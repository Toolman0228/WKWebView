//
//  NetWork.swift
//  Test
//
//  Created by Apple on 2019/6/13.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
// NetWorkError 接收資料狀態錯誤
// enum 列舉: 為自定義一個型別，列舉出一組相關的值，可搭配 switch 使用
enum NetWorkError: Error {
    case netWorkError(String)
    
    case dataInfoError
    
    case jsonResponseError(Error)
    
    case httpStatusCode(Int)
    
}
// 搭配列舉，製作出適用任意型別，主要來將 NetWorkError 回傳的結果，可方便帶到其他地方使用
// generic 泛型: 自定義型別中，定義出適用任意型別的函式及型別
enum RequestResult<T> {    
    case failure(NetWorkError)
    
}

class NetWork<T: Codable>: NSObject {
    // HTTP 狀態碼範圍，狀態碼不為 2XX 範圍，伺服器未成功接收要求，如有在範圍內，伺服器成功接收到客戶端、理解客戶端、以及接受客戶端要求
    var statusCodeRange: ClosedRange<Int> {
        return (200 ... 299)
        
    }
    // 指定加載網址
    let netWorkURL: URL
    // 接收 data 回傳資料的訊息參數
    var netWorkDataTaskData: Data
    // 接收 task 回傳錯誤的訊息參數
    var netWorkDataTaskResponse: String
    // 初始化
    init(netWorkURL: URL,
         netWorkDataTaskData: Data? = nil,
         netWorkDataTaskResponse: String? = nil) {
        
        self.netWorkURL = netWorkURL
        
        if let netWorkDataTaskData = netWorkDataTaskData {
            self.netWorkDataTaskData = netWorkDataTaskData
            
        }else {
            self.netWorkDataTaskData = Data()
            
        }
        
        if let netWorkDataTaskResponse = netWorkDataTaskResponse {
            self.netWorkDataTaskResponse = netWorkDataTaskResponse
            
        }else {
            self.netWorkDataTaskResponse = "載入中"
            
        }
        super.init()
        
    }
    // 自定義 closure { }，主要為檢查伺服器狀態是否成功接收要求，設置為逃逸閉包，方便多次呼叫
    typealias RequestResultHandler = (_ result: RequestResult<Codable>, _ success: Bool) -> Void
    // 回傳 webView 資料
    func webViewPostData(for url: URL, ResultCompletion: @escaping RequestResultHandler) -> Void {
        // URL 加載請求
        let postURLRequest = URLRequest(url: netWorkURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60)
        // 設置 URLRequest 請求方法為 Post
        //        postURLRequest.httpMethod = "POST"
        // 處裡 webView data 加載及文件，在客戶端與伺服器之間得的上傳與下載
        // URLSession: 處理相關 webView data 傳輸任務的物件，，與客戶端與伺服器之間保持狀態的解決方案 URLRequest 會夾帶參數進去，傳出去的方式為 task
        // shared: 使用單例模式，在登入新帳號時，只需要初始化一次就好，可以讓 APP 拿到同一個 instance，讓其他的程式可以共用
        // dataTask: 透過 webViewPostURL，取得 webViewPostURL 回傳資料、錯誤資訊，需要調用此方法時，才執行，是一個逃逸閉包，當所有 func 執行完，才會執行到閉包裡的程式碼
        let webViewDataTask = URLSession.shared.dataTask(with: postURLRequest as URLRequest) { (data, response, error) in
            // data: data 回傳資料的訊息參數
            guard let data = data else {
                // 自定義 closure { }，主要為檢查伺服器狀態是否成功接收要求，設置為逃逸閉包，方便多次呼叫
                ResultCompletion(RequestResult.failure(NetWorkError.dataInfoError), false)
                
                return
                
            }
            // 接收 data 回傳資料的訊息參數
            self.netWorkDataTaskData = data
            // error: task 回傳錯誤的訊息參數
            guard error == nil else {
                // 自定義 closure { }，主要為檢查伺服器狀態是否成功接收要求，設置為逃逸閉包，方便多次呼叫
                ResultCompletion(RequestResult.failure(NetWorkError.netWorkError(error!.localizedDescription)), false)
                
                return
                
            }
            // 回傳的訊息結果
            guard let responseString = String(data: self.netWorkDataTaskData, encoding: .utf8) else {
                return
                
            }
            // task 回傳 HTTP 狀態碼，取得伺服器端 HTTP Respones 狀態
            // response:
            if let webViewHTTPStatus = response as? HTTPURLResponse  {
                if(true != self.statusCodeRange.contains(webViewHTTPStatus.statusCode)) {
                    // 自定義 closure { }，主要為檢查伺服器狀態是否成功接收要求，設置為逃逸閉包，方便多次呼叫
                    ResultCompletion(RequestResult.failure(NetWorkError.httpStatusCode(webViewHTTPStatus.statusCode)), self.statusCodeRange.contains(webViewHTTPStatus.statusCode))
                    
                    print("responseString = \(responseString)")
                    
                    print("response = \(response!)")
                    
                }else {
                    // 自定義 closure { }，主要為檢查伺服器狀態是否成功接收要求，設置為逃逸閉包，方便多次呼叫
                    ResultCompletion(RequestResult.failure(NetWorkError.httpStatusCode(webViewHTTPStatus.statusCode)), self.statusCodeRange.contains(webViewHTTPStatus.statusCode))
                    
                    self.netWorkDataTaskResponse = response.debugDescription
                    
                    print(self.netWorkDataTaskResponse)
                    
                }
                
            }
            
        }
        // 異步執行，配合上面的 task closure { }，把 task 變成當需要調用的時候，才恢復執行，處於暫停狀態，需要透過 resume() 來啟動
        // resume(): 程式執行順序為開始與伺服器之間會話，會話結束後，才會執行當初產生 task 時傳入的 closure { } 程式碼
        // URLSession.shared.dataTask() 只是為客戶端與伺服器之間保持狀態，不代表開始執行 closure { } 程式碼，一定要配合 resume()，不然不會開始上傳或下載資料，要等呼叫 resume()，才開始執行
        webViewDataTask.resume()
        
    }
    // json 格式解碼
    func woebViewJsonDecoder(object: T.Type) -> T? {
        
        do {
            // 類別初始化程序宣告為 decoder 物件
            let jsonDecoder = JSONDecoder()
            // 從指定的 json 格式中，解碼指定類型最上層的資料
            // type: 解碼資料的類型
            // from data: 解碼資料的數據
            // -> T where T : Decodable: 回傳類型為 T 泛型，或者是繼承 decodable 類型物件
            let decoderObject = try jsonDecoder.decode(object, from: self.netWorkDataTaskData)
            
            return decoderObject
            
        }catch {
            print("decoder is \(error as! DecodingError)")
            
        }
        return nil
        
    }
    
}
