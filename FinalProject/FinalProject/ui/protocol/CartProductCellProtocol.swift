import Foundation

protocol CartProductCellProtocol {
    func didTapDeleteButton(sepetId: Int)
    func updateProductInCart(productId: Int,ad: String, resim: String, kategori: String, fiyat: Int, marka: String, siparisAdeti: Int)
}
