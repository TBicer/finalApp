import UIKit

class HomeReusableTitleCell: UICollectionReusableView {
    @IBOutlet weak var cellTitleLbl: UILabel!
    
    func setup(_ title:String){
        cellTitleLbl.text = title
    }
    
}
