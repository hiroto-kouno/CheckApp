//
//  Button.swift
//  CheckApp
//
//  Created by 河野 裕門 on 2022/06/17.
//

import UIKit

class Button: UIButton {
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
    // ボタンの見た目をカスタマイズ
    func setAppearanceSetting() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0.5, height: 3.5)
        self.layer.shadowOpacity = 0.3
        self.layer.shadowRadius = 3.5
        self.layer.cornerRadius = 10
        self.imageView?.contentMode = .scaleAspectFit
    }
}

extension Button {
    // 押下時
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        // ボタン押下をイメージしたアニメーション
        UIView.animate(withDuration: 0.2) {
            self.backgroundColor = UIColor(red: 0.463, green: 0.816, blue: 0.988, alpha:0.6)
            self.layer.shadowOpacity = 0.15
        }
    }
    // 押下終了時
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        // ボタンを元に戻すアニメーション
        UIView.animate(withDuration: 0.2) {
            self.backgroundColor = UIColor(red: 0.427, green: 0.757, blue: 0.918, alpha: 1)
            self.layer.shadowOpacity = 0.3
        }
    }
    
}

