//
//  AlertViewManager.swift
//  Test
//
//  Created by Apple Developer on 2019/9/23.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class AlertViewManager {
    // 自定義 closure { }，主要將 UIAlertAction handler 參數，由於會有不同提醒視窗結果，所以必須帶到入其他頁面使用，設置為逃逸閉包，方便多次呼叫
    typealias AlertViewHandler = (UIAlertAction) -> Void
    // 創造 AlertController
    static func alertView(_ alertTitle: String, _ alertMessage: String, _ AlertCompletion: @escaping AlertViewHandler) {
        // 通過 UIApplication.shared 取得這個單例物件
        let alertAppDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let alertController: UIAlertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        let alertActionOK: UIAlertAction = UIAlertAction(title: "確認", style: .default, handler: AlertCompletion)
        
        let alertActionCancel: UIAlertAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        if("提醒" == alertTitle) {
            
            alertController.addAction(alertActionOK)
            
            alertController.addAction(alertActionCancel)
            
        }else {
            alertController.addAction(alertActionOK)
            
        }
        // 安全型別判斷
        if let alertView: UIViewController = alertAppDelegate.window?.rootViewController {
            
            alertView.view.layoutIfNeeded()
            
            alertView.present(alertController, animated: true, completion: nil)
            
        }
        
    }
    
}

