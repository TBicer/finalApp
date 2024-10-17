//
//  FavoritePageViewModel.swift
//  FinalProject
//
//  Created by Tunay Biçer on 15.10.2024.
//

import Foundation

class FavoritesPageViewModel {
    let productRepository = ProductRepository()
    
    func addToFavList(product:Product){
        productRepository.addToFavList(product: product)
    }
}
