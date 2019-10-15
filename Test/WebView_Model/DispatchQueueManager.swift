//
//  DispatchQueueManager.swift
//  Test
//
//  Created by Apple Developer on 2019/9/16.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
// GCD 佇列優先權順序
public enum DisPatchLevel {
    case main
    
    case userInteractive
    
    case userInitiated
    
    case utility
    
    case background
    // 選擇佇列優先權順序，提供一個適合的 qos 值在佇列初始化，預設為 .default
    // .main: 使用主執行緒進行操作
    // .global(): 使用全局隊列進行操作，為子執行緒
    // DispatchQoS.QoSClass: 任務的重要性及優先順序的資訊，為一個包含特定情境 enum
    var dispatchQueue: DispatchQueue {
        // 任何情況下，都必須根據本身需求提供佇列執行的優先權順序及其他需要的資訊(例如在 CPU 上的執行時間)給系統，任務最終都會執行完成，差別在任務完成的優先時間
        switch self {
        case .main:
            return DispatchQueue.main
        // 隊列優先權順序最高
        case .userInteractive:
            return DispatchQueue.global(qos: .userInteractive)
            
        case .userInitiated:
            return DispatchQueue.global(qos: .userInitiated)
            
        case .utility:
            return DispatchQueue.global(qos: .utility)
        // 隊列優先權順序最低
        case .background:
            return DispatchQueue.global(qos: .background)
            
        }
        
    }
    
}

extension DispatchQueue {
    // 利用陣列字串比對，保證線程不被其他影響
    static private var onceTracker = [String]()
    // 設置延遲讀取時間畫面
    // class func: 指定類別方法，可以被子類別重寫
    class func disPatchDelayTime(_ second: Double, _ dispatchLevel: DisPatchLevel, _ delayTimeHandler: @escaping () -> Void) -> Void {
        // 執行緒需要的延遲時間
        // DispatchTime.now(): 取得當前執行緒時間
        let delayTime: DispatchTime = DispatchTime.now() + second
        // 延遲提交需要執行的工作
        // execute: 提交需要執行工作
        dispatchLevel.dispatchQueue.asyncAfter(deadline: delayTime, execute: delayTimeHandler)
   
    }
    // 設置線程只進行一次
    class func once(_ token: String,_ lock: AnyObject ,_ block: () -> Void) {
        // 將需要執行的物件上鎖，不被其他線程影響
        // objc_sync_enter(object) 會在 object 上開啟同步，直到 objc_sync_exit(object) 結束同步，為成隊出現，程式碼執行在這範圍之間時，object 不會被其他線程影響，可以直接傳入 self，但會鎖住整個
        // 鎖/互斥鎖: 鎖(lock) 與 互斥鎖(mutex) 是一種結構，保證執行範圍內的程式碼在同一時刻只有一個線程執行，防止兩條線程同時對一個可變數據結構進行讀寫機制，通常被用來保證多線程訪問同一個可變數據結構時，數據的一致性
        // object 為 Any 類型，可以帶入 self，多線程訪問同一個可變數據結構，必須使用同一把鎖能鎖住
        objc_sync_enter(lock)
        
        print("正在被鎖住")
        // 當前執行方法執行完畢前，將物件解鎖
        // defer: defer 的 block 會在當前程式碼執行退出時，方法 return 前被調用這之間，執行裡面的程式碼，提供了延遲調用的方式，適合來釋放資源或者銷毀，閉包裡不會持有值，需要透過傳參考來複製，在離開方法前，才開始執行
        defer {
            objc_sync_exit(lock)
            
        }
        // token 可能會有不同線程操作的名稱，為一個標示符
        guard true != onceTracker.contains(token) else {
            return
            
        }
        // 執行一個空的閉包，無回傳值
        block()
        
    }
    
}
