//
//  InternetConnectionDataManager.swift
//  Test
//
//  Created by Apple on 2019/6/5.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

typealias StatusHandler = ( _ success: Bool) -> Void

extension CusWebViewManager {
    // 回傳 webView 資料
    func webViewPostdata(for url: String, completion: @escaping StatusHandler) {
        // 存放抓取的 URL
        let postURL: String = url
        // 字串轉成 URL 型別，安全型別判斷
        guard let webViewPostURL = URL(string: postURL) else {
            print("Error: can't create URL")
            
            return
            
        }
        // URL 加載請求
        let postURLRequest = URLRequest(url: webViewPostURL)
        // URLSession 的 URLRequest 會夾帶參數進去，傳出去的方式為 task
        // shared: 使用單例模式，在登入新帳號時，只需要初始化一次就好，可以讓 APP 拿到同一個 instance，讓其他的程式可以共用
        // dataTask: 是一個逃逸閉包，當所有 func 執行完，才會執行到閉包裡的程式碼
        let webViewTask = URLSession.shared.dataTask(with: postURLRequest) { (data, response, error) in
            
            
            
            
        }
        
    }
    
    func makeGetCall() {
        // Set up the URL request
        let todoEndpoint: String = "https://touchbar.tw"
        guard let url = URL(string: todoEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = URLRequest(url: url)
        
        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // make the request
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                print("error calling GET on /todos/1")
                print(error!)
                return
            }
            // make sure we got data
            //            guard let responseData = data else {
            //                print("Error: did not receive data")
            //                return
            //            }
            // parse the result as JSON, since that's what the API provides
            if let response = response as? HTTPURLResponse {
                print("response.statusCode = \(response.statusCode)")
            }
            
            
        }
        task.resume()
        
    }
    
    
}


