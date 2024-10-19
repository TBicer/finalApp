import UIKit
import RxSwift

class CartPage: UIViewController {
    @IBOutlet weak var cartTableView: UITableView!
    @IBOutlet weak var cartTotalLabel: UILabel!
    @IBOutlet weak var cargoPriceLabel: UILabel!
    @IBOutlet weak var clearCartButton: UIBarButtonItem!
    
    var viewModel = CartPageViewModel()
    private let disposeBag = DisposeBag()
    var cartProducts = [ProductFirebase]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cartTableView.dataSource = self
        cartTableView.delegate = self
        
        viewModel.loadCartItems()
        
        cartTableView.separatorStyle = .none
        
        viewModel.cartProducts
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] cartList in
                        guard let self = self else {return}
                        self.cartProducts = cartList
                        DispatchQueue.main.async{
                            self.cartTableView.reloadData()
                        }
                        if cartList.isEmpty{
                            clearCartButton.isHidden = true
                        }else {
                            clearCartButton.isHidden = false
                        }
                    })
                    .disposed(by: disposeBag)
        
        _ = viewModel.cartTotal
            .subscribe(onNext: { total in
            let fiyat = ProductCellFormatter.shared.formatCurrency(value: total)
            self.cartTotalLabel.text = fiyat
        })
        
        viewModel.cargoPrice
            .subscribe(onNext: { [weak self] price in
                guard let self = self else { return }
                if self.cartProducts.isEmpty {
                    let fiyat = ProductCellFormatter.shared.formatCurrency(value: price)
                    self.cargoPriceLabel.text = fiyat
                } else {
                    if price == 0 {
                        self.cargoPriceLabel.text = "Ücretsiz"
                    } else {
                        let fiyat = ProductCellFormatter.shared.formatCurrency(value: price)
                        self.cargoPriceLabel.text = fiyat
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cartToCheckout" {
            if let products = sender as? [ProductFirebase] {
                let targetVC = segue.destination as! CheckoutPage
                targetVC.orderProducts = products
                viewModel.cartTotal
                        .subscribe(onNext: { total in
                            targetVC.cartTotal = total
                        })
                        .disposed(by: disposeBag)
                viewModel.cargoPrice
                    .subscribe(onNext: { price in
                        targetVC.cargoPrice = price
                    })
                    .disposed(by: disposeBag)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.loadCartItems()
        DispatchQueue.main.async {
            self.cartTableView.reloadData()
        }
    }
    
    @IBAction func handleClearCart(_ sender: Any) {
        viewModel.showDeleteAlert(on: self, title: "Tüm Ürünleri Sil", message: "Tüm ürünleri silmek istediğinize emin misiniz?"){
            self.viewModel.deleteAllProductsFromCart()
        }
    }
    
    @IBAction func handleProceedPayment(_ sender: Any) {
        if cartProducts.isEmpty{
            ShowAlertHelper.shared.showAlert(on: self, title: "Hata", message: "Sepetiniz boş olduğu için sipariş veremezsiniz :(")
        }else{
            performSegue(withIdentifier: "cartToCheckout", sender: cartProducts)
        }
    }
}

extension CartPage : UITableViewDelegate, UITableViewDataSource , CartProductCellProtocol {
    func updateProductInCart(productId: Int,ad: String, resim: String, kategori: String, fiyat: Int, marka: String, siparisAdeti: Int) {
        print("update tuşu \(siparisAdeti)")
        viewModel.addToCart(productId: productId, ad: ad, resim: resim, kategori: kategori, fiyat: fiyat, marka: marka, siparisAdeti: siparisAdeti)
    }
    
    func didTapDeleteButton(sepetId: Int) {
        viewModel.showDeleteAlert(on: self, title: "Bu Ürünü Sil", message: "Bu ürünü silmek istediğinize emin misiniz?"){
            self.viewModel.deleteProductFromCart(sepetId: sepetId)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cartProductCell") as! CartProductCell
        let product = cartProducts[indexPath.row]
        let productPrice = product.fiyat! * product.siparisAdeti!
        
        let fiyat = ProductCellFormatter.shared.formatCurrency(value: productPrice)
        
        cell.item = product
        cell.cartCellProtocol = self
        cell.productBrandLabel.text = product.marka
        cell.productPriceLabel.text = fiyat
        cell.productTitleLabel.text = product.ad
        cell.productQuantityLabel.text = String(product.siparisAdeti!)
        cell.quantity = product.siparisAdeti
        cell.image = product.resim
        
        ProductCellFormatter.shared.fetchImage(imageUrl: Constants.shared.imagePathURL, imageName: product.resim!, imageView: cell.productImageView)
        
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = .clear
        
        return cell
    }
    
}
