//
//  NetWorkManager.swift
//  Test
//
//  Created by Apple on 2019/6/13.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation

class NetWorkManager: NetWork<ToDo> {
    static private(set) var shared: NetWorkManager?
    
    class func setAsSingleton(instance: NetWorkManager) {
        if(nil == shared) {
            shared = instance
            
        }

    }
    
}
