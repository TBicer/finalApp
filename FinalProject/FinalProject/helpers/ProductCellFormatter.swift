import Foundation
import Kingfisher
import UIKit

class ProductCellFormatter {
    
    public static let shared = ProductCellFormatter()
    
    private init(){}
    
    public func formatCurrency(value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal // Para birimi yerine sadece sayı formatı
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.maximumFractionDigits = 0 // Kuruş ayarı
        
        if let formattedValue = formatter.string(from: NSNumber(value: value)) {
            return "\(formattedValue) ₺"
        }
        
        return "\(value) ₺" // format edilmezse
    }
    
    public func fetchImage(imageUrl:String, imageName:String, imageView:UIImageView){
        if let url = URL(string: "\(imageUrl)\(imageName)") {
            DispatchQueue.main.async {
                imageView.kf.setImage(with: url)
            }
        }
    }
}
