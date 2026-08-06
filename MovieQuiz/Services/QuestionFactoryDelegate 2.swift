//
//  QuestionFactoryDelegate 2.swift
//  MovieQuiz
//
//  Created by Артём Тихонов on 29.07.2026.
//


protocol QuestionFactoryDelegate: AnyObject {               // 1
    func didReceiveNextQuestion(question: QuizQuestion?)    // 2
}