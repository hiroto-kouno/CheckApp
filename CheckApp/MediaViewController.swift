//
//  MediaViewController.swift
//  CheckApp
//
//  Created by 河野 裕門 on 2022/06/10.
//

import UIKit

class MediaViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Private
    var path: String = ""
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let imagePath = documentsDirectoryUrl.appendingPathComponent(path+".jpg").path
        
        self.imageView.image = UIImage(contentsOfFile: imagePath)
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
