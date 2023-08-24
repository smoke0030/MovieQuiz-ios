import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    //MARK: private vars
    
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers = 0
    
    private var statisticService: StatisticService?
    private var currentQuestion: QuizQuestion?
    private var questionFactory: QuestionFactoryProtocol?
    private var view: MovieQuizViewControllerProtocol
    private var alertPresenter: AlertPresenterProtocol
    
    lazy var message = makeResultsMessage()
    
    init(view: MovieQuizViewControllerProtocol, alertPresenter: AlertPresenterProtocol) {
        self.view = view
        self.alertPresenter = alertPresenter
        self.statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        view.showLoadingIndicator()
    }
    
    func makeResultsMessage() -> String {
        guard let statisticService = statisticService else { return "" }
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let bestGame = statisticService.bestGame
        
        let totalPlayCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)" + " \(bestGame.date)"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let resultMessage = [currentGameResultLine, totalPlayCountLine, bestGameInfoLine, averageAccuracyLine].joined(separator: "\n")
        return resultMessage
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    // MARK: QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        view.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        view.showNetworkError(message: message)
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func showNetworkError(message: String) {
        let completion = { [weak self] in
            guard let self = self else { return }
            questionFactory?.loadData()
            restartGame()
            
        }
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз",
                               completion: completion)
        
        alertPresenter.showAlert(model)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.view.show(quiz: viewModel)
        }
    }
    
    private func proceedToNextQuestionOrResult() {
        if self.isLastQuestion() {
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: message,
                buttonText: "Сыграть ещё раз")
            view.show(quiz: viewModel)
            
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func show(quiz result: QuizResultsViewModel) {
        
        let completion = { [weak self] in
            guard let self = self else { return }
            self.restartGame()
        }
        
        let alertModel = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText,
            completion: completion)
        alertPresenter.showAlert(alertModel)
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect )
        view.higlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResult()
            view.deselectImageBorder()
        }
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
}

