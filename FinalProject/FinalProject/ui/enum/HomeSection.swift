import Foundation

enum HomeSection{
    case deals([Product])
    case recommend([Product])
    
    var items: [Product]{
        switch self{
        case .deals(let items),
                .recommend(let items):
            return items
        }
    }
    
    var count: Int {
        return items.count
    }
    
    var title:String {
        switch self {
        case .deals: return "Günün Ürünleri"
        case .recommend: return "Tavsiye Edilen Ürünler"
        }
    }
}
