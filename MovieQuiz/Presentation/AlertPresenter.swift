import UIKit

class AlertPresenter {

    let alertModel: AlertModel
    weak var viewController: UIViewController?
    init(alertModel: AlertModel, viewController: UIViewController) {
        self.alertModel = alertModel
        self.viewController = viewController
    }
    
    func showAlert(_ alertModel: AlertModel) {
        
        let alert = UIAlertController(title: alertModel.title,
                                      message: alertModel.message,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            alertModel.completion()
        }
        
        guard let viewController = viewController else { return }
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
        
    }
}

