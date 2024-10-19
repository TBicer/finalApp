import Foundation

struct Constants {
    public static let shared = Constants()
    
    private init(){}
    
    public let addToCartURL = "http://kasimadalan.pe.hu/urunler/sepeteUrunEkle.php"
    public let fetchCartItemsURL = "http://kasimadalan.pe.hu/urunler/sepettekiUrunleriGetir.php"
    public let fetchProductsURL = "http://kasimadalan.pe.hu/urunler/tumUrunleriGetir.php"
    public let deleteFromCartURL = "http://kasimadalan.pe.hu/urunler/sepettenUrunSil.php"
    public let imagePathURL = "http://kasimadalan.pe.hu/urunler/resimler/"
}
