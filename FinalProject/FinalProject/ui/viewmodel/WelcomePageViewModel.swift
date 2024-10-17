import Foundation
import UIKit
import RxSwift

class WelcomePageViewModel {
    let productRepository = ProductRepository()
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
    
    func addToCart(ad: String, resim: String, kategori: String, fiyat: Int, marka: String, siparisAdeti: Int){
        productRepository.addToCart(ad: ad, resim: resim, kategori: kategori, fiyat: fiyat, marka: marka, siparisAdeti: siparisAdeti)
    }
    
    func fetchImage(imageUrl:String, imageName:String, imageView:UIImageView){
        productRepository.fetchImage(imageUrl: imageUrl, imageName: imageName, imageView: imageView)
    }
    
    func formatCurrency(value: Int) -> String {
        return productRepository.formatCurrency(value: value)
    }
}
