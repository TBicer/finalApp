import Foundation
import RxSwift

class FavoritesPageViewModel {
    let productRepository : ProductRepository
    let cartRepository = CartRepository()
    
    var favoriteList = BehaviorSubject<[Product]>(value: [])
    
    init(productRepository: ProductRepository) {
        self.productRepository = productRepository
        
        productRepository.fetchFavoriteProducts()
        
        _ = productRepository.favoriteList.subscribe(onNext: { favList in
            self.favoriteList.onNext(favList)
        })
    }
    
    init() {
        
        self.productRepository = ProductRepository() // Default instance atıyoruz
        productRepository.fetchFavoriteProducts()
        
        _ = productRepository.favoriteList.subscribe(onNext: { favList in
            self.favoriteList.onNext(favList)
        })
    }

    func fetchFavoriteProducts() {
        productRepository.fetchFavoriteProducts()
    }
    
    func checkIfFavorite(productId: Int, completion: @escaping (Bool) -> Void){
        productRepository.checkIfFavorite(productId: productId, completion: completion)
    }
    
    func updateFavoriteList(productId: Int, completion: @escaping (Bool) -> Void) {
        productRepository.updateFavoriteList(productId: productId) { success in
            completion(success)
            self.fetchFavoriteProducts()
        }
    }
    
    func addToCart(productId: Int,ad: String, resim: String, kategori: String, fiyat: Int, marka: String, siparisAdeti: Int){
        let product = CastHelper.shared.castToProductFirebase(from: Product(id: productId, ad: ad, resim: resim, kategori: kategori, fiyat: fiyat, marka: marka), siparisAdeti: siparisAdeti)
        cartRepository.updateCartAndFetchItems(product: product){}
    }
}
