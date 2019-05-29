//
//  TestViewControllerModel.swift
//  Test
//
//  Created by Apple on 2019/5/29.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import WebKit

class TestViewControllerModel<T>: NSObject {
    
    var genericWebView: T
    
    init(genericWebView: T) {
        self.genericWebView = genericWebView
        
    }
    
    var testWebViewHttpCookieStore: WKHTTPCookieStore {
        get {
            return WKWebsiteDataStore.default().httpCookieStore
            
        }
        
    }
    // 自定義 closure，方便多次呼叫
    typealias GetCookiesHandler = ([String: Any]) -> Void
    // 取得 testWebView cookies
    func getTestWebViewCookies(for domain: String?, completion: @escaping GetCookiesHandler) {
        // 存放 cookie 資料，是一個 DictionaryArray
        var cookieDictionaryArray = [String: AnyObject]()
        // 獲取所有儲存的 cookies
        testWebViewHttpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                // 安全型別判斷
                if let domain = domain {
                    // 取得當前網域的 cookie，不為 nil 時，會透過搜尋區分大小寫包含 self 在內，成功會回傳 true (非文字搜索)
                    if(true == cookie.domain.contains(domain)) {
                        // properties: 回傳一個 cookie 屬性 DictionaryArray，是唯讀屬性
                        // 將 cookies.name 放入 cookieDictionaryArray
                        cookieDictionaryArray[cookie.name] = cookie.properties as AnyObject?
                        
                    }
                    
                }else {
                    // 當前網域的 cookie 為 nil，失敗回傳 false
                    cookieDictionaryArray[cookie.name] = cookie.properties as AnyObject?
                    
                }
                
            }
            // 為逃逸閉包，執行完後，可以再次執行閉包
            completion(cookieDictionaryArray)
            
        }
        
    }
    
    
}
