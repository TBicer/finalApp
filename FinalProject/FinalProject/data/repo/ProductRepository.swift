import Foundation
import RxSwift
import UIKit
import Kingfisher
import Alamofire

class ProductRepository {
    private let disposeBag = DisposeBag()
    var productList = [Product]()
    var categoryList = BehaviorSubject<[ProductCategory]>(value: [ProductCategory]())
    var originalCategoryList: [ProductCategory] = []
    var filteredProductList = BehaviorSubject<[Product]>(value: [Product]())
    var orgFilteredProducts: [Product] = []
    var cartProducts = BehaviorSubject<[CartItem]>(value: [CartItem]())
    var dealSliderList = BehaviorSubject<[Product]>(value: [])
    var recommendList = BehaviorSubject<[Product]>(value: [])
    
    init(){
        fetchProducts()
    }
    
    func addToFavList(product:Product){
        
    }
    
    func searchCategory(searchText: String) {
        if searchText.isEmpty {
            // Arama metni boşsa orijinal kategori listesini gönder
            categoryList.onNext(originalCategoryList)
        } else {
            let filteredCategories = originalCategoryList.filter { $0.title?.lowercased().contains(searchText) == true }
            categoryList.onNext(filteredCategories)
        }
    }
    
    func searchProduct(searchText:String) {
        if searchText.isEmpty {
            filteredProductList.onNext(orgFilteredProducts)
        }else {
            let searchedProduct = orgFilteredProducts.filter { $0.ad?.lowercased().contains(searchText) == true }
            filteredProductList.onNext(searchedProduct)
        }
    }
    
    // para yazan yerleri formatlamak için fonksiyon
    func formatCurrency(value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal // Para birimi yerine sadece sayı formatı
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.maximumFractionDigits = 0 // Kuruş ayarı
        
        if let formattedValue = formatter.string(from: NSNumber(value: value)) {
            return "\(formattedValue) ₺"
        }
        
        return "\(value) ₺" // format edilmezse
    }

    
    // Kingfisher'ı her yerde kullanmak için fonksiyon
    func fetchImage(imageUrl:String, imageName:String, imageView:UIImageView){
        if let url = URL(string: "\(imageUrl)\(imageName)") {
            DispatchQueue.main.async {
                imageView.kf.setImage(with: url)
            }
        }
    }
    
    func setRandomDeals(count:Int,completion: @escaping ([Product]) -> Void) {
        let url = "http://kasimadalan.pe.hu/urunler/tumUrunleriGetir.php"
        
        AF.request(url, method: .get).response { response in
            if let data = response.data {
                do {
                    let rs = try JSONDecoder().decode(ProductResponse.self, from: data)
                    if let list = rs.urunler {
                        // Benzersiz ürünleri al
                        let uniqueProducts = self.getUniqueProducts(from: list)
                        // Rastgele 3 benzersiz ürün seç
                        let randomDeals = self.selectRandomDeals(from: uniqueProducts, count: count)
                        
                        // Geri çağırma ile randomDeals'i döndür
                        completion(randomDeals)
                    }
                } catch {
                    print("JSON Decoding Error: \(error.localizedDescription)")
                }
            } else {
                print("No data received from the response.")
            }
        }
    }
    
    private func getUniqueProducts(from products: [Product]) -> [Product] {
        var uniqueProducts: [Product] = []
        var seenProductIds = Set<Int>() // veya benzersiz bir özellik
        
        for product in products {
            if let id = product.id, !seenProductIds.contains(id) {
                seenProductIds.insert(id) // Ürünün id'sini ekle
                uniqueProducts.append(product) // Benzersiz ürünü ekle
            }
        }
        
        return uniqueProducts
    }
    
    private func selectRandomDeals(from products: [Product], count: Int) -> [Product] {
        // Yeterli ürün yoksa hepsini döndür
        guard products.count >= count else { return products }
        
        // Ürünleri karıştır ve ilk 'count' kadarını al
        return products.shuffled().prefix(count).map { $0 }
    }
     
    func fetchProducts() {
        let url = "http://kasimadalan.pe.hu/urunler/tumUrunleriGetir.php"
        
        var newCatList = Set<ProductCategory>()
        
        AF.request(url, method: .get).response { response in
            if let data = response.data {
                do {
                    let rs = try JSONDecoder().decode(ProductResponse.self, from: data)
                    if let list = rs.urunler {
                        for product in list {
                            self.productList.append(product)
                            
                            if let categoryName = product.kategori {
                                let category = ProductCategory(catId: product.id, title: categoryName)
                                newCatList.insert(category)
                            }
                        }
                        
                        let allProd = ProductCategory(catId: 0, title:"Tüm Ürünler")
                        var newArr = Array(newCatList)
                        newArr.insert(allProd, at: 0)
                        
                        DispatchQueue.main.async {
                            self.originalCategoryList = Array(newArr)
                            self.categoryList.onNext(Array(newArr))
                        }
                        
                    }
                } catch {
                    print(error.localizedDescription)
                }
            } else {
                print("No data received from the response.")
            }
        }
    }
    
    func fetchCategoryProducts(for category: ProductCategory) {
        let url = "http://kasimadalan.pe.hu/urunler/tumUrunleriGetir.php"

        AF.request(url, method: .get).response { response in
            if let data = response.data {
                do {
                    let rs = try JSONDecoder().decode(ProductResponse.self, from: data)
                    if let list = rs.urunler {
                        var filteredProductList = [Product]()
                        
                        for product in list {
                            self.productList.append(product)
                            
                            if category.title == "Tüm Ürünler" || product.kategori == category.title {
                                filteredProductList.append(product)
                            }
                        }

                        // Filtrelenmiş ürünleri BehaviorSubject'e gönderiyoruz
                        DispatchQueue.main.async {
                            self.orgFilteredProducts = filteredProductList
                            self.filteredProductList.onNext(filteredProductList)
                        }
                    }
                } catch {
                    print("Decoding error: \(error.localizedDescription)")
                }
            } else {
                print("No data received from the response.")
            }
        }
    }
    
    func fetchCartProducts(completion: @escaping () -> Void) { // Diğer fonksiyonlarımda kullandığım için bir completion parametresi koydum. Böylece diğer kodlar bu bitmeden çalışmıyor.
        let url = "http://kasimadalan.pe.hu/urunler/sepettekiUrunleriGetir.php"
        let params: Parameters = ["kullaniciAdi": "tbicer"]
        
        AF.request(url, method: .post, parameters: params).response { response in
            if let data = response.data {
                do {
                    let rs = try JSONDecoder().decode(CartResponse.self, from: data)
                    
                    if let urunler = rs.urunler_sepeti {
                        var newCartItems: [CartItem] = []
                        
                        newCartItems = urunler.compactMap { urun -> CartItem? in
                            guard let ad = urun.ad,
                                  let resim = urun.resim,
                                  let kategori = urun.kategori,
                                  let fiyat = urun.fiyat,
                                  let marka = urun.marka,
                                  let siparisAdeti = urun.siparisAdeti,
                                  let kullaniciAdi = urun.kullaniciAdi else {
                                return nil // Guard Let ile nil kontrolü yapıyoruz.
                            }
                            
                            return CartItem(
                                sepetId: urun.sepetId,
                                ad: ad,
                                resim: resim,
                                kategori: kategori,
                                fiyat: fiyat,
                                marka: marka,
                                siparisAdeti: siparisAdeti,
                                kullaniciAdi: kullaniciAdi
                            )
                        }
                        
                        newCartItems.sort(by: {$0.fiyat! > $1.fiyat!})
                        
                        // Yeni ürünleri BehaviorSubject'e yollar
                        DispatchQueue.main.async {
                            self.cartProducts.onNext(newCartItems)
                            completion() // Geri çağırmayı burada çağırıyoruz
                        }
                    }
                    
                } catch {
                    // Eğer ürün yoksa boş dizi gönder
                    DispatchQueue.main.async {
                        self.cartProducts.onNext([])
                        completion() // Geri çağırmayı burada çağırıyoruz
                    }
                }
            } else if let error = response.error {
                print("Request error: \(error.localizedDescription)")
            }
        }
    }
    
    func addToCart(ad: String, resim: String, kategori: String, fiyat: Int, marka: String, siparisAdeti: Int) {
        let url = "http://kasimadalan.pe.hu/urunler/sepeteUrunEkle.php"
        
        // Mevcut sepeti güncelle
        fetchCartProducts {
            // cartProducts güncellendikten sonra çalışacak
            self.cartProducts
                .take(1) // Sadece bir kez dinle
                .subscribe(onNext: { cartItems in
                    // Sepette ürün olup olmadığını kontrol et
                    if let existingCartItem = cartItems.first(where: { $0.ad == ad && $0.kategori == kategori }) {
                        print("Mevcut sepet ürünü bulundu: \(existingCartItem)") // Mevcut ürün
                        let newOrderAmount = (existingCartItem.siparisAdeti ?? 0) + siparisAdeti // Yeni sipariş adedini hesapla
                        
                        // Sepetteki mevcut ürünü sil
                        self.deleteProductFromCart(sepetId: existingCartItem.sepetId)
                        
                        // Güncellenmiş sipariş adedini parametreye yaz
                        let params: Parameters = [
                            "kullaniciAdi": "tbicer",
                            "ad": ad,
                            "resim": resim,
                            "kategori": kategori,
                            "fiyat": fiyat,
                            "marka": marka,
                            "siparisAdeti": newOrderAmount
                        ]
                        
                        // Yeni ürünü sepete ekle
                        AF.request(url, method: .post, parameters: params).response { response in
                            if let data = response.data {
                                do {
                                    let rs = try JSONDecoder().decode(CRUDResponse.self, from: data)
                                    if rs.success != nil {
                                        print("Ürün sepete başarıyla eklendi.")
                                        self.fetchCartProducts() {} // Sepeti tekrar güncelle
                                    } else {
                                        print("Sepete ekleme başarısız.")
                                    }
                                } catch {
                                    print("Sepete eklerken bir hata oluştu: \(error.localizedDescription)")
                                }
                            }
                        }
                    } else {
                        // Ürün sepette yoksa, direkt ekle
                        let params: Parameters = [
                            "kullaniciAdi": "tbicer",
                            "ad": ad,
                            "resim": resim,
                            "kategori": kategori,
                            "fiyat": fiyat,
                            "marka": marka,
                            "siparisAdeti": siparisAdeti
                        ]
                        
                        AF.request(url, method: .post, parameters: params).response { response in
                            if let data = response.data {
                                do {
                                    let rs = try JSONDecoder().decode(CRUDResponse.self, from: data)
                                    if rs.success != nil {
                                        print("Ürün sepete başarıyla eklendi.")
                                        self.fetchCartProducts() {} // Sepeti tekrar güncelle
                                    } else {
                                        print("Sepete ekleme başarısız.")
                                    }
                                } catch {
                                    print("Sepete eklerken bir hata oluştu: \(error.localizedDescription)")
                                }
                            }
                        }
                    }
                }).disposed(by: self.disposeBag)
        }
    }
    
    func updateProductInCart(ad: String, resim: String, kategori: String, fiyat: Int, marka: String, siparisAdeti: Int) {
        let url = "http://kasimadalan.pe.hu/urunler/sepeteUrunEkle.php"
        
        // Mevcut sepeti güncelle
        fetchCartProducts {
            // cartProducts güncellendikten sonra çalışacak
            self.cartProducts.subscribe(onNext: { cartItems in
                // Sepette ürün olup olmadığını kontrol et
                if let existingCartItem = cartItems.first(where: { $0.ad == ad && $0.kategori == kategori }) {
                    print("Mevcut sepet ürünü bulundu: \(existingCartItem)") // Mevcut ürün
                    
                    // Sepetteki mevcut ürünü sil
                    self.deleteProductFromCart(sepetId: existingCartItem.sepetId)
                    
                    // Güncellenmiş sipariş adedini parametreye yaz
                    let params: Parameters = [
                        "kullaniciAdi": "tbicer",
                        "ad": ad,
                        "resim": resim,
                        "kategori": kategori,
                        "fiyat": fiyat,
                        "marka": marka,
                        "siparisAdeti": siparisAdeti // Yeni sipariş adedini gönder
                    ]
                    
                    // Ürünü sepete ekle
                    AF.request(url, method: .post, parameters: params).response { response in
                        if let data = response.data {
                            do {
                                let rs = try JSONDecoder().decode(CRUDResponse.self, from: data)
                                if rs.success != nil {
                                    print("Ürün sepete başarıyla eklendi.")
                                    self.fetchCartProducts() {} // Sepeti tekrar güncelle
                                } else {
                                    print("Sepete ekleme başarısız.")
                                }
                            } catch {
                                print("Sepete eklerken bir hata oluştu: \(error.localizedDescription)")
                            }
                        }
                    }
                } else {
                    print("Sepette ürün bulunamadı.")
                }
            }).disposed(by: DisposeBag())
        }
    }

    func deleteProductFromCart(sepetId:Int){
        let url = "http://kasimadalan.pe.hu/urunler/sepettenUrunSil.php"
        let params: Parameters = ["sepetId":sepetId,"kullaniciAdi":"tbicer"]
        
        AF.request(url,method: .post,parameters: params).response { response in
            if let data = response.data {
                do{
                    let rs = try JSONDecoder().decode(CRUDResponse.self, from: data)
                    if (rs.success != nil) {
                        print("\(sepetId) id'li ürün silindi")
                        self.fetchCartProducts {}
                    }
                    
                }catch{
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func deleteAllProductsFromCart(completion: @escaping () -> Void){
        fetchCartProducts(){
            self.cartProducts.subscribe(onNext: {cartItems in
                for item in cartItems {
                    self.deleteProductFromCart(sepetId: item.sepetId)
                }
                self.fetchCartProducts() {}
            }).disposed(by: DisposeBag())
        }
    } 
}
