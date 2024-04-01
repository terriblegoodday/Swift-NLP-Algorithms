//
//  ViterbiView.swift
//  Swift-NLP-Algorithms
//
//  Created by Eduard Dzhumagaliev on 01.04.2024.
//

import SwiftUI

struct ViterbiView: View {
    @State private var sentence = "Janet will back the bill"
    @State private var taggedSentence = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("NLP Part of Speech Tagger")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 50)

            TextField("Type a sentence", text: $sentence)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .autocapitalization(.none)
                .disableAutocorrection(true)

            Button(action: tagSentence) {
                Text("Tag Sentence")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color.blue)
                    .cornerRadius(10)
            }

            if !taggedSentence.isEmpty {
                Text("Tagged Sentence")
                    .font(.headline)
                    .padding(.top, 20)

                Text(taggedSentence)
                    .font(.body)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
    }

    func tagSentence() {
        do {
            let observations = sentence.split(separator: " ").map { String($0) }
            let result = try tagPartsOfSpeech(observations: observations, stateGraph: [.NNP, .MD, .VB, .JJ, .NN, .RB, .DT])
            taggedSentence = result.0.description + " " + result.1.description
        } catch {
            taggedSentence = "Error"
        }
    }
}

#Preview {
    ViterbiView()
}
