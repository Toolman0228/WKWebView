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
    
    var netWorkModel: NetWorkManager!
    // webView cookie 儲存本地端
    let webViewCookieUserDefaults: UserDefaults = UserDefaults.standard
    // Read Only
    private (set) var loadingViewAppDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    // Read Only
    // DispatchWorkItem: 為一個代碼區塊，可以在任何佇列上被調用，裡面程式碼可以在子執行緒或在主執行緒執行，主要將工作概念封裝，幫助 DispatchQueue 來執行佇列上任務
    private (set) var delayTimeWorkItem: DispatchWorkItem?
    
    init(webView: WKWebView){
        
        self.webView = webView
        
        netWorkModel =  NetWorkManager.shared
        
        delayTimeWorkItem = DispatchWorkItem.init(block: {})
       
        super.init()
        
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

}
// MARK: WKNavigationDelegate、WKUIDelegate 實作
extension CusWebViewManager: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // 檢查是否開啟行動數據
        let connect: [String] = netWorkModel.connectToIfaddrs()
        // 判斷 connect 陣列是否為空
        if(false != connect.isEmpty) {
            // 判斷 delayTimeWorkItem 是否為空
            if(nil != delayTimeWorkItem) {
                // 將需要執行工作封裝，方便在任何佇列上被調用
                delayTimeWorkItem = DispatchWorkItem { [weak self] in
                    if let cusWebViewManagerSelf = self {
                        // 設置 loadingView 延遲讀取時間畫面
                        cusWebViewManagerSelf.loadingViewAppDelegate.loadingView.loadingViewDelayTime(2.0, .background) {
                            print("loadingView 延遲消失")
                            // webView 無法收到加載內容開始，移除當前視圖上的 loadingView
                            cusWebViewManagerSelf.loadingViewAppDelegate.loadingView.removeLoadingView()

                        }

                    }

                }
                // 佇列上，提交需要執行工作，為子執行緒的異步執行，結束後，會立即返回，不會有執行緒卡住問題
                // execute: 提交需要執行工作
                DispatchQueue.global().async(execute: delayTimeWorkItem!)
    
            }
    
        }else {
            // 行動數據開啟，delayTimeWorkItem 為 nil
            delayTimeWorkItem = nil
            
        }
        
    }
    // webView 收到伺服器響應頭呼叫，包含 response 的相關資訊，回撥決定是否跳轉
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
        
    }
    // webView 收到加載內容開始
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        // 判斷 delayTimeWorkItem 是否為 nil
        if(nil != delayTimeWorkItem) {
            print("DispatchWorkItem 沒有取消")
            
        }else {
            print("DispatchWorkItem 沒有使用")
            // webView 正常載入，移除當前視圖上的 loadingView
            self.loadingViewAppDelegate.loadingView.removeLoadingView()
            
        }
        
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
        // 取消任務
        delayTimeWorkItem?.cancel()
        // 判斷任務是否取消
        if(false != delayTimeWorkItem?.isCancelled) {
            NSLog("停止，WebView Loading Error: \(error.localizedDescription)")
            
            fatalError("WebView connect is error")
            
        }else {
            NSLog("其他原因，WebView Loading Error: \(error.localizedDescription)")
            
        }
        
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

