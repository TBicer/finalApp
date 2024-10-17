//
//  FavoruiteCell.swift
//  FinalProject
//
//  Created by Tunay Biçer on 15.10.2024.
//

import UIKit

class FavoriteCell: UITableViewCell {
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productBrandLabel: UILabel!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func handleAddToFav(_ sender: UIButton) {
    }
    
    @IBAction func handleAddToCart(_ sender: Any) {
    }
    
}
