import Foundation
import UIKit
import RxSwift

class CartPageViewModel{
    
    var cartRepository = CartRepository()
    var cartProducts = BehaviorSubject<[ProductFirebase]>(value: [ProductFirebase]())
    var cartTotal = BehaviorSubject<Int>(value: 0)
    var cargoPrice = BehaviorSubject<Int>(value: 0)
    let disposeBag = DisposeBag()
    
    init(cartRepository: CartRepository) {
        self.cartRepository = cartRepository
        
        cartRepository.loadCartItems()
        
        _ = cartRepository.cartProducts.subscribe(onNext: { cartList in
            self.cartProducts.onNext(cartList)
            self.calculateCartTotal(products: cartList)
        })
    }
    
    init() {
        
        self.cartRepository = CartRepository() // Default instance atıyoruz
        cartRepository.loadCartItems()
        
        _ = cartRepository.cartProducts.subscribe(onNext: { cartList in
            self.cartProducts.onNext(cartList)
            self.calculateCartTotal(products: cartList)
        })
    }
    
    func loadCartItems() {
        cartRepository.loadCartItems()
    }
    
    func calculateCartTotal(products: [ProductFirebase]) {
        let total = products.reduce(0) { result, product in
            return result + (product.fiyat ?? 0) * (product.siparisAdeti ?? 1)
        }
        cartTotal.onNext(total) // Toplamı güncelliyoruz
        
        if products.count != 0 {
            if total <= 6000 {
                cargoPrice.onNext(450)
            }else {
                cargoPrice.onNext(0)
            }
        }else {
            cargoPrice.onNext(450)
        }
        
    }
        
    func addToCart(productId: Int, ad: String, resim: String, kategori: String, fiyat: Int, marka: String, siparisAdeti: Int) {
        let product = CastHelper.shared.castToProductFirebase(from: Product(id: productId, ad: ad, resim: resim, kategori: kategori, fiyat: fiyat, marka: marka), siparisAdeti: siparisAdeti)
        cartRepository.updateCartAndFetchItems(product: product) { [weak self] in
            guard let self = self else { return }
            self.loadCartItems()
        }
    }

    
    func showDeleteAlert(on viewController: UIViewController, title: String, message: String, yesAction: @escaping () -> Void){
        ShowAlertHelper.shared.showDeleteAlert(on: viewController, title: title, message: message, yesAction: yesAction)
    }
    
    func deleteProductFromCart(sepetId:Int){
        cartRepository.removeProductFromFirebase(productId: sepetId) {[weak self] success in
            guard let self = self else {return}
            cartRepository.removeAllFromCartAPI(){[weak self] success in
                guard let self = self else {return}
                cartRepository.addFetchedItemsToCart {[weak self] success in
                    guard let self = self else {return}
                    loadCartItems()
                }
            }
        }
    }
    
    func deleteAllProductsFromCart(){
        cartRepository.clearCartForFirebase {[weak self] success in
            guard let self = self else {return}
            cartRepository.removeAllFromCartAPI(){[weak self] success in
                guard let self = self else {return}
                loadCartItems()
            }
        }
    }
    

}
