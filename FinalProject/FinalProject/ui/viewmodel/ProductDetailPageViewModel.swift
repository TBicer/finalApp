//
//  ProductDetailViewModel.swift
//  FinalProject
//
//  Created by Tunay Biçer on 13.10.2024.
//

import Foundation
import UIKit

class ProductDetailPageViewModel {
    var productRepository = ProductRepository()
    
    func addToCart(ad: String, resim: String, kategori: String, fiyat: Int, marka: String, siparisAdeti: Int) {
        productRepository.addToCart(ad: ad, resim: resim, kategori: kategori, fiyat: fiyat, marka: marka, siparisAdeti: siparisAdeti)
    }
    
    func fetchImage(imageUrl:String, imageName:String, imageView:UIImageView){
        productRepository.fetchImage(imageUrl: imageUrl, imageName: imageName, imageView: imageView)
    }
    
    func formatCurrency(value: Int) -> String {
        return productRepository.formatCurrency(value: value)
    }
}
