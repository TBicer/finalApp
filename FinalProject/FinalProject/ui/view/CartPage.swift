import UIKit

class CartPage: UIViewController {
    @IBOutlet weak var cartTableView: UITableView!
    
    @IBOutlet weak var cartTotalLabel: UILabel!
    @IBOutlet weak var cargoPriceLabel: UILabel!
    var viewModel = CartPageViewModel()
    var cartProducts = [CartItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cartTableView.dataSource = self
        cartTableView.delegate = self
        
        viewModel.fetchCartProducts()
        cartTableView.separatorStyle = .none
        cartTableView.allowsSelection = false
        
        _ = viewModel.cartProducts.subscribe(onNext: { products in
            self.cartProducts = products
            DispatchQueue.main.async{
                self.cartTableView.reloadData()
            }
        })
        _ = viewModel.cartTotal.subscribe(onNext: { total in
            let formattedTotal = self.viewModel.formatCurrency(value: total)
            self.cartTotalLabel.text = formattedTotal
        })
        
        _ = viewModel.cargoPrice.subscribe(onNext: {price in
            let formattedPrice = self.viewModel.formatCurrency(value: price)
            self.cargoPriceLabel.text = formattedPrice
        })
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.fetchCartProducts()
    }
    
    @IBAction func handleClearCart(_ sender: Any) {
        viewModel.deleteAllProductsFromCart()
    }
    
    @IBAction func handleProceedPayment(_ sender: Any) {
    }
}

extension CartPage : UITableViewDelegate, UITableViewDataSource , CartProductCellProtocol {
    func updateProductInCart(ad: String, resim: String, kategori: String, fiyat: Int, marka: String, siparisAdeti: Int) {
        viewModel.updateProductInCart(ad: ad, resim: resim, kategori: kategori, fiyat: fiyat, marka: marka, siparisAdeti: siparisAdeti)
    }
    
    func didTapDeleteButton(sepetId: Int) {
        viewModel.deleteProductFromCart(sepetId: sepetId)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cartProductCell") as! CartProductCell
        let product = cartProducts[indexPath.row]
        
        let formattedTotal = self.viewModel.formatCurrency(value: product.fiyat!)
        
        cell.item = product
        cell.cartCellProtocol = self
        cell.productBrandLabel.text = product.marka
        cell.productPriceLabel.text = formattedTotal
        cell.productTitleLabel.text = product.ad
        cell.productQuantityLabel.text = String(product.siparisAdeti!)
        cell.quantity = product.siparisAdeti
        cell.sepetId = product.sepetId
        cell.image = product.resim
        
        viewModel.fetchImage(imageUrl: "http://kasimadalan.pe.hu/urunler/resimler/", imageName: product.resim!, imageView: cell.productImageView)
        
        return cell
    }
    
}
