import UIKit

class DealsCell: UICollectionViewCell {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productBrandLabel: UILabel!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var favButton: UIButton!
    
    var productId:Int?
    var productCellProtocol:ProductCellProtocol?
    
    func configureCell(isFavorite: Bool) {
        ButtonImageConfigurator.shared.configureHeartButton(favButton, isFavorite: isFavorite)
    }

    
    @IBAction func addToFav(_ sender: Any) {
        if let id = productId {
            productCellProtocol?.updateFavoriteList(productId: id)
        }
    }
}
