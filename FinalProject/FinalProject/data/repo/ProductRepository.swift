import Foundation
import RxSwift
import UIKit
import Alamofire
import FirebaseAuth
import FirebaseFirestore

class ProductRepository {
    private let disposeBag = DisposeBag()
    var productList = [Product]()
    var categoryList = BehaviorSubject<[ProductCategory]>(value: [ProductCategory]())
    var originalCategoryList: [ProductCategory] = []
    var filteredProductList = BehaviorSubject<[Product]>(value: [Product]())
    var orgFilteredProducts: [Product] = []
    var dealSliderList = BehaviorSubject<[Product]>(value: [])
    var recommendList = BehaviorSubject<[Product]>(value: [])
    var favoriteList = BehaviorSubject<[Product]>(value: [])
    
    init(){
        fetchProducts()
    }
    
    func fetchFavoriteIds(completion: @escaping ([Int]) -> Void) {
        let db = Firestore.firestore()
        let userDocRef = db.collection("users").document(Auth.auth().currentUser?.uid ?? "anonymous")
        
        userDocRef.getDocument { document, error in
            if let document = document, document.exists {
                // Kullanıcı oturumu açıksa
                let favList = document.data()?["favList"] as? [String] ?? []
                let favoriteIds = favList.compactMap { Int($0) }
                completion(favoriteIds)
            } else {
                // Kullanıcı oturumu kapalıysa, anonim kullanıcının favori listesini kontrol et
                let anonymousDocRef = db.collection("anonymous").document("anonymous")
                
                anonymousDocRef.getDocument { document, error in
                    if let document = document, document.exists {
                        let favList = document.data()?["favList"] as? [String] ?? []
                        let favoriteIds = favList.compactMap { Int($0) }
                        completion(favoriteIds)
                    } else {
                        print("Anonymous kullanıcı belgesi bulunamadı veya hata oluştu.")
                        completion([])
                    }
                }
            }
        }
    }
    
    // Ürünleri URL'den çekip favori olanları bulma
    func fetchFavoriteProducts() {
        let url = Constants.shared.fetchProductsURL
        
        fetchFavoriteIds { [weak self] favoriteIds in
            guard let self = self else {return}
            
            var favList = [Product]()
            
            AF.request(url,method: .get).response{ response in
                if let data = response.data {
                    do{
                        let rs = try JSONDecoder().decode(ProductResponse.self, from: data)
                        if let list = rs.urunler {
                            for id in favoriteIds {
                                let newList = list.filter({$0.id == id})
                                favList.append(contentsOf: newList)
                            }
                            
                            DispatchQueue.main.async {
                                self.favoriteList.onNext(favList)
                            }
                        }
                    }catch {
                        print("Fav Listesi Çekerken Hata: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    
    
    // Favori kontrolü için genel bir fonksiyon
    func checkIfFavorite(productId: Int, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        
        if let currentUser = Auth.auth().currentUser {
            // Kullanıcının favori listesini al
            let userDocRef = db.collection("users").document(currentUser.uid)
            userDocRef.getDocument { document, error in
                if let document = document, document.exists,
                   let favList = document.data()?["favList"] as? [String] {
                    let productIdString = String(productId)
                    let isFavorite = favList.contains(productIdString)
                    completion(isFavorite)
                } else {
                    completion(false) // Favori listesi yoksa
                }
            }
        } else {
            // Kullanıcı oturumu kapalıysa anonymous koleksiyonuna bak
            let anonymousDocRef = db.collection("anonymous").document("anonymous")
            anonymousDocRef.getDocument { document, error in
                if let document = document, document.exists,
                   let favList = document.data()?["favList"] as? [String] {
                    let productIdString = String(productId)
                    let isFavorite = favList.contains(productIdString)
                    completion(isFavorite)
                } else {
                    completion(false) // Favori listesi yoksa
                }
            }
        }
    }
    
    func updateFavoriteList(productId: Int, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        
        // currentUser nil mi kontrol et
        guard let currentUser = Auth.auth().currentUser else {
            print("Kullanıcı oturumu açık değil, anonim kullanıcıya geçiliyor...")
            // Kullanıcı oturumu kapalıysa anonim kullanıcı işlemleri
            let anonymousDocRef = db.collection("anonymous").document("anonymous")
            
            anonymousDocRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    var favList = document.data()?["favList"] as? [String] ?? []
                    
                    let productIdString = String(productId)
                    
                    if let index = favList.firstIndex(of: productIdString) {
                        favList.remove(at: index)
                        anonymousDocRef.updateData(["favList": favList]) { error in
                            if let error = error {
                                print("Anonymous favori listesi güncellenirken hata oluştu: \(error.localizedDescription)")
                                completion(false)
                            } else {
                                print("Anonymous favori listesi başarıyla güncellendi, ürün silindi.")
                                completion(true)
                                self.fetchFavoriteProducts()
                            }
                        }
                    } else {
                        favList.append(productIdString)
                        anonymousDocRef.updateData(["favList": favList]) { error in
                            if let error = error {
                                print("Anonymous favori listesi güncellenirken hata oluştu: \(error.localizedDescription)")
                                completion(false)
                            } else {
                                print("Anonymous favori listesi başarıyla güncellendi, ürün eklendi.")
                                completion(true)
                                self.fetchFavoriteProducts()
                            }
                        }
                    }
                } else {
                    let productIdString = String(productId)
                    anonymousDocRef.setData(["favList": [productIdString]]) { error in
                        if let error = error {
                            print("Anonymous favori listesi oluşturulurken hata oluştu: \(error.localizedDescription)")
                            completion(false)
                        } else {
                            print("Anonymous favori listesi başarıyla oluşturuldu.")
                            completion(true)
                            self.fetchFavoriteProducts()
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
                var favList = document.data()?["favList"] as? [String] ?? []
                
                let productIdString = String(productId)
                
                if let index = favList.firstIndex(of: productIdString) {
                    favList.remove(at: index)
                    userDocRef.updateData(["favList": favList]) { error in
                        if let error = error {
                            print("Favori listesi güncellenirken hata oluştu: \(error.localizedDescription)")
                            completion(false)
                        } else {
                            print("Favori listesi başarıyla güncellendi, ürün silindi.")
                            completion(true)
                        }
                    }
                } else {
                    favList.append(productIdString)
                    userDocRef.updateData(["favList": favList]) { error in
                        if let error = error {
                            print("Favori listesi güncellenirken hata oluştu: \(error.localizedDescription)")
                            completion(false)
                        } else {
                            print("Favori listesi başarıyla güncellendi, ürün eklendi.")
                            completion(true)
                        }
                    }
                }
            } else {
                print("Kullanıcı belgesi bulunamadı veya hata oluştu. updatefavlist")
                completion(false)
            }
        }
    }
    
    // Helper'a taşındı
    func showAlert(on viewController: UIViewController,title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "Devam Et", style: .cancel)
        alertController.addAction(actionCancel)
        
        viewController.present(alertController, animated: true)
    }
    // Helper'a taşındı
    func showDeleteAlert(on viewController: UIViewController, title: String, message: String, yesAction: @escaping () -> Void) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let actionYes = UIAlertAction(title: "Evet", style: .destructive) { _ in
            yesAction()
        }
        
        let actionNo = UIAlertAction(title: "Hayır", style: .cancel, handler: nil)
        
        alertController.addAction(actionYes)
        alertController.addAction(actionNo)
        
        viewController.present(alertController, animated: true)
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
    
    func setRandomDeals(count:Int,completion: @escaping ([Product]) -> Void) {
        let url = Constants.shared.fetchProductsURL
        
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
        let url = Constants.shared.fetchProductsURL
        
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
        let url = Constants.shared.fetchProductsURL
        
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
}
