//
//  InternetConnectionDataManager.swift
//  Test
//
//  Created by Apple on 2019/6/5.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
// HTTP 狀態碼範圍，狀態碼不為 2XX 範圍，伺服器未成功接收要求，如有在範圍內，伺服器成功接收到客戶端、理解客戶端、以及接受客戶端要求
var statusCodeRange: ClosedRange<Int> {
    return (200 ... 299)
    
}
// 自定義 closure { }，主要為檢查伺服器狀態是否成功接收要求，設置為逃逸閉包，方便多次呼叫
typealias HTTPStatusHandler = ( _ success: Bool) -> Void

extension CusWebViewManager {
    // 回傳 webView 資料
    func webViewPostdata(for url: URL?, StatusCompletion: @escaping HTTPStatusHandler) {
        // 存放抓取的 URL
        let postURL: URL? = url
        // 字串轉成 URL 型別，安全型別判斷
        guard let webViewPostURL = postURL else {
            print("Error: can't create URL")
            
            return
            
        }
        // URL 加載請求
        let postURLRequest: NSMutableURLRequest = NSMutableURLRequest(url: webViewPostURL)
        // 設置 URLRequest 請求方法為 Post
        postURLRequest.httpMethod = "POST"
         // 處裡 webView data 加載及文件，在客戶端與伺服器之間得的上傳與下載
        // URLSession: 處理相關 webView data 傳輸任務的物件，，與客戶端與伺服器之間保持狀態的解決方案 URLRequest 會夾帶參數進去，傳出去的方式為 task
        // shared: 使用單例模式，在登入新帳號時，只需要初始化一次就好，可以讓 APP 拿到同一個 instance，讓其他的程式可以共用
        // dataTask: 透過 webViewPostURL，取得 webViewPostURL 回傳資料、錯誤資訊，需要調用此方法時，才執行，是一個逃逸閉包，當所有 func 執行完，才會執行到閉包裡的程式碼
        let webViewDataTask = URLSession.shared.dataTask(with: postURLRequest as URLRequest) { (data, response, error) in
            // data: data 回傳資料的訊息參數
            guard let data = data else {
                // 自定義 closure { }，主要為檢查伺服器狀態是否成功接收要求，設置為逃逸閉包，方便多次呼叫
                StatusCompletion(false)
                
                print("data wasn't returned by the request!")
                
                return
                
            }
            // error: task 回傳錯誤的訊息參數
            guard error == nil else {
                // 自定義 closure { }，主要為檢查伺服器狀態是否成功接收要求，設置為逃逸閉包，方便多次呼叫
                StatusCompletion(false)
                
                print("error is: \(error!.localizedDescription))")
                
                return
                
            }
            // 回傳的訊息結果
            guard let responseString = String(data: data, encoding: .utf8) else {
                return
                
            }
            // response: task 回傳 HTTP 狀態碼，取得伺服器端 HTTP Respones 狀態
            if let webViewHTTPStatus = response as? HTTPURLResponse  {
                if(true != statusCodeRange.contains(webViewHTTPStatus.statusCode)) {
                    // 自定義 closure { }，主要為檢查伺服器狀態是否成功接收要求，設置為逃逸閉包，方便多次呼叫
                    StatusCompletion(statusCodeRange.contains(webViewHTTPStatus.statusCode))
                    
                    print("web status should be 200，but is \(webViewHTTPStatus.statusCode)")
                    
                    print("responseString = \(responseString)")

                    print("response = \(response!)")

                }else {
                    // 自定義 closure { }，主要為檢查伺服器狀態是否成功接收要求，設置為逃逸閉包，方便多次呼叫
                    StatusCompletion(statusCodeRange.contains(webViewHTTPStatus.statusCode))
                    
                    print("responseString = \(responseString)")
        
                }

            }
      
        }
        // 異步執行，配合上面的 task closure { }，把 task 變成當需要調用的時候，才恢復執行，處於暫停狀態，需要透過 resume() 來啟動
        // resume(): 程式執行順序為開始與伺服器之間會話，會話結束後，才會執行當初產生 task 時傳入的 closure { } 程式碼
        // URLSession.shared.dataTask() 只是為客戶端與伺服器之間保持狀態，不代表開始執行 closure { } 程式碼，一定要配合 resume()，不然不會開始上傳或下載資料，要等呼叫 resume()，才開始執行
        webViewDataTask.resume()
        
    }
    
}


