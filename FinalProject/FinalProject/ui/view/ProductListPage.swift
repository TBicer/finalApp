import UIKit

class ProductListPage: UIViewController {
    @IBOutlet weak var productCollectionView: UICollectionView!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    var viewModel = ProductListPageViewModel()
    var category:ProductCategory?
    var filteredProducts = [Product]()
    var filterOptions = [Filter]()
    
    var searchBar: UISearchBar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productCollectionView.dataSource = self
        productCollectionView.delegate = self
        designCells()
                
        if let c = category {
            navigationItem.title = c.title
            viewModel.fetchCategoryProducts(category: c)
            
            if c.title == "Tüm Ürünler" {
                // "Tüm Ürünler" kategorisi için filtre seçeneklerini dinamik olarak ayarla
               
            } else {
                // Diğer kategoriler için
                let f1 = Filter(title: "Marka", values: [])
                let f2 = Filter(title: "Fiyat", values: ["test1"])
                let f3 = Filter(title: "Sıralama", values: ["test1"])
                filterOptions.append(f1)
                filterOptions.append(f2)
                filterOptions.append(f3)
            }
            
        }
        
        _ = viewModel.filteredProductList.subscribe(onNext: { filteredProducts in
            self.filteredProducts = filteredProducts
            DispatchQueue.main.async {
                self.productCollectionView.reloadData()
            }
        })
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async {
            self.productCollectionView.reloadData()
        }
    }
    
    func designCells(){
        // ürünler collection view
        let productDesign = UICollectionViewFlowLayout()
        productDesign.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        productDesign.minimumInteritemSpacing = 10
        productDesign.minimumLineSpacing = 16
        let ekranGenislik = UIScreen.main.bounds.width
        let itemGenislik = (ekranGenislik - 30) / 2
        productDesign.itemSize = CGSize(width: itemGenislik, height: 242)
        productCollectionView.collectionViewLayout = productDesign
    }
    
    @IBAction func didTapSearchIcon(_ sender: Any) {
        if searchBar == nil {
            searchBar = UISearchBar()
            searchBar?.placeholder = "Ara..."
            searchBar?.delegate = self
            navigationItem.titleView = searchBar
            searchBar?.becomeFirstResponder()
            searchButton.image = UIImage(systemName: "multiply")
        } else {
            navigationItem.titleView = nil
            searchBar = nil
            searchButton.image = UIImage(systemName: "magnifyingglass")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "listToDetail" {
            if let p = sender as? Product {
                let targetVC = segue.destination as! ProductDetailPage
                targetVC.product = p
            }
        }
    }
}

extension ProductListPage : UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Arama çubuğu iptal edildiğinde
        navigationItem.titleView = nil
        self.searchBar = nil // Arama çubuğunu sıfırla
        searchBar.resignFirstResponder() // Klavyeyi kapat
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchProduct(searchText: searchText.lowercased())
    }
}

extension ProductListPage : UICollectionViewDelegate, UICollectionViewDataSource, ProductCellProtocol {
    func updateFavoriteList(productId: Int) {
        viewModel.updateFavoriteList(productId: productId) { success in
            if success {
                print("Favori listesi başarıyla güncellendi.")
                DispatchQueue.main.async{
                    self.productCollectionView.reloadData()
                }
            } else {
                print("Favori listesi güncellenirken hata oluştu.")
            }
        }
    }
    
    func didTapAddToCart(id:Int, ad: String, resim: String, kategori: String, fiyat: Int, marka: String) {
        viewModel.addToCart(productId: id, ad: ad, resim: resim, kategori: kategori, fiyat: fiyat, marka: marka, siparisAdeti: 1)
        viewModel.showAlert(on: self, title: "Sepete Eklendi", message: "\(ad) adlı ürün başarıyla sepete eklendi!")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productListCell", for: indexPath) as! ProductListCell
        let product = filteredProducts[indexPath.row]
        
        let fiyat = ProductCellFormatter.shared.formatCurrency(value: product.fiyat!)
        
        cell.product = product
        cell.productCellProtocol = self
        cell.productPriceLabel.text = fiyat
        cell.productTitleLabel.text = product.ad
        cell.productBrandLabel.text = product.marka
        ProductCellFormatter.shared.fetchImage(imageUrl: Constants.shared.imagePathURL, imageName: product.resim!, imageView: cell.productImageView)
        
        viewModel.checkIfFavorite(productId: product.id!) { isFavorite in
            DispatchQueue.main.async{
                cell.configureCell(isFavorite: isFavorite)
            }
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = filteredProducts[indexPath.row]
        performSegue(withIdentifier: "listToDetail", sender: product)
        productCollectionView.deselectItem(at: indexPath, animated: true)
    }
}
