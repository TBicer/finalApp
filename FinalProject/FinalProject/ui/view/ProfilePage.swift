import UIKit
import FirebaseAuth
import Kingfisher

class ProfilePage: UIViewController {
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var imageURLTF: UITextField!
    @IBOutlet weak var imageBGView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        handleUsernamePrint()
        fetchImage()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Auth.auth().currentUser == nil {
            performSegue(withIdentifier: "profileToLogin", sender: nil)
        }
        
        handleUsernamePrint()
        fetchImage()
    }
    
    @objc func dismissKeyboard() {
        // Klavyeyi kapat
        view.endEditing(true)
    }
    
    func handleUsernamePrint(){
        if let username = Auth.auth().currentUser?.displayName {
            welcomeLabel.text = "Hoş geldin, \(username)!"
            nameTF.text = ""
        } else {
            welcomeLabel.text = "Hoş geldin!"
            nameTF.text = ""
        }
    }
    
    func fetchImage() {
        if let user = Auth.auth().currentUser, let url = user.photoURL {
            // Kullanıcı giriş yapmış ve profil resmi mevcut
            DispatchQueue.main.async {
                self.profileImageView.kf.setImage(with: url)
                self.imageBGView.backgroundColor = UIColor.clear // Arka planı transparan yap
            }
        } else {
            // Kullanıcı giriş yapmamış veya profil fotoğrafı yok
            DispatchQueue.main.async {
                self.profileImageView.image = UIImage(systemName: "person.fill")
                self.imageBGView.backgroundColor = UIColor(named: "BGAccent") // BGAccent rengini kullan
            }
        }
    }
    
    @IBAction func handleImageChange(_ sender: Any) {
        guard let imageURL = imageURLTF.text, !imageURL.isEmpty else {
            ShowAlertHelper.shared.showAlert(on: self, title: "Hata", message: "Geçerli link girmediniz yada boş bıraktınız!")
            return
        }
        
        let url = URL(string: imageURL)
        
        if let user = Auth.auth().currentUser {
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.photoURL = url
            changeRequest.commitChanges { error in
                if let error = error {
                    print("Profil güncellenirken hata oluştu: \(error.localizedDescription)")
                } else {
                    ShowAlertHelper.shared.showAlert(on: self, title: "Başarılı", message: "Profil resminiz güncellendi.")
                    self.imageURLTF.text = ""
                    self.fetchImage()
                }
            }
        }else {
            print("Kullanıcı Oturum Açmamış")
        }
    }
    
    
    @IBAction func handleSaveCredentials(_ sender: Any) {
        guard let newName = nameTF.text, !newName.isEmpty else {
            ShowAlertHelper.shared.showAlert(on: self, title: "Hata", message: "Geçerli bir isim girmediğiniz yada boş bıraktınız!")
            return
        }
        
        if let user = Auth.auth().currentUser {
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = newName // Kullanıcıdan alınan yeni isim
            changeRequest.commitChanges { error in
                if let error = error {
                    print("Profil güncellenirken hata oluştu: \(error.localizedDescription)")
                } else {
                    ShowAlertHelper.shared.showAlert(on: self, title: "Başarılı", message: "Adınız '\(newName)' olarak sistemimizde başarıyla güncellendi.")
                    self.welcomeLabel.text = "Hoş geldin, \(newName)!" // Ekranda yeni adı göster
                }
            }
        } else {
            print("Kullanıcı oturum açmamış.")
        }
    }
    

    @IBAction func handleLogOut(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            performSegue(withIdentifier: "profileToLogin", sender: nil)
        }catch let error {
            print(error.localizedDescription)
        }
    }
}
