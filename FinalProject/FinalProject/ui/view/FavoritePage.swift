//
//  FavouritesPage.swift
//  FinalProject
//
//  Created by Tunay Biçer on 9.10.2024.
//

import UIKit
import RxSwift

class FavoritePage: UIViewController {
    @IBOutlet weak var favoritesTableView: UITableView!
    
    let viewModel = FavoritesPageViewModel()
    private let disposeBag = DisposeBag()
    var favoriteList : [Product] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        favoritesTableView.dataSource = self
        favoritesTableView.delegate = self
        
        viewModel.favoriteList
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] favList in
                        self?.favoriteList = favList
                        self?.favoritesTableView.reloadData()
                        print(favList)
                    })
                    .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchFavoriteProducts()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "favToDetail" {
            if let p = sender as? Product {
                let targetVC = segue.destination as! ProductDetailPage
                targetVC.product = p
            }
        }
    }
}

extension FavoritePage : UITableViewDelegate, UITableViewDataSource, ProductCellProtocol {
    func didTapAddToCart(id:Int,ad: String, resim: String, kategori: String, fiyat: Int, marka: String) {
        
        let alertController = UIAlertController(title: "Sepete Ekle", message: "Ürünü sepete ekledikten sonra favorilerden kaldırmak ister misiniz ?", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Favorilerden Kaldır", style: .destructive, handler: {[weak self]  _ in
            guard let self = self else {return}
            self.viewModel.addToCart(productId: id, ad: ad, resim: resim, kategori: kategori, fiyat: fiyat, marka: marka, siparisAdeti: 1)
            self.updateFavoriteList(productId: id)
        }))
        
        alertController.addAction(UIAlertAction(title: "Sadece Sepete Ekle", style: .default, handler: {[weak self] _ in
            guard let self = self else {return}
            self.viewModel.addToCart(productId: id, ad: ad, resim: resim, kategori: kategori, fiyat: fiyat, marka: marka, siparisAdeti: 1)
        }))
        
        present(alertController,animated: true)
    }
    
    func updateFavoriteList(productId: Int) {
        viewModel.updateFavoriteList(productId: productId) { [weak self] success in
            guard let self = self else {return}
            if success {
                print("Favori listesi başarıyla güncellendi.")
                DispatchQueue.main.async{
                    self.favoritesTableView.reloadData()
                }
            } else {
                print("Favori listesi güncellenirken hata oluştu.")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell", for: indexPath) as! FavoriteCell
        let item = favoriteList[indexPath.row]
        
        let fiyat = ProductCellFormatter.shared.formatCurrency(value: item.fiyat!)
        
        cell.productBrandLabel.text = item.marka
        cell.productPriceLabel.text = fiyat
        cell.productTitleLabel.text = item.ad
        cell.product = item
        cell.productCellProtocol = self
        ProductCellFormatter.shared.fetchImage(imageUrl: Constants.shared.imagePathURL, imageName: item.resim!, imageView: cell.productImageView)
        
        viewModel.checkIfFavorite(productId: item.id!) { isFavorite in
            DispatchQueue.main.async{
                cell.configureCell(isFavorite: isFavorite)
            }
        }
        
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = .clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = favoriteList[indexPath.row]
        performSegue(withIdentifier: "favToDetail", sender: product)
        favoritesTableView.deselectRow(at: indexPath, animated: true)
    }
}
