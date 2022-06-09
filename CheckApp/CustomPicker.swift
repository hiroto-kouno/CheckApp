//
//  CustomPicker.swift
//  CheckApp
//
//  Created by 河野 裕門 on 2022/06/08.
//

import UIKit

class CustomPicker: UIImagePickerController {
    // MARK: - Private
    let label: UILabel = UILabel()
    let uiView: UIView = UIView()
    var itemTitle: String = ""
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.label.frame = CGRect(x: 200, y: 170, width: self.view.frame.width, height: 30)
        self.label.text = "\(self.itemTitle)を撮影してください"
        self.label.textColor = .white
        self.label.center.x = self.view.center.x
        self.label.textAlignment = NSTextAlignment.center

        self.label.alpha = 1.0
        UIView.animate(withDuration: 4.0, delay: 1.0, options: [.curveEaseIn], animations: {
            self.label.alpha = 0.0
        }, completion: nil)
        
        self.cameraOverlayView = self.label
    }
    
}

