import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginPage: UIViewController {
    
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        setupViewDesign(view: emailView)
        setupViewDesign(view: passwordView)
        
        // Email View ve password view üzerine tıklamayı dinle
        let emailTapGesture = UITapGestureRecognizer(target: self, action: #selector(emailViewTapped))
        emailView.addGestureRecognizer(emailTapGesture)
        let passwordTapGesture = UITapGestureRecognizer(target: self, action: #selector(passwordViewTapped))
        passwordView.addGestureRecognizer(passwordTapGesture)
        
        if Auth.auth().currentUser != nil {
            goBackToPreviousView()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        emailTF.becomeFirstResponder()
        
        if let navController = navigationController {
            navController.setNavigationBarHidden(true, animated: true)
        }
        
        if Auth.auth().currentUser != nil {
            goBackToPreviousView()
        }
    }
    
    @objc func dismissKeyboard() {
        // Klavyeyi kapat
        view.endEditing(true)
    }
    
    func setupViewDesign(view:UIView){
        
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(named: "BGAccent")?.cgColor
        view.layer.masksToBounds = true

    }
    
    @objc func emailViewTapped() {
        emailTF.becomeFirstResponder()
    }
    @objc func passwordViewTapped() {
        passwordTF.becomeFirstResponder()
    }
    
    @IBAction func handleHidePassword(_ sender: UIButton) {
        passwordTF.isSecureTextEntry.toggle()

        let buttonImage = passwordTF.isSecureTextEntry ? UIImage(systemName: "eye") : UIImage(systemName: "eye.slash")
        sender.setImage(buttonImage, for: .normal)
    }
    
    @IBAction func handleLogin(_ sender: Any) {
        // Email ve şifre üzerindeki whitespace karakterlerini kaldır
        let email = emailTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let email = email, !email.isEmpty,
              let password = password, !password.isEmpty else {
            showAlert(title: "Eksik Bilgi", message: "Lütfen email ve şifrenizi doldurun.")
            return
        }

        // E-posta formatını kontrol et
        if !isValidEmail(email) {
            showAlert(title: "Geçersiz Email", message: "Lütfen geçerli bir email adresi giriniz.")
            return
        }
        
        if password.count < 6 {
            showAlert(title: "Geçersiz Şifre", message: "Şifreniz en az 6 karakter olmalıdır.")
            return
        }

        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }

            if let error = error as NSError? {
                print("Hata Kodu: \(error.code)")
                print(email)

                switch AuthErrorCode(rawValue: error.code) {
                case .wrongPassword:
                    self.resetPassword(email: email) // Şifre yanlışsa şifre sıfırlama opsiyonu ekledim
                case .invalidEmail:
                    self.showAlert(title: "Geçersiz Email", message: "Geçersiz bir email adresi girdiniz.")
                case .emailAlreadyInUse:
                    self.showAlert(title: "Email Kullanılıyor", message: "Email başkası tarafından kullanılıyor.")
                case .userNotFound:
                    self.showCreateAccount(email: email, password: password)
                default:
                    self.showAlert(title: "Hata", message: "Bir hata oluştu: \(error.localizedDescription)")
                }
                return
            }

            self.goBackToPreviousView()
        }
        
    }

    
    func showCreateAccount(email:String, password:String){
        let alertController = UIAlertController(title: "Hesap Oluştur", message: "\(email) ile bir hesap bulunamadı. Yeni bir hesap oluşturulsun mu?", preferredStyle: .actionSheet)
        
        
        alertController.addAction(UIAlertAction(title: "Hesap Oluştur", style: .default){_ in
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Hesap oluşturulamadı: \(error.localizedDescription)")
                    return
                }
                
                guard let resultUser = result?.user else {
                    print("Hesap oluşturulamadı")
                    return
                }
                
                let db = Firestore.firestore()
                
                db.collection("users")
                    .document(resultUser.uid)
                    .setData(["email":email]){ error in
                        if let error = error {
                            print("Hesap oluşturulamadı: \(error.localizedDescription)")
                            return
                        }
                    }
                DispatchQueue.main.async {
                    self.goBackToPreviousView()
                }
            }
            
        })
        
        alertController.addAction(UIAlertAction(title: "Geri Dön", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    private func resetPassword(email: String) {
        let alertController = UIAlertController(title: "Şifre Hatalı", message: "Şifrenizi yanlış girdiniz! Şifrenizi sıfırlamak ister misiniz?", preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "Şifre Sıfırla", style: .destructive) { _ in
            Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
                guard let self = self else { return }

                if let error = error {
                    self.showAlert(title: "Hata", message: "Şifre sıfırlama maili gönderilirken hata oluştu: \(error.localizedDescription)")
                } else {
                    self.showAlert(title: "Başarılı", message: "Şifre sıfırlama maili gönderildi.")
                }
            }
        })

        alertController.addAction(UIAlertAction(title: "Vazgeç", style: .cancel))
        present(alertController, animated: true)
        
    }
   
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
    
    private func goBackToPreviousView(){
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
}
