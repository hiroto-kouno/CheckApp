//
//  CameraView.swift
//  CheckApp
//
//  Created by 河野 裕門 on 2022/06/30.
//

import UIKit

class CameraView: UIView {

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
    // Viewの見た目をカスタマイズ
    func setAppearanceSetting() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 15
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
    }

}
