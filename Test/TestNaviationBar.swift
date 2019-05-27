//
//  TestNaviationBar.swift
//  Test
//
//  Created by Apple on 2019/5/21.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class TestNaviationBar: UINavigationBar {
    let navBarImageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 414, height: 44))

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
    
    func testNavBarFrame() {
        
        let visualEffectView = UIVisualEffectView(frame: self.navBarImageView.frame)
        
        visualEffectView.contentView.backgroundColor = UIColor().cusDarkGreyColor()
        
        self.addSubview(visualEffectView)
        
    }
    
}
