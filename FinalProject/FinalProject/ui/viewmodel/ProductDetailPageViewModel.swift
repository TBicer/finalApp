//
//  ProductDetailViewModel.swift
//  FinalProject
//
//  Created by Tunay Biçer on 13.10.2024.
//

import Foundation
import UIKit

class ProductDetailPageViewModel {
    let productRepository = ProductRepository()
    let cartRepository = CartRepository()
    
    func showAlert(on viewController: UIViewController,title: String, message: String){
        ShowAlertHelper.shared.showAlert(on: viewController, title: title, message: message)
    }
    
    func addToCart(productId: Int,ad: String, resim: String, kategori: String, fiyat: Int, marka: String, siparisAdeti: Int){
        let product = CastHelper.shared.castToProductFirebase(from: Product(id: productId, ad: ad, resim: resim, kategori: kategori, fiyat: fiyat, marka: marka), siparisAdeti: siparisAdeti)
        cartRepository.updateCartAndFetchItems(product: product){}
    }
    
    func updateFavoriteList(productId: Int, completion: @escaping (Bool) -> Void) {
        productRepository.updateFavoriteList(productId: productId) { success in
            completion(success)
        }
    }
    
    func checkIfFavorite(productId: Int, completion: @escaping (Bool) -> Void){
        productRepository.checkIfFavorite(productId: productId, completion: completion)
    }
}
