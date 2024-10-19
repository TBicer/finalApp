import Foundation

enum CheckoutSection {
    case shippingAddress([Int]) // Burada Int olarak bırakabilirsiniz, ya da Address gibi bir model de kullanabilirsiniz.
    case products([ProductFirebase])
    
    var items: [Any] {
        switch self {
        case .shippingAddress(let addresses):
            return addresses
        case .products(let products):
            return products
        }
    }
    
    var count: Int {
        switch self {
        case .shippingAddress:
            return 1 // Shipping address için sabit olarak 1 döndür
        case .products(let products):
            return products.count
        }
    }
    
    var title: String {
        switch self {
        case .shippingAddress:
            return "Sipariş Adresi"
        case .products:
            return "Siparişteki Ürünler"
        }
    }
}
