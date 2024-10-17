//
//  ProductCellProtocol.swift
//  FinalProject
//
//  Created by Tunay Biçer on 17.10.2024.
//

import Foundation

protocol ProductCellProtocol {
    func didTapFavButton()
    func didTapAddToCart(ad: String, resim: String, kategori: String, fiyat: Int, marka: String)
}
