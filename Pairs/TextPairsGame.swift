//
//  JsonABPairs.swift
//  Pairs
//
//  Created by H Hugo Falkman on 08/09/2020.
//  Copyright © 2020 H Hugo Falkman. All rights reserved.
//

import SwiftUI

class TextPairsGame {
    private var model = createPairsModel()
    
    private static func createPairsModel() -> PairsGame<UUID, String> {
        let allJsonCards: [JsonCard] = Bundle.main.decode("capitals.json")
        let jsonCards = allJsonCards.shuffled().prefix(numberOfPairs)
        return PairsGame<UUID, String>(numberOfPairsOfCards: numberOfPairs) { pairIndex in
            (jsonCards[pairIndex].id, jsonCards[pairIndex].a, jsonCards[pairIndex].b)
        }
    }
    private static let numberOfPairs = 12
    
    // MARK: - Access to the Model
    
    var cards: [PairsGame<UUID, String>.Card] {
        model.cards
    }
    
    // MARK: - Intent(s)
    
    func choose(card: PairsGame<UUID, String>.Card) {
        model.choose(card: card)
    }
}

struct JsonCard: Codable {
    let id = UUID()
    let a: String
    let b: String
}
