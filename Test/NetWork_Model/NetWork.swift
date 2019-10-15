//
//  NetWork.swift
//  Test
//
//  Created by Apple on 2019/6/13.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import WebKit
import CoreTelephony
import SystemConfiguration
// 透過基地台支援的無線存取技術，讓不同存取技術的使用者來存取網路
// 無線存取技術參數
// Radio Access Technology Values
// enum 列舉: 為自定義一個型別，列舉出一組相關的值，可搭配 switch 使用
enum RadioAccessTechnoloyType: String {
    
    case CTRadioAccessTechnologyGPRS
    
    case CTRadioAccessTechnologyEdge
    
    case CTRadioAccessTechnologyWCDMA
    
    case CTRadioAccessTechnologyHSDPA
    
    case CTRadioAccessTechnologyHSUPA
    
    case CTRadioAccessTechnologyCDMA1x
    
    case CTRadioAccessTechnologyCDMAEVDORev0
    
    case CTRadioAccessTechnologyCDMAEVDORevA
    
    case CTRadioAccessTechnologyCDMAEVDORevB
    
    case CTRadioAccessTechnologyeHRPD
    
    case CTRadioAccessTechnologyLTE
    
}
// 接收回傳 webView 資料狀態錯誤
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
    // 計算屬性
    // 取得行動數據的服務電信業者資訊
    // CTTelephonyNetworkInfo(): 取得手機上行動數據資訊，並不是在 Sim 卡插入時取得，需要為 Sim 卡鎖定才取得
    // serviceSubscriberCellularProviders: 提供行動數據的服務電信業者
    var cellularDataCarrier: String? {
        return CTTelephonyNetworkInfo().serviceSubscriberCellularProviders?.first?.value.carrierName
        
    }
    // 計算屬性
    // 取得目前行動數據的存取技術
    // serviceCurrentRadioAccessTechnology: 提供行動數據的服務通訊技術，例如 2G、3G、4G
    var cellularDataRadioAccess: String? {
        return CTTelephonyNetworkInfo().serviceCurrentRadioAccessTechnology?.first?.value
        
    }
    // Read Only
    // WKHTTPCookieStore: 可以新增、刪除、查詢、監聽變化，管理 cookie
    // WKWebsiteDataStore: 為當前網站所使用各種資料，資料包含 cookie、磁碟、內存、暫存，以及儲存資料、快取等等資料，具體新增、刪除、查詢的方法，WKWebsiteDataStore 都有提供方法
    // default(): 回傳預設儲存的資料
    // httpCookieStore: 回傳當前網頁的儲存資料中，包含帶有 httpCookie 的 cookie
    private (set) var webViewHttpCookieStore: WKHTTPCookieStore = WKWebsiteDataStore.default().httpCookieStore
    // 指定加載網址
    let netWorkURL: URL
    // 接收回傳資料訊息參數
    var netWorkDataTaskData: Data
    // 接收回傳請求訊息參數
    var netWorkDataTaskResponse: String
    // 存放所有查詢 IP 地址資訊陣列
    var IP_addresses: [String]
    // 存放 webView cookie 資料，是一個 Dictionary
    var cookieDictionaryArray: Dictionary<String, AnyObject>
    // HTTP 狀態碼範圍，狀態碼不為 2XX 範圍，伺服器未成功接收要求，如有在範圍內，伺服器成功接收到客戶端、理解客戶端、以及接受客戶端要求
    let statusCodeRange: ClosedRange<Int>  = (200 ... 299)
    
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
        
        IP_addresses = []
        
        cookieDictionaryArray = [:]
        
        super.init()
        
    }
    // 檢查行動數據資訊
    func connectToRadioAccessValues(_ NetWorkInfoType: String?) -> String? {
        // 判斷取得行動數據的存取技術
        switch NetWorkInfoType {
        case RadioAccessTechnoloyType.CTRadioAccessTechnologyGPRS.rawValue:
            return "2G"
            
        case RadioAccessTechnoloyType.CTRadioAccessTechnologyEdge.rawValue:
            return "2G"
            
        case RadioAccessTechnoloyType.CTRadioAccessTechnologyWCDMA.rawValue:
            return "3G"
            
        case RadioAccessTechnoloyType.CTRadioAccessTechnologyHSDPA.rawValue:
            return "3G"
            
        case RadioAccessTechnoloyType.CTRadioAccessTechnologyHSUPA.rawValue:
            return "3G"
            
        case RadioAccessTechnoloyType.CTRadioAccessTechnologyCDMA1x.rawValue:
            return "3G"
            
        case RadioAccessTechnoloyType.CTRadioAccessTechnologyCDMAEVDORev0.rawValue:
            return "3G"
            
        case RadioAccessTechnoloyType.CTRadioAccessTechnologyCDMAEVDORevA.rawValue:
            return "3G"
            
        case RadioAccessTechnoloyType.CTRadioAccessTechnologyCDMAEVDORevB.rawValue:
            return "3G"
            
        case RadioAccessTechnoloyType.CTRadioAccessTechnologyeHRPD.rawValue:
            return "3G"
            
        case RadioAccessTechnoloyType.CTRadioAccessTechnologyLTE.rawValue:
            return "4G"
            
        default:
            break
            
        }
        return nil
        
    }
    // 自定義 closure { }，由於 sequence 方法，本身設置為逃逸閉包，造成當執行方此方法時，需要等方法內的齊其他事情做完吼後，才會最後執行，導致會回傳出一個空的陣列，修改方法為將本身有逃逸閉包再帶出去一次
    typealias IfaddrsHandler = (_ ifaddrsArray: [String]) -> Void
    // 檢查是否開啟行動數據
    func connectToIfaddrs(for ifaddrsCompletion: @escaping IfaddrsHandler) {
        // Get list of all interfaces on the local machine:
        // 使用指標達到三種目的:
        // 1. 用來動態產生某個物件的實體
        // 2. 用來產生一連串相同大小的物件
        // 3. 分配一塊記憶體空間作為存取資料的緩衝區
        // 存放取得手機 IP 地址變數，擁有 UnsafeMutablePointer<ifaddrs> 的屬性
        // UnsafeMutablePointer<Pointee>: 可變指標類型，可以修改此記憶體區塊內容，內存值可改變，通過 Pointee 屬性，進行賦予、取值
        // ifaddrs: 為一個結構，主要作用為取得 IP 地址變數
        // 申請內存時，並不會有 ARC 管理，需要注意手動記憶體釋放，類似 MRC
        var IP_ifaddrs: UnsafeMutablePointer<ifaddrs>?
        // 取得手機 IP 接口資訊，帶入參數為取得 IP 地址
        // getifaddrs(): 指標會指向一個新的鏈結串列，會回傳一個指標，定義 32 位元有符號整數，為 Int32
        // & 符號: 可以將指向變量指標傳遞到接受指標作為參數的方法中使用，Ｃ 語言為取址
        guard getifaddrs(&IP_ifaddrs) == 0 else {
            return
            
        }
        // 存放 IP_ifaddr 變數，不為 0 時，取得第一個元素
        guard let first_IP_ifaddrs = IP_ifaddrs else {
            return
            
        }
        // 取得主執行緒使用，異步執行
        DispatchQueue.main.async { [weak self] in
            if let ifaddrsSelf = self {
                // 透過遍歷來檢查序列回傳的元素
                // sequence(): 回傳序列返回的類型，首先重複延遲的應用程序後，再到下一個，first 會傳遞前一個元素，返回每個值，並繼續返回下一個元素
                // first: 從序列返回的第一個元素
                // next: 為閉包，接受前一個序列元素，並返回下一個元素，帶入閉包參數為閉包第一個參數的指針，指向鏈結串列下一個為元素
                for IP_Pointee in sequence(first: first_IP_ifaddrs, next: { $0.pointee.ifa_next } ) {
                    // 手機 IP 裝置標識位，型別轉為定義 32 位有符號整數，為帶正負號 Int
                    // ifa_flags: IP 裝置標識
                    let IP_ifa_flags: Int32 = Int32(IP_Pointee.pointee.ifa_flags)
                    // 手機 IP 裝置地址
                    // ifa_addr: 指向一個包含 IP 地址的 sockaddr 結構
                    let IP_ifa_addr: sockaddr = IP_Pointee.pointee.ifa_addr.pointee
                    // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
                    // 判斷手機 IP 裝置標識位
                    // IFF_UP: 裝置正在運作，代表網路裝置是否正常啟用，拔除網路線並不會有任何變化
                    // IFF_RUNNING: 資源已分配，代表網路裝置是否正常啟用，拔除網路線會造成改變
                    // IFF_LOOPBACK: 自環接口，類似一張虛擬網路裝置
                    if(IP_ifa_flags & (IFF_UP | IFF_LOOPBACK) == IFF_UP) {
                        // 判斷手機 IP 接口標識位為 IPV4、IPV6
                        // sa_family: IP 地址種類，值為 AF_INET 時，代表 IPV4 地址，值為 AF_INET6 時，代表 IPV6 地址
                        if(IP_ifa_addr.sa_family == UInt8(AF_INET) || IP_ifa_addr.sa_family == UInt8(AF_INET6)) {
                            // Convert interface address to a human readable string:
                            // hostName 是一個陣列，陣列型別為 char，存放取得 IPV4、IPV6 地址串
                            // 主機名稱或者為地址串(IPV4 表示為點分十進位、IPV6 表示為十六進制)
                            // repeating: 重複的元素
                            // count: 重複的元素中，傳遞值的次數，必須為 0 或比 0 更大，定義 hostName 陣列大小
                            var IP_hostName: [CChar] = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                            // 必須將一個指向 sockaddr 結構的指標(可能是轉型過的 sockaddr_in 結構或是 sockaddr_in6 結構)傳遞給 sa 參數，這個結構的長度為 salen，可以查詢到 host name 與 service name 寫入 host 與 serv 參數所指的記憶體空間，必須用 hostlen 與 servlen 來指定這些緩衝區的最大長度
                            // getnameinfo(): getaddrinfo() 的對比，sockaddr 結構提供資訊查詢主機名稱(host name)及描述服務名稱(service name)資訊，成功會回傳 0，失敗會回傳 -1
                            // UnsafePointer<Pointee>: 標準指標，指向某種型態的記憶體區塊，內存值不可改變
                            // IP_Pointee.pointee.ifa_addr: 準備要用的 socket 位置資料結構，記錄很多 sockets 類型的 socket 位置資訊，為 sockaddr 結構
                            // socklen_t(IP_ifa_addr.sa_len): socklen_t 長度為取得 IP 地址總長度，數據類型 socklen_t 和 Int 應該具有相同的長度
                            // &IP_hostName: 取得 IP_hostName 資訊，為定義 8 位元有符號整數，為 Int8，為 char
                            // socklen_t(IP_hostName.count): socklen_t 長度為 hostName 陣列大小，數據類型 socklen_t 和 Int 應該具有相同的長度，為 sockaddr 結構
                            // socklen_t(0): socklen_t 長度為 0，為 sockaddr 結構
                            // NI_NUMERICHOST: 以數字串格式返回主機字元串
                            let IP_getNameInfo: Int32 = getnameinfo(IP_Pointee.pointee.ifa_addr , socklen_t(IP_ifa_addr.sa_len), &IP_hostName, socklen_t(IP_hostName.count), nil, socklen_t(0), NI_NUMERICHOST)
                            // 判斷 getnameinfo() 回傳是否為 0
                            if(0 != IP_getNameInfo) {
                                // 查詢失敗
                                // gai_strerror(): 不為 0 時，可以將回傳值帶入，取得錯誤的文字資訊
                                //
                                gai_strerror(IP_getNameInfo)
                                
                            }else {
                                // 判斷 IP 地址資訊是否會重複放入陣列
                                if(4 > ifaddrsSelf.IP_addresses.count) {
                                    // 查詢成功
                                    // 將 c 語言的 char 類型轉換成 c 語言的字串類型，再轉換成字串
                                    let IP_address: String = String(cString: IP_hostName)
                                    // 查詢到所有 IP 地址資訊放入一個陣列
                                    ifaddrsSelf.IP_addresses.append(IP_address)
                                    
                                }
                                
                                
                            }
                            
                        }
                        
                    }
                    
                }
                // 使用完畢，需要釋放記憶體，主要釋放 ifaddrs 結構
                freeifaddrs(IP_ifaddrs)
                // 自定義 closure { }，由於 sequence 方法，本身設置為逃逸閉包，造成當執行方此方法時，需要等方法內的齊其他事情做完吼後，才會最後執行，導致會回傳出一個空的陣列，修改方法為將本身有逃逸閉包再帶出去一次
                ifaddrsCompletion(ifaddrsSelf.IP_addresses)
                
            }
            
        }
    
    }
    // 檢查是否開啟 wifi 使用
    func connectToWifi() -> Bool {

        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }

        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)

    }
//    // 檢查行動數據、wifi 狀態
//    func netWorkConnectStatus() -> Bool {
//        // 檢查是否開啟行動數據
//        let ifaddrs: [String] = connectToIfaddrs()
//        // 檢查是否開啟 wifi 使用
//        let wifi: Bool = isConnectedToNetwork()
//        
//        switch (ifaddrs.isEmpty, wifi) {
//        case (false, false):
//            return true
//            
//        case (true, true):
//            return true
//            
//        case (false, true):
//            return true
//            
//        case (true, false):
//            return false
//    
//        }
//        
//    }
    // 自定義 closure { }，主要為檢查伺服器狀態是否成功接收要求，設置為逃逸閉包，方便多次呼叫
    typealias RequestResultHandler = (_ result: RequestResult<Codable>, _ success: Bool) -> Void
    // 回傳 webView 資料
    func webViewRequestData(for url: URL, ResultCompletion: @escaping RequestResultHandler) -> Void {
        // URL 加載請求
        // timeIntervalSince1970: 格林威治時間 1970 年 01 月 01 日 00 時 00 分 00 秒至當下的時間秒差
        //格林威治時間1970年01月01日 00時00分00秒 」至當下的時間的秒差
        let postURLRequest: URLRequest = URLRequest(url: netWorkURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60)
        // 設置 URLRequest 請求方法為 Post
        //        postURLRequest.httpMethod = "POST"
        // 處裡 webView data 加載及文件，在客戶端與伺服器之間得的上傳與下載
        // URLSession: 處理相關 webView data 傳輸任務的物件，，與客戶端與伺服器之間保持狀態的解決方案 URLRequest 會夾帶參數進去，傳出去的方式為 task
        // shared: 使用單例模式，在登入新帳號時，只需要初始化一次就好，可以讓 APP 拿到同一個 instance，讓其他的程式可以共用
        // dataTask: 透過 webViewPostURL，取得 webViewPostURL 回傳資料、錯誤資訊，需要調用此方法時，才執行，是一個逃逸閉包，當所有 func 執行完，才會執行到閉包裡的程式碼
        // data: task 回傳資料訊息參數
        // response: task 回傳請求信息，發送網路請求時，如果請求成功，會接收到客戶端的回傳訊息，直接開始接收回傳的資料
        // error: task 回傳錯誤訊息參數
        let webViewDataTask: URLSessionDataTask = URLSession.shared.dataTask(with: postURLRequest as URLRequest) { [weak self] (data, response, error) in
            // task 回傳資料訊息參數
            guard let data = data else {
                // 自定義 closure { }，主要為檢查伺服器狀態是否成功接收要求，設置為逃逸閉包，方便多次呼叫
                ResultCompletion(RequestResult.failure(NetWorkError.dataInfoError), false)
                
                return
                
            }
            // 接收回傳資料訊息參數
            self!.netWorkDataTaskData = data
            // task 回傳錯誤訊息參數
            guard error == nil else {
                // 自定義 closure { }，主要為檢查伺服器狀態是否成功接收要求，設置為逃逸閉包，方便多次呼叫
                ResultCompletion(RequestResult.failure(NetWorkError.netWorkError(error!.localizedDescription)), false)
                
                return
                
            }
            // 回傳請求 data 轉為字串格式
            guard let responseString = String(data: self!.netWorkDataTaskData, encoding: .utf8) else {
                return
                
            }
            // 取得主執行緒使用，異步執行
            DispatchQueue.main.async { [weak self] in
                // task 回傳 HTTP 狀態碼，取得伺服器端 HTTPRespones 狀態
                // task 回傳請求信息，發送網路請求時，如果請求成功，會接收到客戶端的回傳訊息，直接開始接收回傳的資料
                // HTTPURLResponse: 對 HTTP 請求，回傳被封裝為 HTTPURLResponse 的型別
                if let webViewHTTPStatus = response as? HTTPURLResponse  {
                    // 安全型別判斷
                    if let netWorkSelf = self {
                        // 判斷伺服器端 HTTPRespones 狀態是否連線正常
                        if(false != netWorkSelf.statusCodeRange.contains(webViewHTTPStatus.statusCode)) {
                            // 自定義 closure { }，主要為檢查伺服器狀態是否成功接收要求，設置為逃逸閉包，方便多次呼叫
                            ResultCompletion(RequestResult.failure(NetWorkError.httpStatusCode(webViewHTTPStatus.statusCode)), netWorkSelf.statusCodeRange.contains(webViewHTTPStatus.statusCode))
                            // 接收回傳請求訊息參數
                            // description: 程序中打印出 Log 調用的方法
                            // debugDescription: 進行斷點測試時，可以在除錯視窗輸入 po 的語法，來打印出調用的方法
                            netWorkSelf.netWorkDataTaskResponse = response!.description
                            
                        }else {
                            // 自定義 closure { }，主要為檢查伺服器狀態是否成功接收要求，設置為逃逸閉包，方便多次呼叫
                            ResultCompletion(RequestResult.failure(NetWorkError.httpStatusCode(webViewHTTPStatus.statusCode)), netWorkSelf.statusCodeRange.contains(webViewHTTPStatus.statusCode))
                            
                            print("responseString = \(responseString)")
                            
                            print("response = \(response!)")
                            
                        }
                        
                    }
                    
                    
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
    func takeWebViewCookies(_ getCompletion: @escaping GetCookiesHandler) -> Void {
        // 取得主執行緒使用，異步執行
        DispatchQueue.main.async { [weak self] in
            // 安全型別判斷
            if let takeCookiesSelf = self {
                // 獲取所有儲存的 cookies
                takeCookiesSelf.webViewHttpCookieStore.getAllCookies { takeCookies in
                    // 判斷 cookies 總共有幾筆
                    if(0 != takeCookies.count) {
                        // 儲存 cookies 於本地端
                        // self.saveCookiesUserDefaults(cookies)
                        // 處理 cookies 資料，回傳完整 cookie 資料陣列
                        if let takeCookieDictionaryArray = takeCookiesSelf.webViewCookie(takeCookies) {
                            // 主要為取得 cookies 是否成功，設置為逃逸閉包，方便多次呼叫
                            getCompletion(takeCookieDictionaryArray, true)
                            
                        }else {
                            // 當前網域的 cookie 為 nil，失敗回傳 false
                            // 主要為取得 cookies 是否成功，設置為逃逸閉包，方便多次呼叫
                            getCompletion(nil, false)
                            
                        }
                        
                    }else {
                        // 當前網域的 cookie 為 nil，失敗回傳 false
                        // 主要為取得 cookies 是否成功，設置為逃逸閉包，方便多次呼叫
                        getCompletion(nil, false)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    // 自定義 closure，主要為將刪除 cookies 帶出，設置為逃逸閉包，方便多次呼叫
    typealias DeleteCookiesHandler = (_ recordData: WKWebsiteDataRecord?, _ success: Bool) -> Void
    // 刪除 webView cookies
    func removeWebViewCookies(deleteCompletion: @escaping DeleteCookiesHandler) -> Void {
        // 取得主執行緒使用，異步執行
        DispatchQueue.main.async { [weak self] in
            // 刪除被指定時間後所有的 cookies
            HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
            // 刪除全部緩存
            URLCache.shared.removeAllCachedResponses()
            // 取得包含提供 webView data 類型的紀錄
            // ofTypes: 取得紀錄 webView data 的類型
            // WKWebsiteDataStore.allWebsiteDataTypes(): 回傳所有可使用 webView data 的類型
            WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { (records) in
                // 安全型別判斷
                if let deletCookiesSelf = self {
                    // 判斷 cookies 是否有緩存資料
                    if(0 != deletCookiesSelf.cookieDictionaryArray.count) {
                        records.forEach({ (record) in
//                            // 安全型別判斷
//                            if let domain = domain {
//                                // displayName: webView data 紀錄名稱，通常是網域名稱
//                                if(true == record.displayName.contains(domain)) {
//
//                                }
//
//                            }
                            // 主要為將刪除 cookies 帶出，是否刪除成功，設置為逃逸閉包，方便多次呼叫
                            deleteCompletion(record, true)
                            
                        })
                        
                    }else {
                        // 主要為將刪除 cookies 帶出，是否刪除成功，設置為逃逸閉包，方便多次呼叫
                        deleteCompletion(nil, false)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
//    func libraryPathForCookies() {
//        var libraryPath : String = FileManager().urls(for: .libraryDirectory, in: .userDomainMask).first!.path
//
//        libraryPath += "/Cookies"
//
//        do {
//            try FileManager.default.removeItem(atPath: libraryPath)
//
//        } catch {
//            print("error")
//
//        }
//
//        URLCache.shared.removeAllCachedResponses()
//
//    }
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
    func webViewJsonEncoder() -> Void {
        
    }
    
}

//extension WKWebViewConfiguration {
//
//    func add(script: WKUserScript.Defined, scriptMessageHandler: WKScriptMessageHandler) {
//        userContentController.addUserScript(script.create())
//
//        userContentController.add(scriptMessageHandler, name: script.name)
//
//    }
//
//}


