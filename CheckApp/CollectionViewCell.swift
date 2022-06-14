//
//  CollectionViewCell.swift
//  CheckApp
//
//  Created by 河野 裕門 on 2022/06/09.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlet
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var shadowView: UIView!
    
    
    // MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        // セルを枠線で囲む
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = false
        shadowView.layer.cornerRadius = 15
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0.5, height: 3.5)
        shadowView.layer.shadowOpacity = 0.3
        shadowView.layer.shadowRadius = 3.5
    }
    

}
