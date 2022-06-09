//
//  CheckItemTableViewCell.swift
//  CheckApp
//
//  Created by 河野 裕門 on 2022/06/03.
//

import UIKit

class CheckItemTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mediaTypeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.text = "玄関"
        mediaTypeLabel.text = "画像"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
