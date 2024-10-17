//
//  Category.swift
//  FinalProject
//
//  Created by Tunay Biçer on 11.10.2024.
//

import Foundation

struct ProductCategory: Hashable {
    var catId: Int?
    var title: String?
    
    static func ==(lhs: ProductCategory, rhs: ProductCategory) -> Bool {
        return lhs.title == rhs.title
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title) // Hash based on title
    }
}
