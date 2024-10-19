import Foundation

class CartResponse : Codable {
    var urunler_sepeti:[CartItem]?
    var success:Int?
}
