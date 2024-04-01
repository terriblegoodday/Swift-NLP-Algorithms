//
//  ViterbiAlgorithm.swift
//  Swift-NLP-Algorithms
//
//  Created by Eduard Dzhumagaliev on 09.03.2024.
//

import UIKit

extension Array where Element: Collection, Element.Element: CustomStringConvertible {
    func prettyPrint() {
        guard let firstRow = self.first else {
            print("[]")
            return
        }

        let columnWidths = (0..<firstRow.count).map { colIndex in
            self.map { $0[colIndex as! Element.Index].description.count }.max() ?? 0
        }

        for row in self {
            var rowString = "["
            for (colIndex, cell) in row.enumerated() {
                let padding = String(repeating: " ", count: columnWidths[colIndex] - "\(cell)".count)
                rowString += "\(padding)\(cell)"
                if colIndex != row.count - 1 {
                    rowString += ", "
                }
            }
            rowString += "]"
            print(rowString)
        }
    }
}

extension Array where Element: Collection {
    func transpose() -> [[Element.Element]] {
        guard !self.isEmpty else { return [] }

        var transposedMatrix = [[Element.Element]]()
        for columnIndex in 0..<self[0].count {
            var column = [Element.Element]()
            for row in self {
                guard let element = row[safe: columnIndex as! Element.Index] else {
                    fatalError("Invalid matrix dimensions")
                }
                column.append(element)
            }
            transposedMatrix.append(column)
        }
        return transposedMatrix
    }
}

extension Dictionary where Value: Equatable {
    func findKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

enum PartOfSpeech: Int, CustomStringConvertible {
    case start = -1
    case NNP = 0
    case MD = 1
    case VB = 2
    case JJ = 3
    case NN = 4
    case RB = 5
    case DT = 6

    var description: String {
        switch self {
        case .start:
            "start"
        case .NNP:
            "NNP"
        case .MD:
            "MD"
        case .VB:
            "VB"
        case .JJ:
            "JJ"
        case .NN:
            "NN"
        case .RB:
            "RB"
        case .DT:
            "DT"
        }
    }
}

enum Constants {
    static let noBestProbability = -1.0
    static let noBackpointer = -1

    static let transitionProbabilities = [
        // NNP MD VB JJ NN RB DT
        [0.2767, 0.0006, 0.0031, 0.0453, 0.0449, 0.0510, 0.2026], // <s>
        [0.3777, 0.0110, 0.0009, 0.0084, 0.0584, 0.0090, 0.0025], // NNP
        [0.0008, 0.0002, 0.7968, 0.0005, 0.0008, 0.1698, 0.0041], // MD
        [0.0322, 0.0005, 0.0050, 0.0837, 0.0615, 0.0514, 0.2231], // VB
        [0.0366, 0.0004, 0.0001, 0.0733, 0.4509, 0.0036, 0.0036], // JJ
        [0.0096, 0.0176, 0.0014, 0.0086, 0.1216, 0.0177, 0.0068], // NN
        [0.0068, 0.0102, 0.1011, 0.1012, 0.0120, 0.0728, 0.0479], // RB
        [0.1147, 0.0021, 0.0002, 0.2157, 0.4744, 0.0102, 0.0017]  // DT
    ]

    static let observationProbabilities = [
        // Janet   will      back      the       bill
        [0.000032, 0,        0,        0.000048, 0       ], // NNP
        [0,        0.308431, 0,        0,        0       ], // MD
        [0,        0.000028, 0.800000, 0,        0.000028], // VB
        [0,        0,        0.000340, 0,        0       ], // JJ
        [0,        0.000200, 0.000223, 0,        0.002337], // NN
        [0,        0,        0.010446, 0,        0       ], // RB
        [0,        0,        0,        0.506099,  0       ]  // DT
    ]
}

typealias BestPath = [PartOfSpeech]
typealias BestProbability = [Double]

enum PartOfSpeechTaggerError: Error {
    case emptyPathProbabilityMatrix
    case emptyObservations
}

func calculatePathProbabilityMatrix(observations: [String], stateGraph: [PartOfSpeech], stateMap: [Int: PartOfSpeech]) throws -> ([[Double]], [[Int]]) {
    guard !observations.isEmpty else {
        throw PartOfSpeechTaggerError.emptyObservations
    }

    // Stores probability of state for each time step. is used later to compute futher probabilities in the sequence
    var pathProbabilityMatrix = Array(repeating: Array(repeating: Constants.noBestProbability, count: observations.count), count: stateGraph.count)
    // Stores the best previous state for each state at each time step. is used to backtrack the most likely sequence
    var backpointers = Array(repeating: Array(repeating: Constants.noBackpointer, count: stateGraph.count), count: observations.count)

    let transitionProbabilities = Constants.transitionProbabilities
    let observationProbabilities = Constants.observationProbabilities

    for (stateIndex, _) in stateGraph.enumerated() {
        pathProbabilityMatrix[stateIndex][0] = transitionProbabilities[0][stateIndex] * observationProbabilities[stateIndex][0]
        backpointers[0][stateIndex] = 0
    }

    for timeStepIndex in 1 ..< observations.count {
        for stateIndex in 0 ..< stateGraph.count {
            var bestProbability = Constants.noBestProbability
            var bestPreviousState: PartOfSpeech?

            for previousStateIndex in 0 ..< stateGraph.count {
                guard let previousState = stateMap[previousStateIndex] else { continue }

                let probability = pathProbabilityMatrix[previousStateIndex][timeStepIndex - 1] * transitionProbabilities[previousState.rawValue][stateIndex] * observationProbabilities[stateIndex][timeStepIndex]
                if probability > bestProbability {
                    bestProbability = probability
                    bestPreviousState = previousState
                }
            }

            pathProbabilityMatrix[stateIndex][timeStepIndex] = bestProbability
            backpointers[timeStepIndex][stateIndex] = stateMap.findKey(forValue: bestPreviousState!)!
        }
    }

    return (pathProbabilityMatrix, backpointers)
}

/// This function tags a sequence of tokens with corresponding parts of speech
/// - Parameter observations: tokens to tag
/// - Parameter stateGraph: parts of speech which we can use to tag
func tagPartsOfSpeech(observations: [String], stateGraph: [PartOfSpeech]) throws -> (BestPath, BestProbability) {
    var stateMap = [Int: PartOfSpeech]()
    for (index, state) in stateGraph.enumerated() {
        stateMap[index] = state
    }

    let (pathProbabilityMatrix, backpointers) = try calculatePathProbabilityMatrix(observations: observations, stateGraph: stateGraph, stateMap: stateMap)

    var bestLastPathProbability = Constants.noBestProbability
    var bestLastPartOfSpeech: PartOfSpeech?
    var bestLastPathPointer = Constants.noBackpointer

    let transposedPathProbabilityMatrix = pathProbabilityMatrix.transpose()

    guard let lastPathProbabilityMatrix = transposedPathProbabilityMatrix.last else {
        throw PartOfSpeechTaggerError.emptyPathProbabilityMatrix
    }

    for (stateIndex, probability) in lastPathProbabilityMatrix.enumerated() {
        if probability > bestLastPathProbability {
            bestLastPathProbability = probability
            bestLastPartOfSpeech = stateMap[stateIndex]
            bestLastPathPointer = stateIndex
        }
    }

    // Restore best part of speech path in state graph
    var tracedPath: [PartOfSpeech?] = [bestLastPartOfSpeech]
    var tracedProbability = [bestLastPathProbability]

    var timeStepIndex = observations.count - 1
    var currentBackpointer = bestLastPathPointer
    while timeStepIndex >= 1 {
        let foundBackpointer = backpointers[timeStepIndex][currentBackpointer]
        tracedPath.append(stateMap[foundBackpointer])
        tracedProbability.append(transposedPathProbabilityMatrix[timeStepIndex - 1][foundBackpointer])
        currentBackpointer = foundBackpointer
        timeStepIndex -= 1
    }

    return (tracedPath.compactMap { $0 }.reversed(), tracedProbability.reversed())
}

