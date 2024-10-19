//
//  ProductListPageViewModel.swift
//  FinalProject
//
//  Created by Tunay Biçer on 12.10.2024.
//

import Foundation
import UIKit
import RxSwift

class ProductListPageViewModel {
    var filteredProductList = BehaviorSubject<[Product]>(value: [Product]())
    
    let productRepository = ProductRepository()
    let cartRepository = CartRepository()
    
    func fetchCategoryProducts(category: ProductCategory) {
        productRepository.fetchCategoryProducts(for: category)
            
        _ = productRepository.filteredProductList
            .subscribe(onNext: { filteredProducts in
                self.filteredProductList.onNext(filteredProducts)
            })
    }
    
    func showAlert(on viewController: UIViewController,title: String, message: String){
        ShowAlertHelper.shared.showAlert(on: viewController, title: title, message: message)
    }
    
    func addToCart(productId: Int,ad: String, resim: String, kategori: String, fiyat: Int, marka: String, siparisAdeti: Int){
        let product = CastHelper.shared.castToProductFirebase(from: Product(id: productId, ad: ad, resim: resim, kategori: kategori, fiyat: fiyat, marka: marka), siparisAdeti: siparisAdeti)
        cartRepository.updateCartAndFetchItems(product: product){}
    }
    
    func searchProduct(searchText:String){
        productRepository.searchProduct(searchText: searchText)
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
