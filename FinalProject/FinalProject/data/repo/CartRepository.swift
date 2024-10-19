import Foundation
import RxSwift
import FirebaseAuth
import FirebaseFirestore
import Alamofire

class CartRepository {
    var cartProducts = BehaviorSubject<[ProductFirebase]>(value: [ProductFirebase]())
    
    //Helper
    //castToProductFirebase
    
    //SEPETE EKLEME
    //addtocart fonksiyonu yapılacak. sepet içeriği tamamen firebase e yazılacak caritem ama firebasede duracak ayrıca bu ürünler database e kayıt edilecek
    
    // SEPETTEKİ ÜRÜNÜ SİLME -->  removeProductFromFirebase sonrası loadCartItems
    // sepetteki ürünü hem firebaseden hem de dbden silicek
    
    // Sepetteki Tüm ürünleri silme --> removeAllFromCartAPI, clearCartForFirebase
    // hem db hem de firebasedeki tüm ürünler silinecek
    
    // Sepette stok güncelleme ---> updateCartListInFirebase , updateCartAndFetchItems
    // ilk önce updateCartListInFirebase çalışacak daha sonrasında bunun completion kısmında updateCartAndFetchItems çalışacak
    
    // Sepeti Temizleme --> removeAllFromCartAPI
    // sadece db deki ürünler silinecek
    
    // giriş yapıldığında sepet getirme yada sepet sorgusu atma ---> fetchCartItems
    // eğer oturum açıksa users -> uid -> cartListteki ürünler addToCart ile eklenecek
    // eğer oturum kapalıysa anonymous -> anonymous -> cartListteki ürünler addToCart ile eklenecek
    
    //Sepetteki ürünleri listeleme --->
    // sepetteki ürünler firebasedeki veri ile listelenecek
    
    // FUNC LİST
    
    // API
    // addToCartAPI , fetchCartItemsAPI , removeFromCartAPI, removeAllFromCartAPI
    
    //FIREBASE
    // fetchCartItems , fetchUserCartItemsFromFirebase , fetchAnonymousCartItemsFromFirebase , updateCartListInFirebase , removeUsersProductFromFirebase , removeAnonymousProductFromFirebase , removeProductFromFirebase
    // clearCartForFirebase , clearCartForLoggedInUser , clearAnonymousCart
    
    
    func loadCartItems() {
        fetchCartItems { [weak self] items in
            guard let self = self else { return }
            
            if let items = items {
                // cartProducts'ı güncelle
                self.cartProducts.onNext(items)
            } else {
                // Eğer sepet boşsa ya da hata varsa, boş bir dizi gönder
                self.cartProducts.onNext([])
            }
        }
    }
    
    func addToCartAPI(ad: String, resim: String, kategori: String, fiyat: Int, marka: String, siparisAdeti: Int, completion: @escaping (Bool) -> Void) {
        let url = Constants.shared.addToCartURL
        let parameters: [String: Any] = [
            "ad": ad,
            "resim": resim,
            "kategori": kategori,
            "fiyat": fiyat,
            "marka": marka,
            "siparisAdeti": siparisAdeti,
            "kullaniciAdi": "tbicer"
        ]
        
        AF.request(url, method: .post, parameters: parameters).response { response in
            if let data = response.data {
                do {
                    let result = try JSONDecoder().decode(CRUDResponse.self, from: data)
                    print("Sepete ekleme başarılı: \(result)")
                    completion(true) // Başarı durumu
                } catch {
                    print("Sepete ekleme sırasında hata: \(error.localizedDescription)")
                    completion(false) // Hata durumu
                }
            } else if let error = response.error {
                print("İstek hatası: \(error.localizedDescription)")
                completion(false) // Hata durumu
            }
        }
    }
    
    func fetchCartItemsAPI(completion: @escaping ([CartItem]?) -> Void) {
        let url = Constants.shared.fetchCartItemsURL
        let parameters: Parameters = [
            "kullaniciAdi": "tbicer"
        ]
        
        print("repo istek öncesi")
        AF.request(url, method: .post, parameters: parameters).response { response in
            if let data = response.data {
                let responseDataString = String(data: data, encoding: .utf8) // Gelen veriyi string olarak yazdır
                print("Gelen veri: \(responseDataString ?? "Veri okunamadı")")
                
                do {
                    let cartItems = try JSONDecoder().decode(CartResponse.self, from: data)
                    if let list = cartItems.urunler_sepeti {
                        completion(list)
                    } else {
                        completion(nil)
                    }
                } catch {
                    print("Sepetteki ürünleri getirirken hata: \(error.localizedDescription)")
                    completion(nil)
                }
            } else if let error = response.error {
                print("İstek hatası: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    func removeFromCartAPI(sepetId: Int, completion: @escaping (Bool) -> Void) {
        let url = Constants.shared.deleteFromCartURL
        let parameters: [String: Any] = [
            "sepetId": sepetId,
            "kullaniciAdi": "tbicer"
        ]
        
        AF.request(url, method: .post, parameters: parameters).response { response in
            if let data = response.data {
                do {
                    let result = try JSONDecoder().decode(CRUDResponse.self, from: data)
                    print("Ürün silme başarılı: \(result)")
                    completion(true) // Silme işlemi başarılı
                } catch {
                    print("Ürün silinirken hata: \(error.localizedDescription)")
                    completion(false) // Silme işlemi başarısız
                }
            } else if let error = response.error {
                print("İstek hatası: \(error.localizedDescription)")
                completion(false) // Silme işlemi başarısız
            }
        }
    }
    
    func removeAllFromCartAPI(completion: @escaping (Bool) -> Void) {
        fetchCartItemsAPI { [weak self] cartItems in
            guard let self = self else { return }
            guard let items = cartItems else {
                completion(false) // Sepet boşsa veya veriler alınamadıysa
                return
            }
            
            let dispatchGroup = DispatchGroup()
            var allRemoved = true
            
            for item in items {
                dispatchGroup.enter() // Yeni bir işlem başladığını belirt
                self.removeFromCartAPI(sepetId: item.sepetId!) { success in
                    if !success {
                        allRemoved = false // Herhangi bir silme başarısız olduysa
                    }
                    dispatchGroup.leave() // İşlemi tamamla
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(allRemoved) // Tüm silme işlemleri tamamlandığında sonucu döndür
            }
        }
    }
    
    // updateCartListInFirebase başarıyla tamamlandığında çağrılacak fonksiyon
    //    func updateCartAndFetchItems(product: ProductFirebase) {
    //        updateCartListInFirebase(product: product) {[weak self] success in
    //            guard let self = self else {return}
    //            if success {
    //                self.removeAllFromCartAPI { success in
    //                    self.fetchCartItems { cartItems in
    //                        guard let items = cartItems else {
    //                            print("Sepet ürünleri alınamadı.")
    //                            return
    //                        }
    //
    //                        // Sepetteki her bir ürünü veritabanına yazdır
    //                        for item in items {
    //                            self.addToCartAPI(ad: item.ad ?? "",
    //                                         resim: item.resim ?? "",
    //                                         kategori: item.kategori ?? "",
    //                                         fiyat: item.fiyat ?? 0,
    //                                         marka: item.marka ?? "",
    //                                         siparisAdeti: item.siparisAdeti ?? 0)
    //                        }
    //                    }
    //                }
    //            } else {
    //                print("Sepet güncelleme başarısız.")
    //            }
    //        }
    //    }
    
    func updateCartAndFetchItems(product: ProductFirebase, completion: @escaping () -> Void) {
        updateCartListInFirebase(product: product) { [weak self] success in
            guard let self = self else { return }
            if success {
                self.removeAllFromCartAPI { success in
                    self.fetchCartItems { cartItems in
                        guard let items = cartItems else {
                            print("Sepet ürünleri alınamadı.")
                            return
                        }
                        
                        // Sepetteki her bir ürünü veritabanına yazdır
                        let dispatchGroup = DispatchGroup() // İşlemleri takip etmek için DispatchGroup kullanıyoruz
                        
                        for item in items {
                            dispatchGroup.enter() // Yeni bir işlem başlatılıyor
                            
                            self.addToCartAPI(ad: item.ad ?? "",
                                              resim: item.resim ?? "",
                                              kategori: item.kategori ?? "",
                                              fiyat: item.fiyat ?? 0,
                                              marka: item.marka ?? "",
                                              siparisAdeti: item.siparisAdeti ?? 0) { success in
                                if success {
                                    print("\(item.ad ?? "") sepete başarıyla eklendi.")
                                } else {
                                    print("\(item.ad ?? "") sepete eklenirken hata oluştu.")
                                }
                                dispatchGroup.leave() // İşlem tamamlandı
                            }
                        }
                        
                        // Tüm işlemler tamamlandığında
                        dispatchGroup.notify(queue: .main) {
                            print("Tüm ürünler sepete eklendi.")
                            completion()
                        }
                    }
                }
            } else {
                print("Sepet güncelleme başarısız.")
            }
        }
    }
    
    
    func addFetchedItemsToCart(completion: @escaping (Bool) -> Void) {
        fetchCartItems { [weak self] products in
            guard let self = self else {return}
            guard let products = products else {
                print("Sepet ürünleri alınamadı.")
                completion(false)
                return
            }
            
            var addToCartSuccess = true
            let dispatchGroup = DispatchGroup() // Tüm işlemleri takip etmek için DispatchGroup kullanıyoruz
            
            for product in products {
                dispatchGroup.enter() // Yeni bir işlem başlatılıyor
                
                // addToCartAPI fonksiyonunu çağır
                addToCartAPI(ad: product.ad!, resim: product.resim!, kategori: product.kategori!, fiyat: product.fiyat!, marka: product.marka!, siparisAdeti: product.siparisAdeti!) { success in
                    if !success {
                        addToCartSuccess = false // Bir hata olduysa başarı durumunu false yap
                    }
                    dispatchGroup.leave() // İşlem tamamlandı
                }
            }
            
            // Tüm işlemler tamamlandığında
            dispatchGroup.notify(queue: .main) {
                print("Tüm ürünler sepete eklendi.")
                completion(addToCartSuccess)
            }
        }
    }
    
    func fetchCartItems(completion: @escaping ([ProductFirebase]?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            // Kullanıcı giriş yapmamışsa
            print("Kullanıcı giriş yapmamış, anonim sepeti alınıyor...")
            fetchAnonymousCartItemsFromFirebase(completion: completion)
            return
        }
        
        // Kullanıcı giriş yaptıysa
        print("Kullanıcı giriş yapmış, kullanıcı UID: \(currentUser.uid)")
        fetchUserCartItemsFromFirebase(uid: currentUser.uid, completion: completion)
    }
    
    // Giriş yapan kullanıcının sepetini çeken fonksiyon
    private func fetchUserCartItemsFromFirebase(uid: String, completion: @escaping ([ProductFirebase]?) -> Void) {
        let db = Firestore.firestore()
        
        // Kullanıcı belgesinden cartList alanını al
        db.collection("users").document(uid).getDocument { (document, error) in
            if let error = error {
                print("Kullanıcı verilerini alırken hata: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let document = document, document.exists else {
                print("Belge bulunamadı.")
                completion(nil)
                return
            }
            
            // "cartList" alanını al ve ProductFireBase modeline dönüştür
            guard let cartListData = document.data()?["cartList"] as? [[String: Any]] else {
                print("Sepet verisi bulunamadı.")
                completion(nil)
                return
            }
            
            var products: [ProductFirebase] = []
            
            for item in cartListData {
                do {
                    // Firestore'dan gelen verileri ProductFireBase modeline dönüştür
                    let productData = try Firestore.Decoder().decode(ProductFirebase.self, from: item)
                    products.append(productData)
                } catch {
                    print("Ürün verilerini ayrıştırırken hata: \(error.localizedDescription)")
                }
            }
            
            print("Kullanıcı sepeti çekildi, toplam ürün sayısı: \(products.count)")
            completion(products)
        }
    }
    
    
    // Giriş yapmamış kullanıcı için anonim sepetini çeken fonksiyon
    private func fetchAnonymousCartItemsFromFirebase(completion: @escaping ([ProductFirebase]?) -> Void) {
        let db = Firestore.firestore()
        
        // "anonymous" koleksiyonu altındaki "anonymous" belgesine erişim
        db.collection("anonymous").document("anonymous").getDocument { (document, error) in
            if let error = error {
                print("Anonim sepet verilerini alırken hata: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let document = document, document.exists else {
                print("Anonim sepet bulunamadı.")
                completion(nil)
                return
            }
            
            // "cartList" alanını al ve ProductFireBase modeline dönüştür
            guard let cartListData = document.data()?["cartList"] as? [[String: Any]] else {
                print("Sepet verisi bulunamadı.")
                completion(nil)
                return
            }
            
            var products: [ProductFirebase] = []
            
            for item in cartListData {
                do {
                    // Firestore'dan gelen verileri ProductFireBase modeline dönüştür
                    let productData = try Firestore.Decoder().decode(ProductFirebase.self, from: item)
                    products.append(productData)
                } catch {
                    print("Ürün verilerini ayrıştırırken hata: \(error.localizedDescription)")
                }
            }
            
            print("Anonim sepeti çekildi, toplam ürün sayısı: \(products.count)")
            completion(products)
        }
    }
    
    func updateCartListInFirebase(product: ProductFirebase, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        
        // Kullanıcı oturumu açık mı kontrol et
        guard let currentUser = Auth.auth().currentUser else {
            print("Kullanıcı oturumu açık değil, anonim kullanıcıya geçiliyor...")
            let anonymousDocRef = db.collection("anonymous").document("anonymous")
            
            anonymousDocRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    var cartList = document.data()?["cartList"] as? [[String: Any]] ?? []
                    
                    // Mevcut ürünleri kontrol et
                    if let index = cartList.firstIndex(where: { $0["productId"] as? Int == product.productId }) {
                        // Aynı productId varsa, sipariş adedini artır
                        if let currentQuantity = cartList[index]["siparisAdeti"] as? Int {
                            cartList[index]["siparisAdeti"] = currentQuantity + (product.siparisAdeti ?? 1)
                        }
                    } else {
                        // Yeni ürünü ekle
                        let productData: [String: Any] = [
                            "productId": product.productId ?? 0,
                            "ad": product.ad ?? "",
                            "resim": product.resim ?? "",
                            "kategori": product.kategori ?? "",
                            "fiyat": product.fiyat ?? 0,
                            "marka": product.marka ?? "",
                            "siparisAdeti": product.siparisAdeti ?? 0,
                            "kullaniciAdi": product.kullaniciAdi ?? ""
                        ]
                        cartList.append(productData)
                    }
                    
                    // Anonim sepet güncelleme
                    anonymousDocRef.updateData(["cartList": cartList]) { error in
                        if let error = error {
                            print("Anonim sepet güncellenirken hata oluştu: \(error.localizedDescription)")
                            completion(false)
                        } else {
                            print("Anonim sepet başarıyla güncellendi, ürün eklendi.")
                            completion(true)
                        }
                    }
                } else {
                    // Anonim belge yoksa oluştur
                    let productData: [String: Any] = [
                        "cartList": [[
                            "productId": product.productId ?? 0,
                            "ad": product.ad ?? "",
                            "resim": product.resim ?? "",
                            "kategori": product.kategori ?? "",
                            "fiyat": product.fiyat ?? 0,
                            "marka": product.marka ?? "",
                            "siparisAdeti": product.siparisAdeti ?? 0,
                            "kullaniciAdi": product.kullaniciAdi ?? ""
                        ]]
                    ]
                    
                    anonymousDocRef.setData(productData) { error in
                        if let error = error {
                            print("Anonim sepet oluşturulurken hata oluştu: \(error.localizedDescription)")
                            completion(false)
                        } else {
                            print("Anonim sepet başarıyla oluşturuldu.")
                            completion(true)
                        }
                    }
                }
            }
            return
        }
        
        // Kullanıcı oturumu açıksa devam et
        let userDocRef = db.collection("users").document(currentUser.uid)
        
        userDocRef.getDocument { (document, error) in
            if let document = document, document.exists {
                var cartList = document.data()?["cartList"] as? [[String: Any]] ?? []
                
                // Mevcut ürünleri kontrol et
                if let index = cartList.firstIndex(where: { $0["productId"] as? Int == product.productId }) {
                    // Aynı productId varsa, sipariş adedini artır
                    if let currentQuantity = cartList[index]["siparisAdeti"] as? Int {
                        cartList[index]["siparisAdeti"] = currentQuantity + (product.siparisAdeti ?? 1)
                    }
                } else {
                    // Yeni ürünü ekle
                    let productData: [String: Any] = [
                        "productId": product.productId ?? 0,
                        "ad": product.ad ?? "",
                        "resim": product.resim ?? "",
                        "kategori": product.kategori ?? "",
                        "fiyat": product.fiyat ?? 0,
                        "marka": product.marka ?? "",
                        "siparisAdeti": product.siparisAdeti ?? 0,
                        "kullaniciAdi": product.kullaniciAdi ?? ""
                    ]
                    cartList.append(productData)
                }
                
                // Kullanıcı sepet güncelleme
                userDocRef.updateData(["cartList": cartList]) { error in
                    if let error = error {
                        print("Kullanıcı sepet güncellenirken hata oluştu: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("Kullanıcı sepet başarıyla güncellendi, ürün eklendi.")
                        completion(true)
                    }
                }
            } else {
                print("Kullanıcı belgesi bulunamadı veya hata oluştu.")
                completion(false)
            }
        }
    }
    
    func removeUsersProductFromFirebase(productId: Int, completion: @escaping (Bool) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            print("Kullanıcı oturumu açık değil.")
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        let userDocRef = db.collection("users").document(currentUser.uid)
        
        // Kullanıcının sepetini al ve ürün sil
        userDocRef.getDocument { (document, error) in
            if let document = document, document.exists {
                var cartList = document.data()?["cartList"] as? [[String: Any]] ?? []
                
                // Ürünü bul ve sil
                if let index = cartList.firstIndex(where: { $0["productId"] as? Int == productId }) {
                    cartList.remove(at: index)
                    // Güncellenmiş cartList ile veriyi güncelle
                    userDocRef.updateData(["cartList": cartList]) { error in
                        if let error = error {
                            print("Ürün sepetten silinirken hata oluştu: \(error.localizedDescription)")
                            completion(false)
                        } else {
                            print("Ürün başarıyla sepetten silindi.")
                            completion(true)
                        }
                    }
                } else {
                    print("Ürün sepetten silinemedi: Ürün bulunamadı.")
                    completion(false)
                }
            } else {
                print("Kullanıcı belgesi bulunamadı.")
                completion(false)
            }
        }
    }
    
    func removeAnonymousProductFromFirebase(productId: Int, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let anonymousDocRef = db.collection("anonymous").document("anonymous")
        
        // Anonim kullanıcının sepetini al ve ürün sil
        anonymousDocRef.getDocument { (document, error) in
            if let document = document, document.exists {
                var cartList = document.data()?["cartList"] as? [[String: Any]] ?? []
                
                // Ürünü bul ve sil
                if let index = cartList.firstIndex(where: { $0["productId"] as? Int == productId }) {
                    cartList.remove(at: index)
                    // Güncellenmiş cartList ile veriyi güncelle
                    anonymousDocRef.updateData(["cartList": cartList]) { error in
                        if let error = error {
                            print("Anonim kullanıcının sepetinden ürün silinirken hata oluştu: \(error.localizedDescription)")
                            completion(false)
                        } else {
                            print("Anonim kullanıcının sepetinden ürün başarıyla silindi.")
                            completion(true)
                        }
                    }
                } else {
                    print("Ürün anonim sepetten silinemedi: Ürün bulunamadı.")
                    completion(false)
                }
            } else {
                print("Anonim belge bulunamadı.")
                completion(false)
            }
        }
    }
    
    func removeProductFromFirebase(productId: Int, completion: @escaping (Bool) -> Void) {
        if Auth.auth().currentUser != nil {
            // Oturum açık
            removeUsersProductFromFirebase(productId: productId) { success in
                completion(success)
            }
        } else {
            // Oturum kapalı
            removeAnonymousProductFromFirebase(productId: productId) { success in
                completion(success)
            }
        }
    }
    
    
    func clearCartForLoggedInUser(completion: @escaping (Bool) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            print("Kullanıcı oturumu açık değil.")
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        let userDocRef = db.collection("users").document(currentUser.uid)
        
        // CartList alanını sil
        userDocRef.updateData([
            "cartList": FieldValue.delete()
        ]) { error in
            if let error = error {
                print("Kullanıcının sepetini silerken hata oluştu: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Kullanıcının sepeti başarıyla silindi.")
                completion(true)
            }
        }
    }
    
    func clearAnonymousCart(completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let anonymousDocRef = db.collection("anonymous").document("anonymous")
        
        // CartList alanını sil
        anonymousDocRef.updateData([
            "cartList": FieldValue.delete()
        ]) { error in
            if let error = error {
                print("Anonim kullanıcının sepetini silerken hata oluştu: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Anonim kullanıcının sepeti başarıyla silindi.")
                completion(true)
            }
        }
    }
    
    func clearCartForFirebase(completion: @escaping (Bool) -> Void) {
        if Auth.auth().currentUser != nil {
            // Oturum açık
            clearCartForLoggedInUser { success in
                completion(success)
            }
        } else {
            // Oturum kapalı
            clearAnonymousCart { success in
                completion(success)
            }
        }
    }
    
    func createOrderToFirebase(order: Order, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            // Giriş yapmamış kullanıcılar için
            let anonymousRef = Firestore.firestore().collection("anonymous").document("anonymous")
            
            let orderData: [String: Any] = [
                "products": order.products?.map { [
                    "productID": $0.productId ?? 0,
                    "fiyat": $0.fiyat ?? 0,
                    "siparisAdeti": $0.siparisAdeti ?? 0,
                    "marka": $0.marka ?? "",
                    "ad": $0.ad ?? "",
                    "resim": $0.resim ?? ""
                ] } ?? [],
                "address": order.address ?? "",
                "cartTotal": order.cartTotal ?? 0,
                "cargoPrice": order.cargoPrice ?? 0
            ]
            
            anonymousRef.updateData([
                "orderList": FieldValue.arrayUnion([orderData])
            ]) { error in
                if let error = error {
                    print("Anonymous order could not be saved: \(error.localizedDescription)")
                    completion(.failure(error)) // Hata varsa failure ile completion döndür
                } else {
                    print("Anonymous order saved successfully!")
                    completion(.success(())) // Başarılı ise success döndür
                }
            }
            return
        }
        
        // Giriş yapmış kullanıcılar için
        let userRef = Firestore.firestore().collection("users").document(currentUser.uid)
        
        let orderData: [String: Any] = [
            "products": order.products?.map { [
                "productID": $0.productId ?? 0,
                "fiyat": $0.fiyat ?? 0,
                "siparisAdeti": $0.siparisAdeti ?? 0,
                "marka": $0.marka ?? "",
                "ad": $0.ad ?? "",
                "resim": $0.resim ?? ""
            ] } ?? [],
            "address": order.address ?? "",
            "cartTotal": order.cartTotal ?? 0,
            "cargoPrice": order.cargoPrice ?? 0
        ]
        
        userRef.updateData([
            "orderList": FieldValue.arrayUnion([orderData])
        ]) { error in
            if let error = error {
                print("Order could not be saved: \(error.localizedDescription)")
                completion(.failure(error)) // Hata varsa failure ile completion döndür
            } else {
                print("Order saved successfully!")
                completion(.success(())) // Başarılı ise success döndür
            }
        }
    }

}

