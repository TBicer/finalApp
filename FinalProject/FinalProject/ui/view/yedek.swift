//import UIKit
//import RxSwift
//
//class HomePage: UIViewController {
//    @IBOutlet weak var dealCollectionView: UICollectionView!
//
//    let viewModel = HomePageViewModel()
//    var dealSliderList = [Product]()
//    var timer: Timer?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        dealCollectionView.delegate = self
//        dealCollectionView.dataSource = self
//
//        designCells()
//
//        _ = viewModel.dealSliderList
//            .subscribe(onNext: { [weak self] deals in
//                self?.dealSliderList = deals
//                self?.dealCollectionView.reloadData() // CollectionView'i güncelle
//                self?.startCarousel()
//            })
//    }
//
//
//    func designCells(){
//        // ürünler collection view
//        let dealDesign = UICollectionViewFlowLayout()
//        dealDesign.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//        dealDesign.minimumInteritemSpacing = 10
//        dealDesign.minimumLineSpacing = 10
//        dealDesign.itemSize = CGSize(width: 335, height: 170)
//        dealDesign.scrollDirection = .horizontal
//        dealCollectionView.collectionViewLayout = dealDesign
//    }
//
//    func startCarousel() {
//        // Eğer timer zaten çalışıyorsa, onu geçersiz kıl
//        timer?.invalidate()
//
//        // Timer'ı başlat
//        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
//            guard let strongSelf = self else { return }
//            let currentIndex = strongSelf.dealCollectionView.contentOffset.x / strongSelf.dealCollectionView.frame.width
//            let nextIndex = Int(currentIndex) + 1
//
//            // Eğer son elemeye ulaştıysak, başa dön
//            if nextIndex >= strongSelf.dealSliderList.count {
//                // Burada animasyonsuz başa döndürme işlemi yapıyoruz
//                strongSelf.dealCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
//                strongSelf.dealCollectionView.setContentOffset(CGPoint.zero, animated: false)
//            } else {
//                strongSelf.dealCollectionView.scrollToItem(at: IndexPath(item: nextIndex, section: 0), at: .left, animated: true)
//            }
//        }
//    }
//
//    deinit {
//        // Timer'ı temizle
//        timer?.invalidate()
//    }
//
//
//}
//
//extension HomePage : UICollectionViewDelegate, UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        switch collectionView.tag{
//        case 1:
//            return dealSliderList.count
//        case 2:
//            return 0
//        default:
//            return 0
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        switch collectionView.tag{
//        case 1:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dealsCell", for: indexPath) as! DealsCell
//            let deal = dealSliderList[indexPath.row]
//
//            cell.productBrandLabel.text = deal.marka
//            cell.productPriceLabel.text = "\(deal.fiyat!)₺"
//            cell.productTitleLabel.text = deal.ad
//            viewModel.fetchImage(imageUrl: "http://kasimadalan.pe.hu/urunler/resimler/", imageName: deal.resim!, imageView: cell.productImageView)
//
//            return cell
//        case 2:
//            return UICollectionViewCell()
//        default:
//            return UICollectionViewCell()
//        }
//    }
//
//}
