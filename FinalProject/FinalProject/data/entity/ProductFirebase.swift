import Foundation

struct ProductFirebase : Codable {
    var productId: Int?
    var ad: String?
    var resim: String?
    var kategori: String?
    var fiyat: Int?
    var marka: String?
    var siparisAdeti: Int?
    var kullaniciAdi: String?
    
    init(productId: Int, ad: String, resim: String, kategori: String, fiyat: Int, marka: String, siparisAdeti: Int, kullaniciAdi: String) {
        self.productId = productId
        self.ad = ad
        self.resim = resim
        self.kategori = kategori
        self.fiyat = fiyat
        self.marka = marka
        self.siparisAdeti = siparisAdeti
        self.kullaniciAdi = kullaniciAdi
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "productID": productId,
            "fiyat": fiyat,
            "siparisAdeti": siparisAdeti,
            "marka": marka,
            "ad": ad,
            "resim": resim
        ]
    }
}
