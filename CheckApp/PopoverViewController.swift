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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        
        self.imageView.image = UIImage(named: "travel")
        // Do any additional setup after loading the view.
    }
    

}
