import UIKit

class CheckoutTitleReusableView: UICollectionReusableView {
    @IBOutlet weak var cellTitleLbl: UILabel!
    
    func setup(_ title:String){
        cellTitleLbl.text = title
    }
}
