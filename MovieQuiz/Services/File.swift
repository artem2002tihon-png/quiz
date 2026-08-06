//
//  File.swift
//  MovieQuiz
//
//  Created by Артём Тихонов on 28.07.2026.
//


weak var delegate: QuestionFactoryDelegate?

func requestNextQuestion() {
    guard let index = (0..<questions.count).randomElement() else {
        delegate?.didReceiveNextQuestion(question: nil)
        return
    }

    let question = questions[safe: index]
    delegate?.didReceiveNextQuestion(question: question)
}
