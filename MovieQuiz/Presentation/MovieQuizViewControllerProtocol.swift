import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func enableButtons(_ isEnabled: Bool)
    func highlightImage(isCorrect: Bool)
    func showAlert(with model: AlertModel)
    func showNetworkError(message: String)
}
