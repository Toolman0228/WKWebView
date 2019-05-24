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
    
    let testGit = 0
    
    let DarkGrayColor: UIColor = UIColor(red: 43/255, green: 43/255, blue: 43/255, alpha: 1)
    
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
        
        testWebViewAttribute()
        
        loadTestWebViewUrl()
    
    }
    
    func testWebViewAttribute() {
        // WKPreferences(): 封裝 webView 偏好設置，對象由 webView 配置指定
        let testPerfernces = WKPreferences()
        // javaScriptEnabled: 是否禁用由網頁加載或執行的 javaScript，默認值為 true
        testPerfernces.javaScriptEnabled = true
        // WKUserContentController(): javaScript 提供將消息發佈到 WebView 方法，與 webView 關聯的本地端內容蠅由 webView 配置指定
        let testUserController = WKUserContentController()
        // WkWebViewConfiguration(): 用於初始化 webView 屬性集合
        let testConfiguration = testWebView.configuration
        
        testConfiguration.preferences = testPerfernces
        
        testConfiguration.userContentController = testUserController
        // isOpaque: 表示 UIView 是否透明，但不表示當前 UIView 是不是不透明
        // 如為 true，UIView 照樣還是可以看見
        testWebView.isOpaque = false
        
        testWebView.backgroundColor = DarkGrayColor
        
    }

    func loadTestWebViewUrl() {

        let webUrl = URL(string: "https://touchbar.tw")

        let request = URLRequest(url: webUrl!)

        testWebView.load(request)
//        // 加載本地端的 HTML 檔案
//        testWebView.loadHTMLString(webHTML, baseURL: nil)

    }
    
}
// WKNavigationDelegate、WKUIDelegate 實作
extension ViewController:  WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("進入加載頁面")
        
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("加載頁面結束")
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if(nil != webView.title) {
            print("正常")
        
        }else {
            // 網頁重新刷新
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
    
}
// WKScriptMessageHandler 實作
extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // 從 javaScript 回傳過來的 string data
        print(message.name)
        
        print(message.body)
        
    }
    
}

