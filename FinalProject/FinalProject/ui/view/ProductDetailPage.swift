//
//  ProductDetailPage.swift
//  FinalProject
//
//  Created by Tunay Biçer on 9.10.2024.
//

import UIKit

class ProductDetailPage: UIViewController {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productBrandLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productQuantityLabel: UILabel!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    
    var viewModel = ProductDetailPageViewModel()
    var product:Product?
    var quantity : Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let p = product {
            let formattedTotal = self.viewModel.formatCurrency(value: p.fiyat!)
            
            viewModel.fetchImage(imageUrl: "http://kasimadalan.pe.hu/urunler/resimler/", imageName: p.resim!, imageView: productImageView)
            productBrandLabel.text = p.marka
            productTitleLabel.text = p.ad
            productPriceLabel.text = formattedTotal
            productQuantityLabel.text = String(quantity)
        }
    }

    @IBAction func addToFav(_ sender: Any) {
    }
    
    
    @IBAction func handleQuantity(_ sender: UIButton) {
        switch sender.tag {
        case -1: // Eksi butonu
            if quantity > 1 {
                quantity -= 1
            }
            productQuantityLabel.text = String(quantity)
            updateMinusButtonAppearance()
            
        case 1: // Artı butonu
            quantity += 1
            productQuantityLabel.text = String(quantity)
            updateMinusButtonAppearance()
            
        default:
            print("Bilinmeyen butona tıklandı")
        }
    }

    func updateMinusButtonAppearance() {
        if quantity == 0 {
            minusButton.isEnabled = false
        } else if quantity == 1 {
            minusButton.backgroundColor = UIColor(named: "BGSecondary")
            minusButton.setTitleColor(UIColor(named: "ContentDisabled"), for: .normal)
        } else {
            minusButton.backgroundColor = UIColor(named: "BGAccent")
            minusButton.setTitleColor(UIColor(named: "ContentOnColorInverse"), for: .normal)
        }
    }
    
    
    @IBAction func addToCart(_ sender: Any) {
        if let p = product {
            viewModel.addToCart(ad: p.ad!, resim: p.resim!, kategori: p.kategori!, fiyat: p.fiyat!, marka: p.marka!, siparisAdeti: quantity)
        }
    }
}
