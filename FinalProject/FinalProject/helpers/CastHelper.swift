import Foundation

class CastHelper {
    
    public static let shared = CastHelper()
    
    private init(){}
    
    // Product'tan ProductFirebase'e dönüşüm
    public func castToProductFirebase(from product: Product, siparisAdeti: Int?) -> ProductFirebase {
        if let productId = product.id,
           let ad = product.ad,
           let resim = product.resim,
           let kategori = product.kategori,
           let fiyat = product.fiyat,
           let marka = product.marka,
           let siparisAdeti = siparisAdeti {
            return ProductFirebase(productId: productId, ad: ad, resim: resim, kategori: kategori, fiyat: fiyat, marka: marka, siparisAdeti: siparisAdeti, kullaniciAdi: "tbicer")
        }
        return ProductFirebase(productId: 0, ad: "", resim: "", kategori: "", fiyat: 0, marka: "", siparisAdeti: 0, kullaniciAdi: "tbicer")
    }
    
}
