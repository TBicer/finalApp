import UIKit

class ProductDetailPage: UIViewController {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productBrandLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productQuantityLabel: UILabel!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    
    var viewModel = ProductDetailPageViewModel()
    var product:Product?
    var quantity : Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.setupDesign()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let id = product?.id {
            viewModel.checkIfFavorite(productId: id) { isFavorite in
                DispatchQueue.main.async{
                    self.configureCell(isFavorite: isFavorite)
                }
            }
        }
    }
    
    func configureCell(isFavorite: Bool) {
        ButtonImageConfigurator.shared.configureHeartButton(favButton, isFavorite: isFavorite)
    }
    
    private func setupDesign(){
        if let p = product {
            let fiyat = ProductCellFormatter.shared.formatCurrency(value: p.fiyat!)
            
            ProductCellFormatter.shared.fetchImage(imageUrl: Constants.shared.imagePathURL, imageName: p.resim!, imageView: productImageView)
            productBrandLabel.text = p.marka
            productTitleLabel.text = p.ad
            productPriceLabel.text = fiyat
            productQuantityLabel.text = String(quantity)
        }
    }

    @IBAction func addToFav(_ sender: Any) {
        if let id = product?.id {
            viewModel.updateFavoriteList(productId: id) {[weak self] success in
                guard let self = self else {return}
                if success {
                    print("Favori listesi başarıyla güncellendi.")
                    self.viewModel.checkIfFavorite(productId: id) { isFavorite in
                        DispatchQueue.main.async{
                            self.configureCell(isFavorite: isFavorite)
                        }
                    }
                } else {
                    print("Favori listesi güncellenirken hata oluştu.")
                }
            }
        }
    }
    
    
    @IBAction func handleQuantity(_ sender: UIButton) {
        switch sender.tag {
        case -1: // Eksi butonu
            if quantity > 1 {
                quantity -= 1
            }
            productQuantityLabel.text = String(quantity)
            updateMinusButtonAppearance()
            
        case 1: // Artı butonu
            quantity += 1
            productQuantityLabel.text = String(quantity)
            updateMinusButtonAppearance()
            
        default:
            print("Bilinmeyen butona tıklandı")
        }
    }

    func updateMinusButtonAppearance() {
        if quantity == 0 {
            minusButton.isEnabled = false
        } else if quantity == 1 {
            minusButton.backgroundColor = UIColor(named: "BGSecondary")
            minusButton.setTitleColor(UIColor(named: "ContentDisabled"), for: .normal)
        } else {
            minusButton.backgroundColor = UIColor(named: "BGAccent")
            minusButton.setTitleColor(UIColor(named: "ContentOnColorInverse"), for: .normal)
        }
    }
    
    
    @IBAction func addToCart(_ sender: Any) {
        if let p = product {
            viewModel.addToCart(productId: p.id!, ad: p.ad!, resim: p.resim!, kategori: p.kategori!, fiyat: p.fiyat!, marka: p.marka!, siparisAdeti: quantity)
            viewModel.showAlert(on: self, title: "Sepete Eklendi", message: "\(p.ad!) sepetinize eklendi!")
        }
    }
}
