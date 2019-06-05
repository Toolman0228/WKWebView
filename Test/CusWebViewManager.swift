//
//  CusWebViewManager.swift
//  Test
//
//  Created by Apple on 2019/5/30.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import WebKit
import SystemConfiguration

// 自定義 closure，方便多次呼叫
typealias GetCookiesHandler = (_ cookieData: [String: Any]?, _ success: Bool) -> Void
// 自定義 closure，方便多次呼叫
typealias ReMoveCookiesHandler = (WKWebsiteDataRecord) -> Void

class CusWebViewManager: NSObject {
    weak var webView: WKWebView!
    // Read Only
    // WKHTTPCookieStore: 可以新增、刪除、查詢、監聽變化，管理 cookie
    // websiteDataStore: 快取等等資料，具體新增、刪除、查詢的方法，websiteDataStore 都有提供方法
    // WKWebsiteDataStore: 為當前網站所使用各種資料，資料包含 cookie、磁碟、內存、暫存，以及儲存資料
    // default(): 回傳預設儲存的資料
    // httpCookieStore: 回傳當前網頁的儲存資料中，包含帶有 httpCookie 的 cookie
    var webViewHttpCookieStore: WKHTTPCookieStore {
        get {
            return WKWebsiteDataStore.default().httpCookieStore
            
        }
        
    }
    
    var webViewDataStore: WKWebsiteDataStore {
        get {
            return WKWebsiteDataStore.default()
            
        }
        
    }
    // webView cookie 儲存本地端
    var webViewCookieUserDefaults: UserDefaults {
        get {
            return UserDefaults.standard
            
        }
        
    }
    // 判斷是否成功取得 cookie
    var success: Bool
    // webView 網址
    let webViewURL: URL
    // 存放 webView cookie 資料，是一個 DictionaryArray
    var cookieDictionaryArray: [String: AnyObject]  = [:]
    
    init(webView: WKWebView,
         webViewURL: URL? = nil){
        success = false
        
        self.webView = webView
        // 安全型別判斷
        if let webViewURL = webViewURL {
            self.webViewURL = webViewURL
            
        }else {
            self.webViewURL = URL(string: "https://touchbar.tw")!
            
        }
        super.init()
        
    }
    // 取得 webView cookies
    func getWebViewCookies(for domain: String?, completion: @escaping GetCookiesHandler)  {
        // 獲取所有儲存的 cookies
        webViewHttpCookieStore.getAllCookies { cookies in
//            // 儲存 cookie 於本地端
//            self.saveCookiesUserDefaults(cookies)
            
            for cookie in cookies {
                // 安全型別判斷
                if let domain = domain {
                    // 取得當前網域的 cookie，不為 nil 時，會透過搜尋區分大小寫包含 self 在內，成功會回傳 true (非文字搜索)
                    if(true == cookie.domain.contains(domain)) {
                        // properties: 回傳一個 cookie 屬性 DictionaryArray，是唯讀屬性
                        // 將 cookies.name 放入 cookieDictionaryArray
                        self.cookieDictionaryArray[cookie.name] = cookie.properties as AnyObject?
                        // 成功取得 cookie
                        self.success = true
                        
                    }
                    
                }else {
//                    // 當前網域的 cookie 為 nil，失敗回傳 false
//                    self.cookieDictionaryArray[cookie.name] = cookie.properties as AnyObject?
//                    // 無法取得 cookie
                    self.success = false
                    
                }
                
            }
            // 為逃逸閉包，執行完後，可以再次執行閉包
            completion(self.cookieDictionaryArray, self.success)
            
        }
        
    }
    // 刪除 webView cookies
    func reMoveWebViewCookies(for domain: String?, completion: @escaping ReMoveCookiesHandler) {
        // fetchDataRecords(): 取得包含提供 webView data 類型的紀錄
        // ofTypes: 取得紀錄 webView data 的類型
        // WKWebsiteDataStore.allWebsiteDataTypes(): 回傳所有可使用 webView data 的類型
        webViewDataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { (records) in
            
            for record in records {
                // 安全型別判斷
                if let domain = domain {
                    // displayName: webView data 紀錄名稱，通常是網域名稱
                    if(true == record.displayName.contains(domain)) {
                        // 為逃逸閉包，執行完後，可以再次執行閉包
                        completion(record)
            
                    }

                }
            }

        }

    }
    // 儲存 cookie 於本地端
    func saveCookiesUserDefaults(_ saveData: [HTTPCookie]) -> Void {
        // 序列化資料，通過 archivedData 方法，轉為可以儲存資料的型別
        let saveCookiesData = try! NSKeyedArchiver.archivedData(withRootObject: saveData, requiringSecureCoding: false)
        
        webViewCookieUserDefaults.set(saveCookiesData, forKey: "saveCookies")
        
    }
    // 讀取 cookie 於本地端
    func loadCookiesUserDefaults() -> Void {
        // 取出 webViewCookieUserDefaults 儲存資料
        if let fechCookiesData = webViewCookieUserDefaults.data(forKey: "saveCookies") {
            // loadCookiesData
            let _ = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(fechCookiesData) as! [HTTPCookie]
            
        }

    }
    // 檢查是否有開起網路
    func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
        
    }
    
}
// MARK: WKNavigationDelegate、WKUIDelegate 實作
extension CusWebViewManager: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    // webView 收到伺服器響應頭呼叫，包含 response 的相關資訊，回撥決定是否跳轉
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
        
    }
    // webView 加載完成
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if(nil != webView.title) {
            // 取得 webView cookies
            // url.host: 針對基本的 url 解析，如果 webView.url 不為 nil，回傳主機端 url
            self.getWebViewCookies(for: self.webViewURL.host) { (cookieData, success) in
                if(false != success) {
//                    print("\(self.webViewURL.absoluteString)")
//
//                    print(cookieData!)

                }else {
                    print("取得失敗")
                    
                }

            }
            // 刪除 webView cookies
//            self.reMoveWebViewCookies(for: self.webViewURL.host) { (recordData) in
//                // removeData(): 刪除提供 webView 紀錄的類型及 data
//                // ofTypes: 刪除 webView data 的類型
//                // for: 刪除 webView data 的紀錄
//                // completionHandler: 刪除 webView data 的紀錄時，需要做什麼事情，為逃逸閉包
//                self.webViewDataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: [recordData], completionHandler: {
//                    print("Delete: \(recordData.displayName)")
//
//                })
//
//            }

        }else {
            // 頁面重新刷新
            webView.reload()
            
        }
//        // testScript 加載本地端與 javaScript 溝通
//        let testJavaScript = "sayHello('touchBarWebView 你好！')"
//
//        webView.evaluateJavaScript(testJavaScript) { (response, error) in
//            print("respones", response ?? "No Response", "errㄟr:", error ?? "No Error")
//
//        }
        
    }
    // 記憶體佔用過大等原因，造成網頁載入中斷時，使用該方法
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        // 頁面重新刷新
        webView.reload()
        
    }
    // webView 開始載入時，出現錯誤
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // 出現錯誤，停止加載網頁所有資源
        webView.stopLoading()
        
        print("停止")
        
        NSLog("WebView Loading Error: \(error.localizedDescription)")
        
    }
   
}
// MARK: WKScriptMessageHandler 實作
//extension ViewController: WKScriptMessageHandler {

//    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//        // 從 javaScript 回傳過來的 string data
//        print(message.name)
//
//        print(message.body)
//
//        if  let script = WKUserScript.Defined(rawValue: message.name),
//            let url = message.webView?.url {
//            switch script {
//            case .getUrlAtDocumentStartScript: print("start: \(url)")
//            case .getUrlAtDocumentEndScript: print("end: \(url)")
//
//            }
//        }
//
//    }

//}

//extension WKUserScript {
//    enum Defined: String {
//        case getUrlAtDocumentStartScript = "GetUrlAtDocumentStart"
//        case getUrlAtDocumentEndScript = "GetUrlAtDocumentEnd"
//
//        var name: String { return rawValue }
//
//        private var injectionTime: WKUserScriptInjectionTime {
//            switch self {
//            case .getUrlAtDocumentStartScript: return .atDocumentStart
//            case .getUrlAtDocumentEndScript: return .atDocumentEnd
//            }
//        }
//
//        private var forMainFrameOnly: Bool {
//            switch self {
//            case .getUrlAtDocumentStartScript: return false
//            case .getUrlAtDocumentEndScript: return false
//            }
//        }
//
//        private var source: String {
//            switch self {
//            case .getUrlAtDocumentEndScript, .getUrlAtDocumentStartScript:
//                return "webkit.messageHandlers.\(name).postMessage(document.URL)"
//            }
//        }
//
//        func create() -> WKUserScript {
//            return WKUserScript(source: source,
//                                injectionTime: injectionTime,
//                                forMainFrameOnly: forMainFrameOnly)
//        }
//    }
//}

