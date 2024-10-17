//
//  HomeReusableTitleCell.swift
//  FinalProject
//
//  Created by Tunay Biçer on 16.10.2024.
//

import UIKit

class HomeReusableTitleCell: UICollectionReusableView {
    @IBOutlet weak var cellTitleLbl: UILabel!
    
    func setup(_ title:String){
        cellTitleLbl.text = title
    }
    
}
