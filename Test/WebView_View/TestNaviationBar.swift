//
//  TestNaviationBar.swift
//  Test
//
//  Created by Apple on 2019/5/21.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class TestNaviationBar: UINavigationBar {
    // Read Only
    private (set) var navBarImageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        testNavBarFrame()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        testNavBarFrame()
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        testNavBarFrame()
        
    }
    
    func testNavBarFrame() -> Void {
        
        let visualEffectView: UIVisualEffectView = UIVisualEffectView(frame: self.navBarImageView.frame)
        // visualEffectView.contentView 背景顏色為深丈青色
        visualEffectView.contentView.backgroundColor = UIColor().cusDarkGreyColor()
        
        self.addSubview(visualEffectView)
        
    }
    
}
