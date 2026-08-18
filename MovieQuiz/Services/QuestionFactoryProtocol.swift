import UIKit

protocol QuestionFactoryProtocol {
    func requestNextQuestion(at index: Int)
    func setup(delegate: QuestionFactoryDelegate)
}
