//
//  DevicesViewControllerCell.swift
//  Demo2
//
//  Created by Raysharp666 on 2020/12/10.
//

import UIKit

class DevicesViewControllerCell: UITableViewCell {

    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var port: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
