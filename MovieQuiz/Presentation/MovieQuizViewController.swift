import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    // MARK: - Outlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    private var presenter: MovieQuizPresenter!
    private var alertPresenter: ResultAlertPresenter?
    
    // MARK: - Constants
    private enum Constants {
        static let cornerRadius: Double = 20
        static let borderWidth: Double = 8
        static let errorTitle = "Ошибка"
        static let retryButtonText = "Попробовать еще раз"
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Setup
    private func setup() {
        imageView.layer.cornerRadius = Constants.cornerRadius
        alertPresenter = ResultAlertPresenter()
        presenter = MovieQuizPresenter(view: self)
    }
    
    // MARK: - Actions
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
    }
    
    // MARK: - MovieQuizViewControllerProtocol
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderWidth = 0
        imageView.image = UIImage(data: step.image) ?? UIImage()
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        enableButtons(true)
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func enableButtons(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    func highlightImage(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = Constants.borderWidth
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = Constants.cornerRadius
    }
    
    func showAlert(with model: AlertModel) {
        alertPresenter?.show(in: self, model: model)
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: Constants.errorTitle,
            message: message,
            buttonText: Constants.retryButtonText,
            completion: { [weak self] in
                self?.presenter.restartGame()
            }
        )
        
        alertPresenter?.show(in: self, model: alertModel)
    }
}
