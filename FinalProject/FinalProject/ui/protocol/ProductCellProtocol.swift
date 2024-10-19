import Foundation

protocol ProductCellProtocol {
    func didTapAddToCart(id:Int ,ad: String, resim: String, kategori: String, fiyat: Int, marka: String)
    func updateFavoriteList(productId: Int)
}
