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
    @IBOutlet weak var favButton: UIButton!
    
    var product:Product?
    var productCellProtocol:ProductCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(isFavorite: Bool) {
        ButtonImageConfigurator.shared.configureHeartButton(favButton, isFavorite: isFavorite)
    }
    
    @IBAction func handleAddToFav(_ sender: Any) {
        if let id = product?.id {
            productCellProtocol?.updateFavoriteList(productId: id)
        }
    }
    
    @IBAction func handleAddToCart(_ sender: Any) {
        if let p = product {
            productCellProtocol?.didTapAddToCart(id:p.id! ,ad: p.ad!, resim: p.resim!, kategori: p.kategori!, fiyat: p.fiyat!, marka: p.marka!)
        }
    }
    
}
