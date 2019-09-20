//
//  TestColorModel.swift
//  Test
//
//  Created by Apple on 2019/5/29.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

protocol NSNumber {
    // Read Only
    var _Red: CGFloat { get }
    // Read Only
    var _Green: CGFloat { get }
    // Read Only
    var _Blue: CGFloat { get }
    // Read Only
    var _Alpha: CGFloat { get }
    
}

extension Int: NSNumber {
    // 計算屬性
    var _Red: CGFloat {
        return CGFloat(self) / 255
        
    }
    // 計算屬性
    var _Green: CGFloat {
        return  CGFloat(self) / 255
        
    }
    // 計算屬性
    var _Blue: CGFloat {
        return  CGFloat(self) / 255
        
    }
    // 計算屬性
    var _Alpha: CGFloat {
        return  CGFloat(self)
        
    }
    
}
// MARK: 自定義顏色
extension UIColor {
    // 次要的初始化，主要是增加 init() 初始化
    convenience init(R: Int, G: Int, B: Int, A: CGFloat) {
        // 自定義顏色，需要使用 UIColor init() 初始化
        // 使用 convenience init()，一定要呼叫父類別的 init()
        self.init(red: R._Red, green: G._Green, blue: B._Blue, alpha: A)
        
    }
    // 深灰色
    func cusDarkGreyColor() -> UIColor {
        return UIColor(R: 43, G: 43, B: 43, A: 1)
        
    }
    // 深丈青色
    func cusDarkNavyColor() -> UIColor {
        return UIColor(R: 4, G: 13, B: 41, A: 100)
        
    }
    
}
