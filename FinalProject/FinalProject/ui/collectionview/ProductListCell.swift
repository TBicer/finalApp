//
//  ProductListCell.swift
//  FinalProject
//
//  Created by Tunay Biçer on 12.10.2024.
//

import UIKit

class ProductListCell: UICollectionViewCell {
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productBrandLabel: UILabel!
    
    var product:Product?
    var productCellProtocol:ProductCellProtocol?
    
    func configureCell(isFavorite: Bool) {
        ButtonImageConfigurator.shared.configureHeartButton(favButton, isFavorite: isFavorite)
    }
    
    @IBAction func addToCart(_ sender: Any) {
        if let p = product {
            productCellProtocol?.didTapAddToCart(id:p.id!, ad: p.ad!, resim: p.resim!, kategori: p.kategori!, fiyat: p.fiyat!, marka: p.marka!)
        }
    }
    
    @IBAction func addToFav(_ sender: Any) {
        if let id = product?.id {
            productCellProtocol?.updateFavoriteList(productId: id)
        }
    }
    
}
