import UIKit

final class AlertPresenter: AlertPresenterProtocol {

    weak var viewController: UIViewController?
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func showAlert(_ alertModel: AlertModel) {
        
        let alert = UIAlertController(title: alertModel.title,
                                      message: alertModel.message,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            alertModel.completion()
        }
        
        alert.view.accessibilityIdentifier = "Alert"
        guard let viewController = viewController else { return }
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
        
    }
}

