//
//  CusWebViewManager.swift
//  Test
//
//  Created by Apple on 2019/5/30.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import WebKit

class CusWebViewManager: NSObject {
    
    weak var webView: WKWebView!
    
    weak var btnSuperView: UIView!

    var netWorkModel: NetWorkManager!
//    // webView cookie 儲存本地端
//    let webViewCookieUserDefaults: UserDefaults = UserDefaults.standard
    // Read Only
    // 通過 UIApplication.shared 取得這個單例物件
    // UIApplication: 為應用程式的象徵，每一個應用程式都有一個 UIApplication 物件，系統自動會建立，為一個單例物件，程式啟動後，建立的第一個物件就是 UIApplication，不能手動建立
    // UIApplication.shared.delegate: 可以處理應用程式生命週期事件(程式啟動和關閉)、系統提示(來電)、記憶體警告
    private (set) var loadingViewAppDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    // Read Only
    // DispatchWorkItem: 為一個代碼區塊，可以在任何佇列上被調用，裡面程式碼可以在子執行緒或在主執行緒執行，主要將工作概念封裝，幫助 DispatchQueue 來執行佇列上任務
    private (set) var delayLoadingTimeWorkItem: DispatchWorkItem = {
       return DispatchWorkItem.init(block: {})
        
    }()
    
    init(btnSuperView: UIView,
         webView: WKWebView){
        
        self.btnSuperView = btnSuperView
        
        self.webView = webView
       
        netWorkModel =  NetWorkManager.shared

        super.init()
        
    }
    // 是否使用 scrollView 拖曳手勢
    func webScrollViewGestureRecognizer(_ enable: Bool) {
        // 取得主執行緒使用，異步執行，所有 UI 元件更新，需在主執行緒執行
        DispatchQueue.main.async { [weak self] in
            // 安全型別判斷
            if let webScrollViewSelf = self {
                // scrollView 拖曳手勢識別是否使用
                webScrollViewSelf.webView.scrollView.panGestureRecognizer.isEnabled = enable
                // 判斷是否拖曳手勢
                if(true != enable) {
                    // 隱藏 webView 上按鈕父視圖
                    webScrollViewSelf.btnSuperView.isHidden = true
        
                }else {
                    // 顯示 webView 上按鈕父視圖
                    webScrollViewSelf.btnSuperView.isHidden = false
                    
                }
                
            }
            
        }
        
    }
//    // 儲存 cookie 於本地端
//    func saveCookiesUserDefaults(_ saveData: [HTTPCookie]) -> Void {
//        // 序列化資料，通過 archivedData 方法，轉為可以儲存資料的型別
//        let saveCookiesData = try! NSKeyedArchiver.archivedData(withRootObject: saveData, requiringSecureCoding: false)
//
//        webViewCookieUserDefaults.set(saveCookiesData, forKey: "saveCookies")
//
//    }
//    // 讀取 cookie 於本地端
//    func loadCookiesUserDefaults() -> Void {
//        // 取出 webViewCookieUserDefaults 儲存資料
//        if let fechCookiesData = webViewCookieUserDefaults.data(forKey: "saveCookies") {
//            // loadCookiesData
//            let _ = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(fechCookiesData) as! [HTTPCookie]
//
//        }
//
//    }

}
// MARK: WKNavigationDelegate、WKUIDelegate 實作
extension CusWebViewManager: WKNavigationDelegate, WKUIDelegate {
    // webView 開始加載
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // 是否使用 scrollView 拖曳手勢
        webScrollViewGestureRecognizer(false)
        // 行動數據或 Wifi 開啟，取消 delayTimeWorkItem 任務
        self.delayLoadingTimeWorkItem.cancel()
//        // 檢查是否開啟行動數據
//        netWorkModel.connectToIfaddrs { (connect) in
//            print(connect.count)
//            // 判斷 connect 是否有順利查詢成功 IP 地址資訊
//            print("剛開始載入網頁，IP 地址資訊目前有 \(connect.count) 筆")
//            if(false != (4 > connect.count)) {
//                // 將需要執行工作封裝，方便在任何佇列上被調用
//                self.delayLoadingTimeWorkItem = DispatchWorkItem {
//                    // 取得主執行緒使用，異步執行，所有 UI 元件更新，需在主執行緒執行
//                    DispatchQueue.main.async {
//                        // 創造 AlertController
//                        AlertViewManager.alertView("警告", "請檢查行動數據或 Wifi 是否開啟！") { (netWorkAction) in
//                            // 出現警告視窗，結束後，取消 delayTimeWorkItem 任務
//                            self.delayLoadingTimeWorkItem.cancel()
//
//                            fatalError("WebView connect is error")
//
//                        }
//
//                    }
//
//                }
//                // 佇列上，提交需要執行工作，為子執行緒的異步執行，結束後，會立即返回，不會有執行緒卡住問題
//                // execute: 提交需要執行工作
//                DispatchQueue.global().async(execute: self.delayLoadingTimeWorkItem)
//
//            }else {
//
//
//            }
//
//        }
        
    }
    // webView 收到伺服器響應頭呼叫，包含 response 的相關資訊，回撥決定是否跳轉
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
        
    }
    // webView 收到加載內容開始返回
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        // 刪除存放所有查詢 IP 地址資訊陣列內容
        netWorkModel.IP_addresses.removeAll()
        
        print("載入網頁準備完畢，IP 地址資訊目前有 \(netWorkModel.IP_addresses.count) 筆")
        // webView 正常載入，移除當前視圖上的 loadingView
        self.loadingViewAppDelegate.loadingView.removeLoadingView()
        
        print("DispatchWorkItem 是否取消 \(String(describing: delayLoadingTimeWorkItem.isCancelled))")
        
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
            // 是否使用 scrollView 拖曳手勢
            webScrollViewGestureRecognizer(true)

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
        // 將需要執行工作封裝，方便在任何佇列上被調用
        self.delayLoadingTimeWorkItem = DispatchWorkItem {
            // 設置延遲讀取時間畫面，因為是進行 UI 更新，需要在主執行緒執行
            DispatchQueue.disPatchDelayTime(2.5, .main) {
                // 創造 AlertController
                AlertViewManager.alertView("警告", "請檢查行動數據或 Wifi 是否開啟！") { (netWorkAction) in
                    // 出現警告視窗，結束後，取消 delayTimeWorkItem 任務
                    self.delayLoadingTimeWorkItem.cancel()
                    
                    fatalError("WebView connect is error")
                        
                }
                
            }

        }
        // 佇列上，提交需要執行工作，為子執行緒的異步執行，結束後，會立即返回，不會有執行緒卡住問題
        // execute: 提交需要執行工作
        DispatchQueue.global().async(execute: delayLoadingTimeWorkItem)
        
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
//
//            switch script {
//            case .getUrlAtDocumentStartScript: print("start: \(url)")
//
//            case .getUrlAtDocumentEndScript: print("end: \(url)")
//
//            }
//
//        }
//
//    }
//
//}
//
//extension WKUserScript {
//    enum Defined: String {
//        case getUrlAtDocumentStartScript = "GetUrlAtDocumentStart"
//
//        case getUrlAtDocumentEndScript = "GetUrlAtDocumentEnd"
//
//        var name: String {
//            return rawValue
//
//        }
//
//        private var injectionTime: WKUserScriptInjectionTime {
//            switch self {
//            case .getUrlAtDocumentStartScript: return .atDocumentStart
//
//            case .getUrlAtDocumentEndScript: return .atDocumentEnd
//
//            }
//
//        }
//
//        private var forMainFrameOnly: Bool {
//            switch self {
//            case .getUrlAtDocumentStartScript: return false
//
//            case .getUrlAtDocumentEndScript: return false
//
//            }
//
//        }
//
//        private var source: String {
//            switch self {
//            case .getUrlAtDocumentEndScript, .getUrlAtDocumentStartScript:
//                return "webkit.messageHandlers.\(name).postMessage(document.URL)"
//
//            }
//
//        }
//
//        func create() -> WKUserScript {
//            return WKUserScript(source: source, injectionTime: injectionTime, forMainFrameOnly: forMainFrameOnly)
//
//        }
//
//    }
//
//}

