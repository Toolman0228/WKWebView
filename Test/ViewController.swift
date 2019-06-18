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
    
    var webViewModel: CusWebViewManager!
    
    var webviewNetWorkModel: NetWorkManager!
    // WKPreferences(): 封裝 webView 偏好設置，對象由 webView 配置指定
    lazy var testPerfernces = WKPreferences()
    // WKUserContentController(): javaScript 提供將消息發佈到 WebView 方法，與 webView 關聯的本地端內容蠅由 webView 配置指定
    lazy var testUserController = WKUserContentController()
    // WkWebViewConfiguration(): 用於初始化 webView 屬性集合
    var testConfiguration: WKWebViewConfiguration {
        get {
            return testWebView.configuration
            
        }
        
    }
    
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
        webViewModel = CusWebViewManager(webView: testWebView)
        
        webviewNetWorkModel = NetWorkManager.shared!
        
        self.testWebView.navigationDelegate = webViewModel
        
        self.testWebView.uiDelegate = webViewModel
        // webView 屬性設置
        testWebViewAttribute()
        // 讀取 webView 內容
        loadTestWebViewUrl()
        
    }
    // MARK: 設置 webView 屬性及方法
    // webView 屬性設置
    func testWebViewAttribute() -> Void {
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
    func loadTestWebViewUrl() -> Void {
        // URL 加載請求
        let request = URLRequest(url: webviewNetWorkModel.netWorkURL)
        // 讀取 URL 加載請求
        testWebView.load(request)
        // 加載本地端的 HTML 檔案
//        testWebView.loadHTMLString(webHTML, baseURL: nil)
        
    }

}

//extension WKWebViewConfiguration {
//    func add(script: WKUserScript.Defined, scriptMessageHandler: WKScriptMessageHandler) {
//        userContentController.addUserScript(script.create())
//        userContentController.add(scriptMessageHandler, name: script.name)
//    }
//}

