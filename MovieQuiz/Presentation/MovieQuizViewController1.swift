import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var gamesCount = 0
    private var bestScore = 0
    private var bestScoreData = ""
    private var totalCorrectAnswers = 0
    private let questions: [QuizQuestion] = [
        QuizQuestion(imageName: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(imageName: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(imageName: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(imageName: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(imageName: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(imageName: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(imageName: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(imageName: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(imageName: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(imageName: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
    ]
    override func viewDidLoad() { // Life
        super.viewDidLoad()
        let firstQuestion = questions[currentQuestionIndex]
        let viewModel = convert (model: firstQuestion)
        show (quiz: viewModel)
    }
    @IBAction func noButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    @IBAction func yesButtonClicked(_ sender: UIButton) {
        showAnswerResult(isCorrect: questions[currentQuestionIndex].correctAnswer)
    }
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        yesButton.isEnabled = false
        noButton.isEnabled = false
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor: UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 20
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionResults()
        }
    }
    private func showNextQuestionResults() {
        if currentQuestionIndex == questions.count - 1 {
            gamesCount += 1
            totalCorrectAnswers += correctAnswers
            if correctAnswers >= bestScore {
                bestScore = correctAnswers
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
                bestScoreData = dateFormatter.string(from: Date())
            }
        let totalQuestionAsked = gamesCount * questions.count
            let averageScore = Double(totalCorrectAnswers) / Double(totalQuestionAsked) * 100
            let text = """
            Ваш результат: \(correctAnswers)/\(questions.count)
            Количество сыгранных квизов: \(gamesCount)
            Рекорд: \(bestScore)/\(questions.count) (\(bestScoreData))
            Средняя точность:   \(String(format: "%.2f", averageScore))%
            """
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel) // 3
        } else {
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            show(quiz: viewModel)
            imageView.layer.borderWidth = 0
        }
    }
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionImage = UIImage(named: model.imageName) ?? UIImage()
        return QuizStepViewModel (
            image: questionImage,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
    }
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) { [self] _ in
            currentQuestionIndex = 0
            correctAnswers = 0
            let firstQuestion = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQuestion)
            show(quiz: viewModel)
            imageView.layer.borderWidth = 0
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    private func showNetworkError(message: String) {
        imageView.layer.borderWidth = 0
        let viewModel = QuizResultsViewModel(title: "Что-то пошло не так(", text: message, buttonText: "Попробовать еще раз")
        show(quiz: viewModel)
    }
    private struct QuizStepViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
    private struct QuizQuestion {
        let imageName: String
        let text: String
        let correctAnswer: Bool
    }
    private struct QuizResultsViewModel {
        let title: String
        let text: String
        let buttonText: String
    }
}


/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
*/
