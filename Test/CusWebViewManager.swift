//
//  CusWebViewManager.swift
//  Test
//
//  Created by Apple on 2019/5/30.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import WebKit

// 自定義 closure，方便多次呼叫
typealias GetCookiesHandler = ([String: Any]) -> Void

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
    // 網址
    let webViewURL: URL
    // 存放 cookie 資料，是一個 DictionaryArray
    var cookieDictionaryArray: [String: AnyObject]  = [:]
    
    init(webView: WKWebView,
         webViewURL: URL? = nil) {
        
        self.webView = webView
        // 安全型別判斷
        if let webViewURL = webViewURL {
            self.webViewURL = webViewURL
            
        }else {
            self.webViewURL = URL(string: "https://touchbar.tw")!
            
        }
        
        super.init()
        
        webView.navigationDelegate = self
        
        webView.uiDelegate = self
        
    }
    // 取得 webView cookies
    func getWebViewCookies(for domain: String?, completion: @escaping GetCookiesHandler)  {
        // 獲取所有儲存的 cookies
        webViewHttpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                // 安全型別判斷
                if let domain = domain {
                    // 取得當前網域的 cookie，不為 nil 時，會透過搜尋區分大小寫包含 self 在內，成功會回傳 true (非文字搜索)
                    if(true == cookie.domain.contains(domain)) {
                        // properties: 回傳一個 cookie 屬性 DictionaryArray，是唯讀屬性
                        // 將 cookies.name 放入 cookieDictionaryArray
                        self.cookieDictionaryArray[cookie.name] = cookie.properties as AnyObject?
                        
                    }
                    
                }else {
                    // 當前網域的 cookie 為 nil，失敗回傳 false
                    self.cookieDictionaryArray[cookie.name] = cookie.properties as AnyObject?
                    
                }
                
            }
            // 為逃逸閉包，執行完後，可以再次執行閉包
            completion(self.cookieDictionaryArray)
            
        }
        
    }
    
    func webViewdeinit() {
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { (records) in
            for record in records {
                if record.displayName.contains(self.webViewURL.host!) {
                    dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: [record], completionHandler: {
                        print("Deleted: " + record.displayName);
                    })
                }
            }
        }
        
        
    }
    
}
// MARK: WKNavigationDelegate、WKUIDelegate 實作
extension CusWebViewManager: WKNavigationDelegate, WKUIDelegate {
    // webView 開始加載
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("進入加載頁面")
        
    }
    // webView 接收觸發後，決定是否跳轉頁面
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
        
    }
    // webView 頁面加載完成
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        if(nil != webView.title) {
            print("加載頁面完成")
            // 取得 webView cookies
            // url.host: 針對基本的 url 解析，如果 webView.url 不為 nil，回傳主機端 url
            getWebViewCookies(for: webViewURL.host) { (data) in

                print("\(self.webViewURL.absoluteString)")

                print(data)

            }
            
        }else {
            // 頁面重新刷新
            webView.reload()
            
        }
        // testScript 加載本地端與 javaScript 溝通
//        let testJavaScript = "sayHello('touchBarWebView 你好！')"
//
//        webView.evaluateJavaScript(testJavaScript) { (response, error) in
//            print("respones", response ?? "No Response", "errㄟr:", error ?? "No Error")
//
//        }
        
    }
   
    
}
// MARK: WKScriptMessageHandler 實作
extension ViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // 從 javaScript 回傳過來的 string data
        print(message.name)
        
        print(message.body)
        
    }
    
}
