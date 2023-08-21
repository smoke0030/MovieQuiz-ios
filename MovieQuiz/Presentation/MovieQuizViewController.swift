import UIKit
import Foundation

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet weak var noButtonLabel: UIButton!
    @IBOutlet weak var yesButtonLabel: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    struct Actor: Codable {
        let id: String
        let image: String
        let name: String
        let asCharacter: String
    }
    
    struct Movie: Codable {
        let id: String
        let rank: String
        let title: String
        let fullTitle: String
        let year: String
        let image: String
        let crew: String
        let imDbRating: String
        let imDbRatingCount: String
    }
    
    struct Top: Decodable {
        let items: [Movie]
    }
    // MARK: - Private var's
    ///текущий вопрос
    private var statisticService: StatisticService = StatisticServiceImplementation()
    private var presenter: MovieQuizPresenter!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        presenter.viewController = self
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
        let completion = { [weak self] in
            guard let self = self else { return }
            self.presenter.restartGame()
            
        }
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: completion)
        let alertPresenter = AlertPresenter(alertModel: alertModel, viewController: self)
        alertPresenter.showAlert(alertModel)
    }
    
    func showAnswerResult(isCorrect: Bool) {
        presenter.didAnswer(isCorrectAnswer: isCorrect )
        yesButtonLabel.isEnabled = false
        noButtonLabel.isEnabled = false
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.presenter.showNextQuestionOrResult()
            self.imageView.layer.borderWidth = 0
            self.imageView.layer.borderColor = nil
            self.yesButtonLabel.isEnabled = true
            self.noButtonLabel.isEnabled = true
        }
    }
    
    private func showNextQuestionOrResult() {
        if presenter.isLastQuestion() {
            
            statisticService.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
            
            let bestGame = statisticService.bestGame
            
            let text = """
Ваш результат: \(presenter.correctAnswers)/10
Количество сыгранных игр: \(statisticService.gamesCount)
Рекордная игра: \(bestGame.correct)/\(bestGame.total) \(bestGame.date)
Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
"""
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
            
        } else {
            presenter.switchToNextQuestion()
            
        }
    }
    
    // MARK: - IBAction
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
}
