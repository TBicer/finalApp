import Foundation
import UIKit

class ShowAlertHelper {
    public static let shared = ShowAlertHelper()
    
    private init(){}
    
    public func showAlert(on viewController: UIViewController,title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "Devam Et", style: .cancel)
        alertController.addAction(actionCancel)
        
        viewController.present(alertController, animated: true)
    }
    
    public func showDeleteAlert(on viewController: UIViewController, title: String, message: String, yesAction: @escaping () -> Void) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let actionYes = UIAlertAction(title: "Evet", style: .destructive) { _ in
            yesAction()
        }
        
        let actionNo = UIAlertAction(title: "Hayır", style: .cancel, handler: nil)
        
        alertController.addAction(actionYes)
        alertController.addAction(actionNo)
        
        viewController.present(alertController, animated: true)
    }
}
