//
//  ViewController.swift
//  Test
//
//  Created by Apple on 2019/5/15.
//  Copyright © 2019 Apple. All rights reserved.
//
//  以 iphone XR 尺吋為基準

import UIKit
import WebKit

class ViewController: UIViewController {
    
    @IBOutlet weak var testWebView: WKWebView!
    // WKPreferences(): 封裝 webView 偏好設置，對象由 webView 配置指定
    lazy var testPerfernces = WKPreferences()
    // WKUserContentController(): javaScript 提供將消息發佈到 WebView 方法，與 webView 關聯的本地端內容蠅由 webView 配置指定
    lazy var testUserController = WKUserContentController()
    // WkWebViewConfiguration(): 用於初始化 webView 屬性集合
    lazy var testConfiguration = testWebView.configuration
    
    //    let webHTML = try! String(contentsOfFile: Bundle.main.path(forResource: "testScript", ofType: "html")!, encoding: String.Encoding.utf8)
    // MARK: 不使用 storyBoard，透過 lazy 來創造 WKWebView
    //    lazy var touchBarWebView: WKWebView = {
    //        // WKPreferences(): 封裝 webView 偏好設置，對象由 webView 配置指定
    //        let touchBarPerfernces = WKPreferences()
    //        // javaScriptEnabled: 是否禁用由網頁加載或執行的 javaScript，默認值為 true
    //        touchBarPerfernces.javaScriptEnabled = true
    //        // WKUserContentController(): javaScript 提供將消息發佈到 WebView 方法，與 webView 關聯的本地端內容蠅由 webView 配置指定
    //        let touchBarUserScript = WKUserContentController()
    //        // WkWebViewConfiguration(): 用於初始化 webView 屬性集合
    //        let touchBarConfiguration = WKWebViewConfiguration()
    //
    //        touchBarConfiguration.preferences = touchBarPerfernces
    //
    //        touchBarConfiguration.userContentController = touchBarUserScript
    //        // webview 与 swift 溝通的名字 “AppModel”，webview 给 swift 發送消息時，會用到
    //        touchBarConfiguration.userContentController.add(self, name: "AppModel")
    //
    //        let touchbarContantViewFrame = WKWebView(frame: CGRect(x: 0.0, y: 88, width: self.view.frame.width, height: 808))
    //
    //        var touchBarContantView = WKWebView(frame: touchbarContantViewFrame.frame, configuration: touchBarConfiguration)
    //        // scrollView.bounces: 滾動 touchBarContantView 有回彈效果，默認值為 true
    //        touchBarContantView.scrollView.bounces = true
    //        // scrollView.alwaysBounceVertical: 只允許 touchBarContantView 垂直滾動，默認值為 false
    //        touchBarContantView.scrollView.alwaysBounceVertical = true
    //
    //        return touchBarContantView
    //
    //    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        testWebView.navigationDelegate = self
        
        testWebView.uiDelegate = self
        // 設置 webView 屬性及方法
        testWebViewAttribute()
        // 讀取 webView 內容
        loadTestWebViewUrl()
        
    }
    // 設置 webView 屬性及方法
    func testWebViewAttribute() {
        // javaScriptEnabled: 是否禁用由網頁加載或執行的 javaScript，默認值為 true
        testPerfernces.javaScriptEnabled = true
        
        testConfiguration.preferences = testPerfernces
        
        testConfiguration.userContentController = testUserController
        // isOpaque: 表示 UIView 是否透明，但不表示當前 UIView 是不是不透明
        // 如為 true，UIView 照樣還是可以看見
        testWebView.isOpaque = false
        // webView 背景顏色為深灰色
        testWebView.backgroundColor = UIColor().cusDarkGreyColor()
        
    }
    // 讀取 webView 內容
    func loadTestWebViewUrl() {
        // 指定加載網址，網址型別為字串，轉型為 URL
        let webUrl = URL(string: "https://touchbar.tw")
        // URL 加載請求
        let request = URLRequest(url: webUrl!)
        // 讀取 URL 加載請求
        testWebView.load(request)
//        // 加載本地端的 HTML 檔案
//        testWebView.loadHTMLString(webHTML, baseURL: nil)
        
    }
    
}
// MARK: WKNavigationDelegate、WKUIDelegate 實作
extension ViewController:  WKNavigationDelegate, WKUIDelegate {
    // webView 開始加載
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("進入加載頁面")
        
    }
    // webView 頁面加載完成
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if(nil != webView.title) {
            print("加載頁面完成")
            
        }else {
            // 頁面重新刷新
            webView.reload()
            
        }
        // testScript 加載本地端與 javaScript 溝通
//        let testJavaScript = "sayHello('touchBarWebView 你好！')"
//
//        webView.evaluateJavaScript(testJavaScript) { (response, error) in
//
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
// 自定義 closure，方便多次呼叫
typealias GetCookiesHandler = ([String: Any]) -> Void

extension WKWebView {
    // WKHTTPCookieStore: 可以新增、刪除、查詢、監聽變化，管理 cookie
    // websiteDataStore: 快取等等資料，具體新增、刪除、查詢的方法，websiteDataStore 都有提供方法
    // WKWebsiteDataStore: 為當前網站所使用各種資料，資料包含 cookie、磁碟、內存、暫存，以及儲存資料
    // default(): 回傳預設儲存的資料
    // httpCookieStore: 回傳當前網頁的儲存資料中，包含帶有 httpCookie 的 cookie
    var testWebViewHttpCookieStore: WKHTTPCookieStore {
        get {
            // 寫法 (1)
            return WKWebsiteDataStore.default().httpCookieStore
            // 寫法 (2)
//            return WKWebsiteDataStore.default().httpCookieStore
            
        }
        
    }
    // 取得 testWebView cookies
    func getTestWebViewCookies(for domain: String?, completion: @escaping GetCookiesHandler) {
        var cookieDict = [String: AnyObject]()
        
        testWebViewHttpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                
                if let domain = domain {
                    
                    if(cookie.domain.contains(domain)) {
                        cookieDict[cookie.name] = cookie.properties as AnyObject?
                        
                    }
                    
                }else {
                    cookieDict[cookie.name] = cookie.properties as AnyObject?
                    
                }
                
            }
            completion(cookieDict)
            
        }
        
    }
    
}

