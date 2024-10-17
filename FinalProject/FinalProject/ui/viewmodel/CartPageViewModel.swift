import Foundation
import UIKit
import RxSwift

class CartPageViewModel{
    var productRepository = ProductRepository()
    var cartProducts = BehaviorSubject<[CartItem]>(value: [CartItem]())
    var cartTotal = BehaviorSubject<Int>(value: 0)
    var cargoPrice = BehaviorSubject<Int>(value: 0)
    
    func fetchCartProducts(){
        productRepository.fetchCartProducts() {}
        
        _ = productRepository.cartProducts
            .subscribe(onNext: { cartProducts in
                self.cartProducts.onNext(cartProducts)
                self.calculateCartTotal(products: cartProducts)
            })
    }
    
    func formatCurrency(value: Int) -> String {
        return productRepository.formatCurrency(value: value)
    }
    
    func calculateCartTotal(products: [CartItem]) {
        let total = products.reduce(0) { result, product in
            return result + (product.fiyat ?? 0) * (product.siparisAdeti ?? 1)
        }
        cartTotal.onNext(total) // Toplamı güncelliyoruz
        
        if products.count != 0 {
            if total <= 3000 {
                cargoPrice.onNext(450)
            }else {
                cargoPrice.onNext(0)
            }
        }else {
            cargoPrice.onNext(0)
        }
        
    }
    
    
    func fetchImage(imageUrl:String, imageName:String, imageView:UIImageView){
        productRepository.fetchImage(imageUrl: imageUrl, imageName: imageName, imageView: imageView)
    }
    
    func updateProductInCart(ad: String, resim: String, kategori: String, fiyat: Int, marka: String, siparisAdeti: Int) {
        productRepository.updateProductInCart(ad: ad, resim: resim, kategori: kategori, fiyat: fiyat, marka: marka, siparisAdeti: siparisAdeti)
    }
    
    func deleteProductFromCart(sepetId:Int){
        productRepository.deleteProductFromCart(sepetId: sepetId)
        fetchCartProducts()
    }
    
    func deleteAllProductsFromCart(){
        productRepository.deleteAllProductsFromCart(){
            self.fetchCartProducts()
        }
    }
    

}
