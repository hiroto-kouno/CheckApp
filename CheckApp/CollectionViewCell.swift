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
        // セルのデザイン
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = false
        self.shadowView.layer.cornerRadius = 15
        self.shadowView.layer.shadowColor = UIColor.black.cgColor
        self.shadowView.layer.shadowOffset = CGSize(width: 0.5, height: 3.5)
        self.shadowView.layer.shadowOpacity = 0.3
        self.shadowView.layer.shadowRadius = 3.5
        // サムネイルのデザイン
        self.thumbnail.layer.cornerRadius = 7
        self.thumbnail.clipsToBounds = true
    }
}
