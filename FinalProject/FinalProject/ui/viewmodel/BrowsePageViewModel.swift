import Foundation
import UIKit
import RxSwift

class BrowsePageViewModel {
    let repo = ProductRepository()
    var categoryList = BehaviorSubject<[ProductCategory]>(value: [ProductCategory]())
    
    init(){
        categoryList = repo.categoryList
    }
    
    func searchCategory(searchText:String){
        repo.searchCategory(searchText: searchText)
    }
}
