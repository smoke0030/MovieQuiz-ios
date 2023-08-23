import UIKit
import Foundation

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    // MARK: - IBOutlet
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet weak var noButtonLabel: UIButton!
    @IBOutlet weak var yesButtonLabel: UIButton!
    
    // MARK: - Private var's
    
    private var presenter: MovieQuizPresenter!
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let alertPresenter = AlertPresenter(viewController: self)
        presenter = MovieQuizPresenter(viewController: self, alertPresenter: alertPresenter)
        textLabel.text = "Hello"
        imageView.layer.cornerRadius = 20
        centeringAndShowActivityIndicator()
    }
    
    //MARK: methods
    func centeringAndShowActivityIndicator() {
        imageView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        activityIndicator.color = UIColor.ypGray
        activityIndicator.hidesWhenStopped = true
        showLoadingIndicator()
    }
    
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
        presenter.showNetworkError(message: message)
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {
        presenter.show(quiz: result)
    }
    
    // MARK: - IBAction
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    
    
}
