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
    
    func fetchCategoryProducts(category: ProductCategory) {
        productRepository.fetchCategoryProducts(for: category)
            
        _ = productRepository.filteredProductList
            .subscribe(onNext: { filteredProducts in
                self.filteredProductList.onNext(filteredProducts)
            })
    }
    
    func fetchImage(imageUrl:String, imageName:String, imageView:UIImageView){
        productRepository.fetchImage(imageUrl: imageUrl, imageName: imageName, imageView: imageView)
    }
    
    func addToCart(ad: String, resim: String, kategori: String, fiyat: Int, marka: String, siparisAdeti: Int){
        productRepository.addToCart(ad: ad, resim: resim, kategori: kategori, fiyat: fiyat, marka: marka, siparisAdeti: siparisAdeti)
    }
    
    func formatCurrency(value: Int) -> String {
        return productRepository.formatCurrency(value: value)
    }
    
    func searchProduct(searchText:String){
        productRepository.searchProduct(searchText: searchText)
    }
    
    
}
