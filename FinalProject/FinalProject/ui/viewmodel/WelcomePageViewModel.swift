import Foundation
import UIKit
import RxSwift

class WelcomePageViewModel {
    let productRepository = ProductRepository()
    let cartRepository = CartRepository()
    var dealSliderList: BehaviorSubject<[Product]> = BehaviorSubject(value: [Product]())
    var recommendList = BehaviorSubject<[Product]>(value: [])
    
    init() {
        // İlk olarak rastgele ürünleri ayarla
        setRandomDeals()
        setRecommendList()
    }
    
    func setRandomDeals() {
       productRepository.setRandomDeals(count: 5) { [weak self] randomDeals in
           // self ile dealSliderList'i güncelle
           self?.dealSliderList.onNext(randomDeals)
       }
    }
    
    func setRecommendList() {
       productRepository.setRandomDeals(count: 8) { [weak self] randomDeals in
           // self ile dealSliderList'i güncelle
           self?.recommendList.onNext(randomDeals)
       }
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
