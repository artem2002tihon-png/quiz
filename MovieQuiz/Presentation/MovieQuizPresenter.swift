import Foundation

final class MovieQuizPresenter {
    
    // MARK: - Properties
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var currentQuestion: QuizQuestion?
    private var correctAnswers: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticServiceProtocol = StatisticService()
    
    weak var view: MovieQuizViewControllerProtocol?
    
    // MARK: - Constants
    private enum Constants {
        static let answerDelay: Double = 1.0
        static let errorTitle = "Ошибка"
        static let retryButtonText = "Попробовать еще раз"
        static let roundFinishedTitle = "Этот раунд окончен!"
        static let playAgainButtonText = "Сыграть ещё раз"
        static let resultPrefix = "Ваш результат: "
        static let gamesCountPrefix = "Количество сыгранных КВИЗОВ: "
        static let recordPrefix = "Рекорд: "
        static let accuracyPrefix = "Средняя точность: "
    }
    
    // MARK: - Initialization
    init(view: MovieQuizViewControllerProtocol? = nil) {
        self.view = view
        self.questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        self.statisticService = StatisticService()
        loadData()
    }
    
    // MARK: - Public Methods
    func loadData() {
        view?.showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        view?.enableButtons(true)
        questionFactory?.requestNextQuestion()
    }
    
    func yesButtonClicked() {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func noButtonClicked() {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // MARK: - Convert Method
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: model.image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    // MARK: - Private Methods
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        view?.enableButtons(false)
        view?.highlightImage(isCorrect: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.answerDelay) { [weak self] in
            self?.showNextQuestionResults()
        }
    }
    
    private func showNextQuestionResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            showQuizResults()
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showQuizResults() {
        let bestGame = statisticService.bestGame
        let formattedDate = bestGame.date.dateTimeString
        
        let text = """
        \(Constants.resultPrefix)\(correctAnswers)/\(questionsAmount)
        \(Constants.gamesCountPrefix)\(statisticService.gamesCount)
        \(Constants.recordPrefix)\(bestGame.correct)/\(bestGame.total) (\(formattedDate))
        \(Constants.accuracyPrefix)\(String(format: "%.2f", statisticService.totalAccuracy))%
        """
        
        let alertModel = AlertModel(
            title: Constants.roundFinishedTitle,
            message: text,
            buttonText: Constants.playAgainButtonText,
            completion: { [weak self] in
                self?.restartGame()
            }
        )
        
        view?.showAlert(with: alertModel)
    }
}

// MARK: - QuestionFactoryDelegate
extension MovieQuizPresenter: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        
        currentQuestion = question
        
        // Используем метод convert для создания ViewModel
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.view?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        view?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        view?.hideLoadingIndicator()
        view?.showNetworkError(message: error.localizedDescription)
    }
}
