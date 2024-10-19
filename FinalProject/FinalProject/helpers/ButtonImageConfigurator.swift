import UIKit

class ButtonImageConfigurator {
    
    public static let shared = ButtonImageConfigurator()
    
    private init(){}
    
    public func configureHeartButton(_ button: UIButton, isFavorite: Bool) {
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium) // Boyut ve ağırlık ayarları
        
        if isFavorite {
            button.setImage(UIImage(systemName: "heart.fill")?.withConfiguration(symbolConfiguration), for: .normal) // Doldurulmuş kalp simgesi
        } else {
            button.setImage(UIImage(systemName: "heart")?.withConfiguration(symbolConfiguration), for: .normal) // Boş kalp simgesi
        }
        
        // Eğer gerekiyorsa butonun içerik modunu ayarlama
        button.imageView?.contentMode = .scaleAspectFit
    }
}

