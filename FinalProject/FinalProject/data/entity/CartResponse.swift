//
//  FetchCartResponse.swift
//  FinalProject
//
//  Created by Tunay Biçer on 11.10.2024.
//

import Foundation

class CartResponse : Codable {
    var urunler_sepeti:[CartItem]?
    var success:Int?
}
