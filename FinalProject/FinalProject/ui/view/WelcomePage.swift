import UIKit
import RxSwift
import FirebaseAuth
import FirebaseFirestore

class WelcomePage: UIViewController {
    @IBOutlet weak var homeCollectionView: UICollectionView!
    
    
    
    let viewModel = WelcomePageViewModel()
    var dealSliderList = [Product]()
    var recommendList = [Product]()
    var sections: [HomeSection] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeCollectionView.dataSource = self
        homeCollectionView.delegate = self
        homeCollectionView.collectionViewLayout = createLayout()
        
        handleUsernamePrint()
        
        _ = viewModel.dealSliderList
            .subscribe(onNext: { [weak self] deals in
                self?.dealSliderList = deals
                self?.updateSections()
            })
        
        _ = viewModel.recommendList
            .subscribe(onNext: { [weak self] deals in
                self?.recommendList = deals
                self?.updateSections()
            })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        handleUsernamePrint()
        DispatchQueue.main.async {
            self.homeCollectionView.reloadData()
        }
    }
    
    func handleUsernamePrint(){
        if let username = Auth.auth().currentUser?.displayName {
            navigationItem.title = "Hoşgeldin, \(username)"
        } else {
            navigationItem.title = "Hoşgeldin"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeToDetail" {
            if let pro = sender as? Product {
                let targetVC = segue.destination as! ProductDetailPage
                targetVC.product = pro
            }
        }
    }
    
    private func updateSections() {
       sections = [
           .deals(dealSliderList),
           .recommend(recommendList)
       ]
       homeCollectionView.reloadData() // UICollectionView'u güncelle
   }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
            guard let self = self else { return nil}
            let section = self.sections[sectionIndex]
            
            switch section {
            case .deals:
                // Deal bölümü için Compositional Layout
                let screenSize = UIScreen.main.bounds.width
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15)

                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(screenSize), heightDimension: .absolute(180))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.orthogonalScrollingBehavior = .groupPagingCentered
                section.boundarySupplementaryItems = [supplementaryHeaderItem()]
                section.contentInsets = .init(top: 0, leading: 0, bottom: 20, trailing: 0)
                
                return section
            case .recommend:
                // Recommend bölümü için Compositional Layout
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(255))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
                group.contentInsets = .init(top: 0, leading: 10, bottom: 0, trailing: 10)
                
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 5 // Satırlar arasındaki boşluk
                section.boundarySupplementaryItems = [supplementaryHeaderItem()]
                
                return section
            }
        }
    }
    
    private func supplementaryHeaderItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(40)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
    }
    
    
}

extension WelcomePage: UICollectionViewDelegate, UICollectionViewDataSource, ProductCellProtocol {
    func updateFavoriteList(productId: Int) {
        viewModel.updateFavoriteList(productId: productId) { [weak self] success in
            guard let self = self else {return}
            if success {
                print("Favori listesi başarıyla güncellendi.")
                DispatchQueue.main.async{
                    self.homeCollectionView.reloadData()
                }
            } else {
                print("Favori listesi güncellenirken hata oluştu.")
            }
        }
    }
    
    func didTapAddToCart(id:Int, ad: String, resim: String, kategori: String, fiyat: Int, marka: String) {
        viewModel.addToCart(productId: id,ad: ad, resim: resim, kategori: kategori, fiyat: fiyat, marka: marka, siparisAdeti: 1)
        ShowAlertHelper.shared.showAlert(on: self, title: "Sepete Eklendi", message: "\(ad) sepetinize eklendi!")
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch sections[indexPath.section]{
        case .deals(let items):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dealsCell", for: indexPath) as! DealsCell
            let item = items[indexPath.row]
            
            let fiyat = ProductCellFormatter.shared.formatCurrency(value: item.fiyat!)
            
            cell.productId = item.id
            cell.productBrandLabel.text = item.marka
            cell.productPriceLabel.text = fiyat
            cell.productTitleLabel.text = item.ad
            cell.productCellProtocol = self
            ProductCellFormatter.shared.fetchImage(imageUrl: Constants.shared.imagePathURL, imageName: item.resim!, imageView: cell.productImageView)
            
            viewModel.checkIfFavorite(productId: item.id!) { isFavorite in
                DispatchQueue.main.async{
                    cell.configureCell(isFavorite: isFavorite)
                }
            }
            
            return cell
        case .recommend(let items):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recListCell", for: indexPath) as! RecListCell
            let item = items[indexPath.row]
            
            let fiyat = ProductCellFormatter.shared.formatCurrency(value: item.fiyat!)
            
            cell.product = item
            cell.productPriceLabel.text = fiyat
            cell.productTitleLabel.text = item.ad
            cell.productBrandLabel.text = item.marka
            cell.productCellProtocol = self
            ProductCellFormatter.shared.fetchImage(imageUrl: Constants.shared.imagePathURL, imageName: item.resim!, imageView: cell.productImageView)
            
            viewModel.checkIfFavorite(productId: item.id!) { isFavorite in
                DispatchQueue.main.async{
                    cell.configureCell(isFavorite: isFavorite)
                }
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "homeReusableTitleCell", for: indexPath) as! HomeReusableTitleCell
            header.setup(sections[indexPath.section].title)
            return header
        default:
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var product:Product?
        
        switch sections[indexPath.section]{
        case .deals:
            product = dealSliderList[indexPath.row]
        case .recommend:
            product = recommendList[indexPath.row]
            
        }
        performSegue(withIdentifier: "homeToDetail", sender: product)
        homeCollectionView.deselectItem(at: indexPath, animated: true)
    }
}
