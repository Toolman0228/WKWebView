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

class CusWebViewManager: NSObject {
    weak var webView: WKWebView!
    // Read Only
    // webView cookie 儲存本地端
    var webViewCookieUserDefaults: UserDefaults {
        get {
            return UserDefaults.standard
            
        }
        
    }
    
    var netWorkModel: NetWorkManager!

    init(webView: WKWebView){
        
        self.webView = webView

        super.init()
        
        netWorkModel =  NetWorkManager.shared
        
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
//    func isConnectedToNetwork() -> Bool {
//
//        var zeroAddress = sockaddr_in()
//        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
//        zeroAddress.sin_family = sa_family_t(AF_INET)
//
//        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
//            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
//                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
//            }
//        }
//
//        var flags = SCNetworkReachabilityFlags()
//        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
//            return false
//        }
//        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
//        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
//        return (isReachable && !needsConnection)
//
//    }
    
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
            netWorkModel.takeWebViewCookies { (cookieData, success) in
                if(false != success) {
                    print(cookieData!)
                    
                }else {
                    print("cookieData 無資料或已被刪除")
                    
                }
                
            }
            // 刪除 webView cookies
            netWorkModel.removeWebViewCookies { (dataRecord, success) in
                if(false != success) {
                    // 刪除提供 webView 紀錄的類型及 data
                    // ofTypes: 刪除 webView data 的類型
                    // for: 刪除 webView data 的紀錄
                    // completionHandler: 刪除 webView data 的紀錄時，需要做什麼事情，為逃逸閉包
                    WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: [dataRecord!], completionHandler: {
                        print("[WebCacheCleaner] Record \(dataRecord!) deleted")
                    })

                }else {
                    print("刪除成功")

                }

            }

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
        
//        print("停止")
//        
//        NSLog("WebView Loading Error: \(error.localizedDescription)")
        
    }
   
}
// MARK: WKScriptMessageHandler 實作
//extension ViewController: WKScriptMessageHandler {
//
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
//
//}
//
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
//    
//}

