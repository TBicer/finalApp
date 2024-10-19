import UIKit
import RxSwift

class CheckoutPage: UIViewController {
    @IBOutlet weak var checkoutCollectionView: UICollectionView!
    @IBOutlet weak var orderTotalLabel: UILabel!
    @IBOutlet weak var cargoPriceLabel: UILabel!
    
    let viewModel = CheckoutPageViewModel()
    var addressSection = [1]
    var selectedAddress:String?
    var orderProducts = [ProductFirebase]()
    var sections: [CheckoutSection] = []
    var cargoPrice: Int?
    var cartTotal: Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateSections()
        handlePriceLabels()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        checkoutCollectionView.dataSource = self
        checkoutCollectionView.delegate = self
        checkoutCollectionView.collectionViewLayout = createLayout()
        checkoutCollectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateSections()
        handlePriceLabels()
    }
    
    @objc func dismissKeyboard() {
        // Klavyeyi kapat
        view.endEditing(true)
    }
    
    func handlePriceLabels() {
        if let cPrice = cargoPrice,
           let cTotal = cartTotal {
            let cartTotalFormatted = ProductCellFormatter.shared.formatCurrency(value: cTotal)
            orderTotalLabel.text = cartTotalFormatted
            
            if cPrice == 0 {
                cargoPriceLabel.text = "Ücretsiz"
            } else {
                let cargoPriceFormatted = ProductCellFormatter.shared.formatCurrency(value: cPrice)
                cargoPriceLabel.text = cargoPriceFormatted
            }
        }
    }
    
    func checkAddress() -> String {
        if let address = selectedAddress {
            if address.count < 10 {
                ShowAlertHelper.shared.showAlert(on: self, title: "Hata", message: "Girilen adres 10 karakterden daha uzun olmalıdır.")
            }else {
                return address
            }
        }else {
            ShowAlertHelper.shared.showAlert(on: self, title: "Hata", message: "Adres alanınız boş yada hatalı bir veri girdiniz.")
        }
        return ""
    }
    
    @IBAction func handleProceed(_ sender: Any) {
        guard let cPrice = cargoPrice,
              let cTotal = cartTotal else {
            return
        }

        let order = Order(products: orderProducts, address: checkAddress(), cartTotal: cTotal, cargoPrice: cPrice)
        
        let alertController = UIAlertController(title: "Siparişi Tamamla", message: "Siparinizi tamamlamak istediğinize emin misiniz?", preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Evet", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.viewModel.createOrderToFirebase(order: order) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success:
                    self.navigationController?.popToRootViewController(animated: true)
                case .failure(let error):
                    ShowAlertHelper.shared.showAlert(on: self, title: "Hata", message: "Sipariş oluşturulamadı: \(error.localizedDescription)")
                }
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Hayır", style: .cancel))
        
        present(alertController, animated: true)

    }
    
    private func updateSections() {
        sections = [
            .shippingAddress(addressSection),
            .products(orderProducts)
        ]
        checkoutCollectionView.reloadData()
   }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let section = self.sections[sectionIndex]
            
            switch section {
            case .shippingAddress:
                let screenSize = UIScreen.main.bounds.width
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(screenSize), heightDimension: .absolute(100))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.contentInsets = .init(top: 0, leading: 27, bottom: 0, trailing: 27)
                
                let section = NSCollectionLayoutSection(group: group)
//                section.interGroupSpacing = 10
                section.orthogonalScrollingBehavior = .groupPagingCentered
                section.boundarySupplementaryItems = [self.supplementaryHeaderItem()]
                
                return section
                
            case .products:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 5, bottom: 10, trailing: 5)
                

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(100))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
                group.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
                
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 5 // Satırlar arasındaki boşluk
                section.boundarySupplementaryItems = [self.supplementaryHeaderItem()]
                
                return section
            }
        }
    }
    
    private func supplementaryHeaderItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(40)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
    }
}

extension CheckoutPage : UICollectionViewDelegate, UICollectionViewDataSource, ShippingCellProtocol {
    func didUpdateAddress(value: String) {
        selectedAddress = value
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch sections[indexPath.section] {
            case .shippingAddress(let items):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "shippingCell", for: indexPath) as! ShippingCell
                
                cell.delegate = self
                return cell
                
            case .products(let items):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "orderProductCell", for: indexPath) as! OrderProductCell
                let item = items[indexPath.row]
                
                let productPrice = item.fiyat! * item.siparisAdeti!
                let fiyat = ProductCellFormatter.shared.formatCurrency(value: productPrice)
                
                cell.productBrandLabel.text = item.marka
                cell.productPriceLabel.text = fiyat
                cell.productTitleLabel.text = item.ad
                cell.productQuantityLabel.text = String(item.siparisAdeti!)
                
                ProductCellFormatter.shared.fetchImage(imageUrl: Constants.shared.imagePathURL, imageName: item.resim!, imageView: cell.productImageView)
                
                cell.selectedBackgroundView = UIView()
                cell.selectedBackgroundView?.backgroundColor = .clear
                
                return cell
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "checkoutTitleReusableView", for: indexPath) as! CheckoutTitleReusableView
            header.setup(sections[indexPath.section].title)
            return header
        default:
            return UICollectionReusableView()
        }
    }
    
}
