//
//  TextPairsGame.swift
//  Pairs
//
//  Created by H Hugo Falkman on 08/09/2020.
//  Copyright © 2020 H Hugo Falkman. All rights reserved.
//

import SwiftUI

class TextPairsGame: ObservableObject {
    @Published private var model = createPairsGame()
    typealias Game = PairsGame<UUID, String>
    
    private static func createPairsGame() -> Game {
        let allJsonCards: [JsonCard] = Bundle.main.decode(jsonFileName)
        let jsonCards = allJsonCards.shuffled().prefix(numberOfPairs)
        return Game(numberOfPairsOfCards: numberOfPairs, maxGameTime: maxGameTime) { pairIndex in
            (jsonCards[pairIndex].id, jsonCards[pairIndex].a, jsonCards[pairIndex].b)
        }
    }
    
    // MARK: - Access to the Model
    
    var cards: [Game.Card] {
        model.cards
    }
    var timeRemaining: TimeInterval {
        model.timeRemaining
    }
    
    // MARK: - Intent(s)
    
    func flip(_ card: Game.Card) {
        model.flip(card: card)
    }
    
    func resetGame() {
        model = TextPairsGame.createPairsGame()
    }
    
    // MARK: - Constants
    
    static let maxGameTime = 100.0
    private static let jsonFileName = "capitals.json"
    // private static let jsonFileName = "math.json"
    
    // Number of Grid rows must be divisible into two times Number of pairs
    private static let numberOfPairs = 6
    let numberOfGridRows = 4
    
}

struct JsonCard: Codable {
    let id = UUID()
    let a: String
    let b: String
    
    enum CodingKeys: CodingKey {
        case a, b
    }
}
