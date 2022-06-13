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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // セルを枠線で囲む
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.black.cgColor
    }
    

}
