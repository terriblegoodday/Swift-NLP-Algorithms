//
//  ContentView.swift
//  Swift-NLP-Algorithms
//
//  Created by Eduard Dzhumagaliev on 09.03.2024.
//

import SwiftUI

struct AlgorithmRow: View {
    var algorithm: String
    var status: String?
    var isActive: Bool = false

    var body: some View {
        HStack {
            Text(algorithm)
                .foregroundColor(isActive ? .primary : .secondary)
            if let status {
                Spacer()
                Text(status)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                    .padding(5)
                    .background(Color.white)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.orange, lineWidth: 1)
                    )
            }
        }
        .foregroundColor(.secondary)
    }
}

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: ViterbiView()) {
                    AlgorithmRow(algorithm: "Viterbi Algorithm", isActive: true)
                }
                AlgorithmRow(algorithm: "Lesk Algorithm", status: "WIP")
                AlgorithmRow(algorithm: "Markov Chain", status: "WIP")
                AlgorithmRow(algorithm: "Naive Bayes Classifier", status: "WIP")
                AlgorithmRow(algorithm: "CoreML Model Classifier", status: "WIP")
            }
            .navigationBarTitle("Swift NLP Algorithms", displayMode: .large)
        }
    }
}

#Preview {
    ContentView()
}
