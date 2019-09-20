//
//  AppDelegate.swift
//  Test
//
//  Created by Apple on 2019/5/15.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    // 為一個空白的畫面，上面沒有任何內容，類似 iphone 輔助按鈕停留的畫面
    // UIWindow 主要包含了 App 所有畫面內容、事件處理、結合 viewcontroller 處理螢幕方向變化時的情況
    var window: UIWindow?
    // Read Only
    // DispatchWorkItem: 為一個代碼區塊，可以在任何佇列上被調用，裡面程式碼可以在子執行緒或在主執行緒執行，主要將工作概念封裝，幫助 DispatchQueue 來執行佇列上任務
    private(set) var delayLaunchScreenTimeWorkItem: DispatchWorkItem? = {
       return DispatchWorkItem.init(block: {})
        
    }()
    // 延後準備初始，創造 loading 大小及位置
    // stored property 建立屬性時，一定會確保屬性的每一個 stored property 都已完成初始(property 有內容或是設為 optional)，但有些屬性可能需要花費時間才能完成初始，為了加快建立屬性時間，可以添加 lazy 方法，當其他屬性在建立時，可以延後創造，等屬性建立後，需要讀取屬性時，再做初始
    // 非 static var 的 lazy，是不能保證多線程訪問下只初始化一次
    // 使用 lazy 規則:
    // 1. let 宣告屬性不能加上 lazy: let 會產生不能改變的常數，所以不可能滿足 lazy 後來才改變屬性內容的需求
    // 2. computed property 不能加上 lazy: computed property 在讀取時才計算生成屬性，早就已實現 lazy 後來再建立物件目的
    // 3. lazy 屬性一定要在宣告時，指定初始值
    lazy var loadingView: ActivityIndicatorView = {
        let setupLoadingViewFrame = ActivityIndicatorView(frame: .zero, midFrameX: UIScreen.main.bounds.midX, midFrameY: UIScreen.main.bounds.midY)
        
        return setupLoadingViewFrame
        
    }()
    // application 第一次進入 app 時出現
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 打開 app 時，會出現 LaunchScreenImage，主要是讓 app Logo 畫面顯示延遲，由於並不是使用 LaunchScreen 上的 imageView 來加入圖片，畫面顯示並不是在 LaunchScreen 上，會造成進入 AppDelegate 前消失，使用控制 MainThread 方式，讓 MainThread 暫時睡著，缺點會影響線程主塞，不建議使用此方式
        Thread.sleep(forTimeInterval: 0.5)
        // window 視窗大小為 iPhone 螢幕尺寸大小，初始化 window
        self.window = UIWindow(frame: UIScreen.main.bounds)
        // 加載 storyboard 文件，使用 UIStoryboard 初始化頁面
        // instantiateInitialViewController(): 加載 storyboard 上的頁面
        self.window?.rootViewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        // 顯示 window
        self.window?.makeKeyAndVisible()
        // 創造 loadingView
        // 需安全型別判斷
        if let addLoadingView = loadingView.setupLoadingView() {
            // loadingView 添加到 window 上 rootViewController
            self.window?.rootViewController?.view.addSubview(addLoadingView)
            
        }
        // 將需要執行工作封裝，方便在任何佇列上被調用
        delayLaunchScreenTimeWorkItem = DispatchWorkItem { [weak self] in
            // 安全型別判斷
            if let ADSelf = self {
                // 設置延遲讀取時間畫面，因為是進行 UI 更新，需要在主執行緒執行
                DispatchQueue.disPatchDelayTime(2.5, .main) {
                    // 設置線程只進行一次
                    DispatchQueue.once("com.apple.LaunchScreen", ADSelf, {
                        
                        ADSelf.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
                        
                    })
                    
                }
                
            }
            
            
        }
        // 佇列上，提交需要執行工作，為子執行緒的異步執行，結束後，會立即返回，不會有執行緒卡住問題
        // execute: 提交需要執行工作
        DispatchQueue.global().async(execute: delayLaunchScreenTimeWorkItem!)
        // Override point for customization after application launch.
        let netWorkManager: NetWorkManager = NetWorkManager(netWorkURL: URL(string: "https://ifixit.tw/")!)
        
        NetWorkManager.setAsSingleton(instance: netWorkManager)
        // 取消 delayLaunchScreenTimeWorkItem 任務
        delayLaunchScreenTimeWorkItem?.cancel()
        
        return true
        
    }
    // applicationWillResignActive 當 app 浮起來準備進入背景時出現
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    // applicationDidEnterBackground 程式已經完全進入背景時出現
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    // applicationWillEnterForeground 當程式由背景狀態重新回到 app 前景時出現
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    // applicationDidBecomeActive 剛開啟 app 時出現
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    // applicationWillTerminate 將程式完全關閉結束時出現
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

