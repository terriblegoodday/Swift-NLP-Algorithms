//
//  ViterbiAlgorithmTests.swift
//  Swift-NLP-AlgorithmsTests
//
//  Created by Eduard Dzhumagaliev on 01.04.2024.
//

import XCTest
@testable import Swift_NLP_Algorithms

final class ViterbiAlgorithmTests: XCTestCase {
    func testTagPartsOfSpeech() {
        let sentence = "Janet will back the bill"
        let observations = sentence.split(separator: " ").map { String($0) }
        let stateGraph: [PartOfSpeech] = [.NNP, .MD, .VB, .JJ, .NN, .RB, .DT] // Replace with your actual PartOfSpeech type
        let result = try? tagPartsOfSpeech(observations: observations, stateGraph: stateGraph)

        // Check if the result is exactly what you expect
        let expectedOutput: [PartOfSpeech] = [.NNP, .MD, .VB, .DT, .NN] // Replace with your actual expected output
        XCTAssertEqual(result?.0, expectedOutput, "tagPartsOfSpeech did not return the expected output")
    }

    func testEmptyObservations() {
        let observations: [String] = []
        let stateGraph: [PartOfSpeech] = [.NNP, .MD, .VB, .JJ, .NN, .RB, .DT]

        XCTAssertThrowsError(try tagPartsOfSpeech(observations: observations, stateGraph: stateGraph), "tagPartsOfSpeech should throw error when observations are empty") { error in
            XCTAssertEqual(error as? PartOfSpeechTaggerError, PartOfSpeechTaggerError.emptyObservations, "tagPartsOfSpeech should throw PartOfSpeechTaggerError.emptyObservations when observations are empty")
        }
    }

    func testUnknownWord() {
        let sentence = "Janet will back the unknownword"
        let observations = sentence.split(separator: " ").map { String($0) }
        let stateGraph: [PartOfSpeech] = [.NNP, .MD, .VB, .JJ, .NN, .RB, .DT]
        let result = try? tagPartsOfSpeech(observations: observations, stateGraph: stateGraph)

        // Check if the result is nil or some default value when encountering an unknown word
        // Adjust this according to your implementation
        XCTAssertEqual(result?.0.last, .NN, "tagPartsOfSpeech should return .NNP or some default value for unknown words")
    }

    func testTagPartsOfSpeechError() {
        let sentence = "Janet will back the bill"
        let observations = sentence.split(separator: " ").map { String($0) }
        let stateGraph: [PartOfSpeech] = [] // Empty stateGraph should throw error
        var error: Error?

        do {
            _ = try tagPartsOfSpeech(observations: observations, stateGraph: stateGraph)
        } catch let e {
            error = e
        }

        // Check if the error is PartOfSpeechTaggerError.emptyPathProbabilityMatrix
        XCTAssertTrue(error is PartOfSpeechTaggerError && (error as! PartOfSpeechTaggerError) == .emptyPathProbabilityMatrix, "tagPartsOfSpeech should throw PartOfSpeechTaggerError.emptyPathProbabilityMatrix for empty state graph")
    }
}
