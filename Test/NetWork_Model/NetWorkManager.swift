//
//  NetWorkManager.swift
//  Test
//
//  Created by Apple on 2019/6/13.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation

class NetWorkManager: NetWork<ToDo> {
    // static var: 第一次執行為延後準備初始，不需要加上 lazy，能保證多線程訪問下只初始化一次，適用於 singleton，但初始化機制並不確定，只能確認 App 啟動不會直接加載，不影響記憶體使用
    static private (set) var shared: NetWorkManager?
    
    class func setAsSingleton(instance: NetWorkManager) {
        if(nil == shared) {
            shared = instance
            
        }

    }
    
}
