import UIKit
import Foundation

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate{
    
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
    
    ///переменная с индексом текущего вопроса
    private var currentQuestionIndex = 0
    ///переменная со счетчиком правильных ответов
    private var correctAnswers = 0
    ///переменная количества вопросов
    private let questionsAmount = 10
    ///обращение к протоколу фабрики вопросов
    private var questionFactory: QuestionFactoryProtocol?
    ///текущий вопрос
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService = StatisticServiceImplementation()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.text = "Hello"
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        showLoadingIndicator()
        questionFactory?.loadData()
        questionFactory?.requestNextQuestion()
        
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
        
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        show(quiz: viewModel)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
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
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    private func showNetworkError(message: String) {
        let complition = { [weak self] in
            guard let self = self else { return }
            self.questionFactory?.loadData()
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз",
                                completion: complition)
        let alertPresenter = AlertPresenter(alertModel: model, viewController: self)
        alertPresenter.showAlert(model)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let completion = { [weak self] in
            self?.currentQuestionIndex = 0
            self?.correctAnswers = 0
            self?.questionFactory?.requestNextQuestion()
        }
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: completion)
        let alertPresenter = AlertPresenter(alertModel: alertModel, viewController: self)
        alertPresenter.showAlert(alertModel)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect == true {
            correctAnswers += 1
        }
        yesButtonLabel.isEnabled = false
        noButtonLabel.isEnabled = false
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResult()
            self.imageView.layer.borderWidth = 0
            self.imageView.layer.borderColor = nil
            self.yesButtonLabel.isEnabled = true
            self.noButtonLabel.isEnabled = true
        }
    }
    
    private func showNextQuestionOrResult() {
        if currentQuestionIndex == questionsAmount - 1 {
            
                statisticService.store(correct: correctAnswers, total: questionsAmount)
                
                let bestGame = statisticService.bestGame
                
                let text = """
Ваш результат: \(correctAnswers)/10
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
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
            
        }
    }
    
    // MARK: - IBAction
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
}
