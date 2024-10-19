import UIKit

class BrowsePage: UIViewController {
    @IBOutlet weak var browseSearchBar: UISearchBar!
    @IBOutlet weak var categoryTableView: UITableView!
    
    let viewModel = BrowsePageViewModel()
    var categoryList = [ProductCategory]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationController?.navigationBar.isHidden = true
        
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        browseSearchBar.delegate = self
        
        _ = viewModel.categoryList.subscribe(onNext: { categories in
            self.categoryList = categories
            DispatchQueue.main.async{
                self.categoryTableView.reloadData()
            }
        })
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        // Gesture recognizer sadece tableView dışında çalışacak şekilde ayarlanacak
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func dismissKeyboard() {
        // Klavyeyi kapat
        view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        if let searchTextField = browseSearchBar.value(forKey: "searchTextField") as? UITextField {
            searchTextField.frame.size.height = 76
            searchTextField.leftView = nil
            
            // İsteğe bağlı: Font boyutu veya padding ayarlamak
            searchTextField.font = UIFont.systemFont(ofSize: 18) // Örnek font boyutu
            searchTextField.textRect(forBounds: CGRect(x: 10, y: 10, width: searchTextField.frame.width, height: 76)) // Metin dikdörtgeni
            searchTextField.editingRect(forBounds: CGRect(x: 10, y: 10, width: searchTextField.frame.width, height: 76)) // Düzenleme dikdörtgeni
            
            let magnifyingGlassImage = UIImage(systemName: "magnifyingglass") // Sistem simgesini kullan
            let magnifyingGlassView = UIImageView(image: magnifyingGlassImage)
            magnifyingGlassView.contentMode = .scaleAspectFit
            magnifyingGlassView.frame = CGRect(x: 0, y: 0, width: 24, height: 24) // Boyutu ayarlayın

            magnifyingGlassView.tintColor = UIColor(named: "ContentSecondary")
            
            searchTextField.rightView = magnifyingGlassView
            searchTextField.rightViewMode = .always // Her zaman göster
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toProductList" {
            if let cat = sender as? ProductCategory {
                let targetVC = segue.destination as! ProductListPage
                targetVC.category = cat
            }
        }
    }
    
}

extension BrowsePage : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchCategory(searchText: searchText.lowercased())
    }
}

extension BrowsePage : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryTableCell") as! CategoryTableCell
        let category = categoryList[indexPath.row]
        
        cell.catNameLabel.text = category.title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categoryList[indexPath.row]
        performSegue(withIdentifier: "toProductList", sender: category)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}
