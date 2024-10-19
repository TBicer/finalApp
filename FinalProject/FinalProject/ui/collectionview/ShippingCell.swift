import UIKit

class ShippingCell: UICollectionViewCell {
    @IBOutlet weak var addressTF: UITextField!
    
    weak var delegate: ShippingCellProtocol?

    override func awakeFromNib() {
        super.awakeFromNib()
        addressTF.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    @objc private func textFieldDidChange() {
        if let text = addressTF.text {
            delegate?.didUpdateAddress(value: text)
        }
    }
}
