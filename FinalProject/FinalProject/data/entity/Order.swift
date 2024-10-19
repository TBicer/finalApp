import Foundation

class Order: Codable {
    var products: [ProductFirebase]?
    var address: String?
    var cartTotal:Int?
    var cargoPrice:Int?
    
    init(products: [ProductFirebase], address: String,cartTotal:Int,cargoPrice:Int) {
        self.products = products
        self.address = address
        self.cartTotal = cartTotal
        self.cargoPrice = cargoPrice
    }

}
