import UIKit



class CartProductCell: UITableViewCell {
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productBrandLabel: UILabel!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productQuantityLabel: UILabel!
    @IBOutlet weak var minusButton: UIButton!
    
    var cartCellProtocol : CartProductCellProtocol?
    var image:String?
    var item:ProductFirebase?
    
    var quantity: Int? {
        didSet {
            productQuantityLabel.text = "\(quantity ?? 0)"
            updateMinusButtonAppearance()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func handleQuantity(_ sender: UIButton) {
        guard var q = quantity else { return }
            
        switch sender.tag {
        case -1: // Eksi butonu
            if q > 1 {
                q -= 1
                quantity = q
                productQuantityLabel.text = String(q)
                updateMinusButtonAppearance()
                updateCart(with: -1) // Güncellenmiş miktarı API'ye gönder
            }
            
        case 1: // Artı butonu
            q += 1
            quantity = q
            productQuantityLabel.text = String(q)
            updateMinusButtonAppearance()
            updateCart(with: 1) // Güncellenmiş miktarı API'ye gönder
            
        default:
            print("Bilinmeyen butona tıklandı")
        }
    }
    
    func updateCart(with quantity: Int) {
        guard let cartCellProtocol = self.cartCellProtocol, let item = item else { return }
        
        let productId = item.productId
        let ad = item.ad
        let resim = item.resim
        let kategori = item.kategori
        let fiyat = item.fiyat
        let marka = item.marka
        
        cartCellProtocol.updateProductInCart(productId: productId!, ad: ad!, resim: resim!, kategori: kategori!, fiyat: fiyat!, marka: marka!, siparisAdeti: quantity)
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
    
    @IBAction func handleDelete(_ sender: Any) {
        if let productId = item?.productId{
            cartCellProtocol?.didTapDeleteButton(sepetId: productId)
        }
    }
}
