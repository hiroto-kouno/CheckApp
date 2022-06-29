//
//  CameraLabel.swift
//  CheckApp
//
//  Created by 河野 裕門 on 2022/06/29.
//

import UIKit

class CameraLabel: UILabel {

    // MARK: - init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setAppearanceSetting()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearanceSetting()
    }
    // MARK: - Private method
    func setAppearanceSetting() {
        let stroke:UIColor = UIColor.black
        let foreground:UIColor = UIColor.white
        let width:CGFloat = 1.0

        let strokeTextAttributes = [
            .strokeColor : stroke,
            .foregroundColor : foreground,
            .strokeWidth : width,
            .font : UIFont.systemFont(ofSize: 20.0)
            ] as [NSAttributedString.Key : Any]
        let string = NSMutableAttributedString.init(string: "縁取り文字", attributes: strokeTextAttributes)
        self.attributedText = string
    }
}
