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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
