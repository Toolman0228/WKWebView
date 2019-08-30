//
//  ActivityIndicatorView.swift
//  Test
//
//  Created by Apple on 2019/8/14.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

// GCD 佇列優先權順序
enum DisPatchLevel {
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

class ActivityIndicatorView: UIView {
    // Read Only
    // 計算 loaidngView 寬度
    // floor: 返回不大於參數的最大整數，帶入參數型別為 Double
    private (set) var calLoadingViewWidth: CGFloat = CGFloat(floor(Double(UIScreen.main.bounds.width / 4)))
    // Read Only
    // 計算 loadingView 高度
    // roundf: 返回四捨五入後的整數，帶入參數型別為 Float
    private (set) var calLoadingViewHeight: CGFloat = CGFloat(roundf(Float(UIScreen.main.bounds.height / 8)))
    // 載入時，讀取名稱
    var cusIndicatorLabel: UILabel?
    // 載入時，讀取畫面
    var cusIndicatorView: UIActivityIndicatorView?
    // 載入時，讀取畫面上模糊視覺效果
    var cusIndicatorEffectView: UIVisualEffectView?
    // 載入時，讀取畫面 X 座標位置
    var midFrameX: CGFloat?
    // 載入時，讀取畫面 Y 座標位置
    var midFrameY: CGFloat?
    // 初始化
    init(frame: CGRect,
         midFrameX: CGFloat,
         midFrameY: CGFloat) {
        self.cusIndicatorLabel = UILabel()
        
        self.cusIndicatorView = UIActivityIndicatorView()
        
        self.cusIndicatorEffectView = UIVisualEffectView()
        
        self.midFrameX = midFrameX
        
        self.midFrameY = midFrameY
        
        super.init(frame: frame)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
        
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    // 自定義 Tuple，主要為回傳 loadingView 計算好的座標位置
    // Tuple(元組): 類似一個簡單、匿名結構(struct)，屬於傳參數(value type)，不需要正式定義，方便使用、丟棄，可以透過元組作為 function 回傳多個參數時使用
    typealias LoadingViewPosition = (frameX: CGFloat, frameY: CGFloat)
    // 計算 loadingView 座標位置
    // function 回傳為空時，是一個空的 Tuple，對應 Swift 語法資料型別為 Void，也是預設
    internal func calculateLoadingViewPosition() -> LoadingViewPosition {
        // midFrameX 安全型別判斷
        guard let loadingViewMidFrameX = midFrameX else {
            return (0.0, 0.0)
            
        }
        // midFrameY 安全型別判斷
        guard let loadingViewMidFrameY = midFrameY else {
            return (0.0, 0.0)
            
        }
        // 計算 loadingView X 座標位置
        // 取得畫面上 X 座標中心值，首先計算完 loadingView width 後，再除於 2，得到 loadingView 目前本身 X 座標中心值離原本畫面上 X 座標中心值的距離，透過畫面上 X 座標中心值 - loadingView 中心值距離，即可計算出結果
        let calLoadingViewFrameX: CGFloat = loadingViewMidFrameX - (calLoadingViewWidth / 2)
        // 計算 loadingView Y 座標位置
        // 取得畫面上 Y 座標中心值，首先計算完 loadingView height 後，再除於 2，得到 loadingView 目前本身 Y 座標中心值離原本畫面上 Y 座標中心值的距離，透過畫面上 Y 座標中心值 - loadingView 中心值距離，即可計算出結果
        let calLoadingViewFrameY: CGFloat = loadingViewMidFrameY - (calLoadingViewHeight / 2)
        
        return (calLoadingViewFrameX, calLoadingViewFrameY)
        
    }
    // 創造 loadingView
   func setupLoadingView() -> UIView? {
        // 準備創造 CusIndicatorLabel
        guard let setupLoadingIndicatorLabel: UILabel = setupCusIndicatorLabel() else {
            return nil
            
        }
        // 準備創造 CusIndicatorView
        guard let setupLoadingIndicatorView: UIActivityIndicatorView = setupCusIndicatorView() else {
            return nil
            
        }
        // 準備創造 CusIndicatorEffectView
        guard let setupLoadingIndicatorEffectView: UIVisualEffectView = setupCusIndicatorEffectView() else {
            return nil
            
        }
        // 計算 loadingView 座標位置
        let posLoadingView = calculateLoadingViewPosition()
        // 設置 ActivityIndicatorView 大小及位置
        cusIndicatorView?.frame = CGRect(x: 0.0, y: 0.0, width: calLoadingViewWidth, height: calLoadingViewHeight)
        // 設置 VisualEffectView 大小及位置
        cusIndicatorEffectView?.frame = CGRect(x: posLoadingView.frameX, y: posLoadingView.frameY, width: calLoadingViewWidth, height: calLoadingViewHeight)
        // cusIndicatorLabel 添加到 cusIndicatorEffectView
        setupLoadingIndicatorEffectView.contentView.addSubview(setupLoadingIndicatorLabel)
        // cusIndicatorView 添加到 cusIndicatorEffectView
        setupLoadingIndicatorEffectView.contentView.addSubview(setupLoadingIndicatorView)
        
        return setupLoadingIndicatorEffectView
      
    }
    // 自定義 Tuple，主要為回傳 loadingView 上 label 計算好的座標位置
    typealias LoadingViewLabelPosition = (frameX: CGFloat,frameY: CGFloat)
    // 計算 loadingView 上 label 座標位置
    // cusIndicatorLabel 的 frameX、frameY 座標位置是對應 loadingView，並不是對應裝置本身
    // function 回傳為空時，是一個空的 Tuple，對應 Swift 語法資料型別為 Void，也是預設
    internal func calculateLoadingViewLabelPosition() -> LoadingViewLabelPosition {
        // label X 座標位置對應 loadingView 本身，利用 calLoadingViewWidth 來計算座標位置
        // roundf: 返回四捨五入後的整數，帶入參數型別為 Float
        let calLoadingViewLabelFrameX: CGFloat = CGFloat(roundf(Float(calLoadingViewWidth / 30)))
        // label Y 座標位置對應 loadingView 本身，利用 calLoadingViewHeight 來計算座標位置
        let calLoadingViewLabelFrameY: CGFloat = calLoadingViewHeight / 2
        
        return (calLoadingViewLabelFrameX, calLoadingViewLabelFrameY)
        
    }
    // 設置 cusIndicatorLabel 屬性
    internal func setupCusIndicatorLabel() -> UILabel? {
        // 移除當前視圖上的父視圖，並沒有在內存中移除，需要使用，不需再次創建，直接使用 addSubView
        // removeFromSuperview(): 取消連接視圖與父視圖，也從響應事件操作的程序中移除
        cusIndicatorLabel?.removeFromSuperview()
        // 計算 loadingView 上 label 座標位置
        let posLoadingViewLabel = calculateLoadingViewLabelPosition()
        // 計算 label Y 座標位置超出 loadingView 畫面，並減掉 loadingView 超出範圍
        let overPosLoadingViewLabelFrameY: CGFloat = calLoadingViewWidth - (posLoadingViewLabel.frameX * 2)
        // 設置 cusIndicatorLabel 大小及位置
        // cusIndicatorLabel 的 frameX、frameY 座標位置是對應 loadingView，並不是對應裝置本身
        cusIndicatorLabel = UILabel(frame: CGRect(x: posLoadingViewLabel.frameX, y: posLoadingViewLabel.frameY, width: overPosLoadingViewLabelFrameY, height: calLoadingViewHeight / 2))
        // 設置 cusIndicatorLabel 文字內容
        cusIndicatorLabel?.text = "loading..."
        // 設置 cusIndicatorLabel 文字內容位置
        cusIndicatorLabel?.textAlignment = .center
        // 設置 cusIndicatorLabel 文字粗細大小
        // UIFont.systemFont(): 系統字體大小及粗細度
        // UIFont.Weight.medium: 字體粗細度介於 regular 和 semibold 之間
        cusIndicatorLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.medium)
        // 設置 cusIndicatorLabel 顏色及透明度
        cusIndicatorLabel?.textColor = UIColor(white: 0.9, alpha: 0.7)
        
        return cusIndicatorLabel
        
    }
    // 設置 cusIndicatorView 屬性
    internal func setupCusIndicatorView() -> UIActivityIndicatorView? {
        // 移除當前視圖上的父視圖，並沒有在內存中移除，需要使用，不需再次創建，直接使用 addSubView
        // removeFromSuperview(): 取消連接視圖與父視圖，也從響應事件操作的程序中移除
        cusIndicatorView?.removeFromSuperview()
        // 設置 ActivityIndicatorView 樣式，為白色的旋轉圈
        cusIndicatorView = UIActivityIndicatorView(style: .white)
        // 讀取畫面動畫效果開始
        cusIndicatorView?.startAnimating()
        
        return cusIndicatorView
        
    }
    // 設置 cusIndicatorEffectView 屬性
    internal func setupCusIndicatorEffectView() -> UIVisualEffectView? {
        // 移除當前視圖上的父視圖，並沒有在內存中移除，需要使用，不需再次創建，直接使用 addSubView
        cusIndicatorEffectView?.removeFromSuperview()
        // 提供模糊視覺效果，
        // UIBlurEffect(): 添加於 UIVisualEffectView 背景、contentView 上，但 contentView 本身並未模糊，不會對自身這層進行模糊視覺效果
        cusIndicatorEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        // 設置 VisualEffectView 圓角效果
        // layer.cornerRadius: 圓角只對背景和圖層邊框有用，對 layer.contents 屬性中的 image 無效，如果 contents 有內容或者內容背景不透明時，單純使用 cornerRadius 是無法完成圓角效果
        cusIndicatorEffectView?.layer.cornerRadius = 15
        // 設置 VisualEffectView 裁減效果，
        // 剪裁超出父视图范围的子视图部分
        // layer.masksToBounds: 裁剪超出父視圖範圍的子視圖部分，UIView 上對應的屬性為 clipsToBounds，IB 對應的設置為 Clip Subviews 選項，masksToBounds 會裁剪 layer.contents
        cusIndicatorEffectView?.layer.masksToBounds = true
        
        return cusIndicatorEffectView
       
    }
    // 設置 loadingView 延遲讀取時間畫面
    func loadingViewDelayTime(_ second: Double, _ dispatchLevel: DisPatchLevel, _ delayTimeHandler: @escaping () -> Void) -> Void {
        // 執行緒需要的延遲時間
        // DispatchTime.now(): 取得當前執行緒時間
        let delayTime: DispatchTime = DispatchTime.now() + second
        
        dispatchLevel.dispatchQueue.asyncAfter(deadline: delayTime, execute: delayTimeHandler)
        
    }
    // 移除當前視圖上的 loadingView
    func removeLoadingView() -> Void {
        // 取得主執行緒使用，異步執行，所有 UI 元件更新，需在主執行緒執行
        DispatchQueue.main.async { [weak self] in
            if let activityIndicatorViewSelf = self {
                // 讀取畫面動畫效果停止
                activityIndicatorViewSelf.cusIndicatorView?.stopAnimating()
                // 移除當前視圖上的父視圖，並沒有在內存中移除，需要使用，不需再次創建，直接使用 addSubView
                activityIndicatorViewSelf.cusIndicatorEffectView?.removeFromSuperview()
                
                
            }
           
        }
        
    }
    
}
