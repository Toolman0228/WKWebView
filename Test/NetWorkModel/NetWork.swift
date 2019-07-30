//
//  NetWork.swift
//  Test
//
//  Created by Apple on 2019/6/13.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import WebKit
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
    // Read Only
    // HTTP 狀態碼範圍，狀態碼不為 2XX 範圍，伺服器未成功接收要求，如有在範圍內，伺服器成功接收到客戶端、理解客戶端、以及接受客戶端要求
    var statusCodeRange: ClosedRange<Int> {
        return (200 ... 299)
        
    }
    // Read Only
    // WKHTTPCookieStore: 可以新增、刪除、查詢、監聽變化，管理 cookie
    // WKWebsiteDataStore: 為當前網站所使用各種資料，資料包含 cookie、磁碟、內存、暫存，以及儲存資料
    // default(): 回傳預設儲存的資料
    // httpCookieStore: 回傳當前網頁的儲存資料中，包含帶有 httpCookie 的 cookie
    var webViewHttpCookieStore: WKHTTPCookieStore {
        get {
            return WKWebsiteDataStore.default().httpCookieStore
            
        }
        
    }
    // 指定加載網址
    let netWorkURL: URL
    // 接收回傳資料訊息參數
    var netWorkDataTaskData: Data
    // 接收回傳請求訊息參數
    var netWorkDataTaskResponse: String
    // 存放 webView cookie 資料，是一個 Dictionary
    var cookieDictionaryArray: Dictionary<String, AnyObject>
    // 判斷是否成功取得 cookie 資料
    var success: Bool
    
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
        
        cookieDictionaryArray = [:]
      
        success = false
        
        super.init()
        
    }
    // 自定義 closure { }，主要為檢查伺服器狀態是否成功接收要求，設置為逃逸閉包，方便多次呼叫
    typealias RequestResultHandler = (_ result: RequestResult<Codable>, _ success: Bool) -> Void
    // 回傳 webView 資料
    func webViewRequestData(for url: URL, ResultCompletion: @escaping RequestResultHandler) -> Void {
        // URL 加載請求
        let postURLRequest = URLRequest(url: netWorkURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60)
        // 設置 URLRequest 請求方法為 Post
        //        postURLRequest.httpMethod = "POST"
        // 處裡 webView data 加載及文件，在客戶端與伺服器之間得的上傳與下載
        // URLSession: 處理相關 webView data 傳輸任務的物件，，與客戶端與伺服器之間保持狀態的解決方案 URLRequest 會夾帶參數進去，傳出去的方式為 task
        // shared: 使用單例模式，在登入新帳號時，只需要初始化一次就好，可以讓 APP 拿到同一個 instance，讓其他的程式可以共用
        // dataTask: 透過 webViewPostURL，取得 webViewPostURL 回傳資料、錯誤資訊，需要調用此方法時，才執行，是一個逃逸閉包，當所有 func 執行完，才會執行到閉包裡的程式碼
        // data: task 回傳資料訊息參數
        // response: task 回傳請求信息，發送網路請求時，如果請求成功，會接收到客戶端的回傳訊息，直接開始接收回傳的資料
        // error: task 回傳錯誤訊息參數
        let webViewDataTask = URLSession.shared.dataTask(with: postURLRequest as URLRequest) { (data, response, error) in
            // task 回傳資料訊息參數
            guard let data = data else {
                // 自定義 closure { }，主要為檢查伺服器狀態是否成功接收要求，設置為逃逸閉包，方便多次呼叫
                ResultCompletion(RequestResult.failure(NetWorkError.dataInfoError), false)
                
                return
                
            }
            // 接收回傳資料訊息參數
            self.netWorkDataTaskData = data
            // task 回傳錯誤訊息參數
            guard error == nil else {
                // 自定義 closure { }，主要為檢查伺服器狀態是否成功接收要求，設置為逃逸閉包，方便多次呼叫
                ResultCompletion(RequestResult.failure(NetWorkError.netWorkError(error!.localizedDescription)), false)
                
                return
                
            }
            // 回傳請求 data 轉為字串格式
            guard let responseString = String(data: self.netWorkDataTaskData, encoding: .utf8) else {
                return
                
            }
            // task 回傳 HTTP 狀態碼，取得伺服器端 HTTPRespones 狀態
            // task 回傳請求信息，發送網路請求時，如果請求成功，會接收到客戶端的回傳訊息，直接開始接收回傳的資料
            // HTTPURLResponse: 對 HTTP 請求，回傳被封裝為 HTTPURLResponse 的型別
            if let webViewHTTPStatus = response as? HTTPURLResponse  {
                // 判斷伺服器端 HTTPRespones 狀態是否連線正常
                if(false != self.statusCodeRange.contains(webViewHTTPStatus.statusCode)) {
                    // 自定義 closure { }，主要為檢查伺服器狀態是否成功接收要求，設置為逃逸閉包，方便多次呼叫
                    ResultCompletion(RequestResult.failure(NetWorkError.httpStatusCode(webViewHTTPStatus.statusCode)), self.statusCodeRange.contains(webViewHTTPStatus.statusCode))
                    // 接收回傳請求訊息參數
                    // description: 程序中打印出 Log 調用的方法
                    // debugDescription: 進行斷點測試時，可以在除錯視窗輸入 po 的語法，來打印出調用的方法
                    self.netWorkDataTaskResponse = response!.description
                    
                }else {
                    // 自定義 closure { }，主要為檢查伺服器狀態是否成功接收要求，設置為逃逸閉包，方便多次呼叫
                    ResultCompletion(RequestResult.failure(NetWorkError.httpStatusCode(webViewHTTPStatus.statusCode)), self.statusCodeRange.contains(webViewHTTPStatus.statusCode))
                    
                    print("responseString = \(responseString)")
                    
                    print("response = \(response!)")
                    
                }
                
            }
            
        }
        // 異步執行，配合上面的 task closure { }，把 task 變成當需要調用的時候，才恢復執行，處於暫停狀態，需要透過 resume() 來啟動
        // resume(): 程式執行順序為開始與伺服器之間會話，會話結束後，才會執行當初產生 task 時傳入的 closure { } 程式碼
        // URLSession.shared.dataTask() 只是為客戶端與伺服器之間保持狀態，不代表開始執行 closure { } 程式碼，一定要配合 resume()，不然不會開始上傳或下載資料，要等呼叫 resume()，才開始執行
        webViewDataTask.resume()
        
    }
    // 處理 cookies 資料，回傳完整 cookie 資料陣列
    private func webViewCookie(_ cookies: [HTTPCookie]) -> [String: Any]? {
        print(cookies.count)
        for cookie in cookies {
            // properties: 回傳一個 cookie 屬性 DictionaryArray，是唯讀屬性
            // 將 cookies.name 放入 cookieDictionaryArray
            self.cookieDictionaryArray[cookie.name] = cookie.properties as AnyObject?
            // 安全型別判斷
//            if let domain = self.netWorkURL.host {
//                // 取得當前 cookie 的網域，不為 nil 時，會透過搜尋區分大小寫包含 self 在內，成功會回傳 true (非文字搜索)
//                // 如果在網域 A 產生一個 A 域和 B 域都能訪問的 cookie，就將該 cookie 的網域設置為 .test.com
//                // 如果在網域 A 產生一個 A 域不能訪問而 B 域都能訪問的 cookie，就將該 cookie 的網域設置為 t1.test.com
//                // 會產生不同 cookie.domain 名稱
//                if(true == cookie.domain.contains(domain)) {
//
//                }
//
//            }
        
        }
        return self.cookieDictionaryArray
        
    }
    // 自定義 closure，主要為取得 cookies 是否成功，設置為逃逸閉包，方便多次呼叫
    typealias GetCookiesHandler = (_ cookieData: [String: Any]?, _ success: Bool) -> Void
    // 取得 webView cookies
    func takeWebViewCookies(_ getCompletion:  @escaping GetCookiesHandler) -> Void {
        // 取得主執行緒使用，異步執行
        DispatchQueue.main.async {
            // 獲取所有儲存的 cookies
            self.webViewHttpCookieStore.getAllCookies { [weak self] takeCookies in
                // 儲存 cookies 於本地端
                // self.saveCookiesUserDefaults(cookies)
                // 處理 cookies 資料，回傳完整 cookie 資料陣列
                if let takeCookieDictionaryArray = self!.webViewCookie(takeCookies) {
                    // 取得 cookie 資料判斷成功
                    self!.success = true
                    // 主要為取得 cookies 是否成功，設置為逃逸閉包，方便多次呼叫
                    getCompletion(takeCookieDictionaryArray, self!.success)
                    
                }else {
                    // 取得 cookie 資料判斷失敗
                    self!.success = false
                    // 主要為取得 cookies 是否成功，設置為逃逸閉包，方便多次呼叫
                    getCompletion(nil, self!.success)
                    
                }
                
            }
        }
        
    }
    
    func deleteWebViewCookies() -> Void {
        
        if let exsitCookies = HTTPCookieStorage.shared.cookies(for: netWorkURL) {
    
            for exsitCookie in exsitCookies {
                webViewHttpCookieStore.delete(exsitCookie)

            }
            
        }
        
//        var DictionaryArray: Dictionary<String, AnyObject> = [:]
//
//        let takeCookies = HTTPCookieStorage.shared.cookies(for: netWorkURL)
//
//        if let takeCookie = takeCookies {
//
//            for Cookie in takeCookie {
//
//                if(true == Cookie.domain.contains(netWorkURL.host!)) {
//                    DictionaryArray[Cookie.name] = Cookie.properties as AnyObject?
//
//                    print("===============")
//
//                    print(DictionaryArray)
//
//                }
//
//            }
//
//        }else {
//            print("我在這")
//
//
//        }
        
    }
    // json 格式解碼
    func webViewJsonDecoder(_ object: T.Type) -> T? {
        
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
    // json 格式編碼
    func webViewJsonEncoder() {
        
    }
//    // 自定義 closure，主要為取得 cookies 是否成功，設置為逃逸閉包，方便多次呼叫
//    typealias GetCookiesHandler = (_ cookieData: [String: Any]?, _ success: Bool) -> Void
//    // 取得 webView cookies
//    func takeWebViewCookies(_ getCompletion:  @escaping GetCookiesHandler) -> Void {
//        // 獲取所有儲存的 cookies
//        webViewHttpCookieStore.getAllCookies { cookies in
//            // 儲存 cookie 於本地端
//            // self.saveCookiesUserDefaults(cookies)
//
//            for cookie in cookies {
//                // 安全型別判斷
//                if let domain = self.netWorkURL.host {
//                    // 取得當前網域的 cookie，不為 nil 時，會透過搜尋區分大小寫包含 self 在內，成功會回傳 true (非文字搜索)
//                    if(true == cookie.domain.contains(domain)) {
//                        // properties: 回傳一個 cookie 屬性 DictionaryArray，是唯讀屬性
//                        // 將 cookies.name 放入 cookieDictionaryArray
//                        self.cookieDictionaryArray[cookie.name] = cookie.properties as AnyObject?
//                        // 成功取得 cookie
//                        self.success = true
//
//                    }
//
//                }else {
//                    // 當前網域的 cookie 為 nil，失敗回傳 false
//                    self.cookieDictionaryArray[cookie.name] = cookie.properties as AnyObject?
//                    // 無法取得 cookie
//                    self.success = false
//
//                }
//
//
////                HTTPCookieStorage.shared.setCookie(cookie)
//
//            }
//            // 為逃逸閉包，執行完後，可以再次執行閉包
//            getCompletion(self.cookieDictionaryArray, self.success)
//
//        }
//
//    }
    
}
