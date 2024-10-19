import Foundation

class CheckoutPageViewModel {
    let cartRepository = CartRepository()
    
    func createOrderToFirebase(order: Order, completion: @escaping (Result<Void, Error>) -> Void) {
        cartRepository.createOrderToFirebase(order: order) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.cartRepository.clearCartForFirebase { [weak self] success in
                    guard let self = self else { return }
                    if success {
                        self.cartRepository.removeAllFromCartAPI { _ in
                            completion(.success(())) // Void success durumu
                        }
                    } else {
                        completion(.failure(NSError(domain: "ClearCartError", code: -1, userInfo: nil)))
                    }
                }
            case .failure(let error):
                completion(.failure(error)) // Hata durumunda dönecek error
            }
        }
    }
}
