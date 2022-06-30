//
//  CameraLabel.swift
//  CheckApp
//
//  Created by 河野 裕門 on 2022/06/30.
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
    // 文字をカスタマイズ
    func setAppearanceSetting() {
        self.font = UIFont.systemFont(ofSize: 20)
        self.textColor = .white
        self.textAlignment = NSTextAlignment.center
    }

}
