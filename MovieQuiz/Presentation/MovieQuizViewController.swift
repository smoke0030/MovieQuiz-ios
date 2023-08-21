import UIKit
import Foundation

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    // MARK: - IBOutlet
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet weak var noButtonLabel: UIButton!
    @IBOutlet weak var yesButtonLabel: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private var's
    
    private var presenter: MovieQuizPresenter!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        textLabel.text = "Hello"
        imageView.layer.cornerRadius = 20
        activityIndicator.hidesWhenStopped = true
        showLoadingIndicator()
        
    }
    
    // MARK: - Private Methods
    private func sendFirstRequest() {
        ///проверяем является ли строка адресом
        guard let url = URL(string: "https://imdb-api.com/en/API/MostPopularTVs/k_zcuw1ytf") else { return }
        ///создаем запрос
        let request = URLRequest(url: url)
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request) {data, response,error in
            
        }
        task.resume()
    }
    
    //MARK: methods
    
    func higlightImageBorder(isCorrectAnswer: Bool) {
        yesButtonLabel.isEnabled = false
        noButtonLabel.isEnabled = false
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func deselectImageBorder() {
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
        yesButtonLabel.isEnabled = true
        noButtonLabel.isEnabled = true
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    func showNetworkError(message: String) {
        let completion = { [weak self] in
            guard let self = self else { return }
            self.presenter.restartGame()
            
        }
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз",
                               completion: completion)
        let alertPresenter = AlertPresenter(alertModel: model, viewController: self)
        alertPresenter.showAlert(model)
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let message = presenter.makeResultsMessage()
        
        let completion = { [weak self] in
            guard let self = self else { return }
            self.presenter.restartGame()
            
        }
        
        let alertModel = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText,
            completion: completion)
        let alertPresenter = AlertPresenter(alertModel: alertModel, viewController: self)
        alertPresenter.showAlert(alertModel)
    }
    
    
    // MARK: - IBAction
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    
    
}
