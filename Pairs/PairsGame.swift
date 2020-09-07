//
//  Pairs.swift
//  Pairs
//
//  Created by H Hugo Falkman on 08/09/2020.
//  Copyright © 2020 H Hugo Falkman. All rights reserved.
//

import Foundation

struct PairsGame<PairId, CardContent> {
    var cards: [Card]
    
    private var state = GameState.start
    private var firstIndex: Int?
    private var secondIndex: Int?
    
    enum GameState {
        case start, firstFlipped
    }
    
    func choose(card: Card) {
        print("card chosen: \(card)")
    }
    
    init(numberOfPairsOfCards: Int,
        cardFactory: (Int) -> (PairId, CardContent, CardContent)) {
        cards = [Card]()
        for pairIndex in 0..<numberOfPairsOfCards {
            let pairContents = cardFactory(pairIndex)
            cards.append(Card(pairId: pairContents.0, content: pairContents.1, id: pairIndex*2))
            cards.append(Card(pairId: pairContents.0, content: pairContents.2, id: pairIndex*2+1))
        }
//        cards.shuffle()
    }
    
    enum CardState {
        case unflipped, flipped, matched
    }
    
    struct Card: Identifiable {
        var state: CardState = .flipped
        var pairId: PairId
        var content: CardContent
        var id: Int
    }
}
