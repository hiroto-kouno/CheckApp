//
//  PopoverViewController.swift
//  CheckApp
//
//  Created by 河野 裕門 on 2022/06/09.
//

import UIKit

class PopoverViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var okButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // 背景色の透化
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        // 外出のイメージ画像
        self.imageView.image = UIImage(named: "travel")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor(red: 0.216, green: 0.482, blue: 0.886, alpha: 1)
        // 完了のイメージ画像
        self.checkImageView.image = UIImage(named: "check")
    }
    
    // MARK: - IBAction
    // ボタンを押したときに呼ばれるメソッド
    @IBAction func handleShowMediaButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
