import UIKit

class RecListCell: UICollectionViewCell {
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productBrandLabel: UILabel!
    
    var product:Product?
    var productCellProtocol:ProductCellProtocol?
    
    @IBAction func addToCart(_ sender: Any) {
        if let p = product {
            productCellProtocol?.didTapAddToCart(ad: p.ad!, resim: p.resim!, kategori: p.kategori!, fiyat: p.fiyat!, marka: p.marka!)
        }
    }
    
    @IBAction func addToFav(_ sender: Any) {
        
    }
    
}
