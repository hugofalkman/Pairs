//
//  PairsGame.swift
//  Pairs
//
//  Created by H Hugo Falkman on 08/09/2020.
//  Copyright © 2020 H Hugo Falkman. All rights reserved.
//

import Foundation

struct PairsGame<PairId: Equatable, CardContent> {
    
    private(set) var cards: [Card]
    var timeRemaining: TimeInterval {
        max(0, gameTimeLimit - usedTime)
    }
    
    private let gameTimeLimit: TimeInterval
    private var lastStartDate: Date?
    private var pastUsedTime: TimeInterval = 0
    private var usedTime: TimeInterval {
        if let lastStartDate = lastStartDate {
            return pastUsedTime + Date().timeIntervalSince(lastStartDate)
        } else {
            return pastUsedTime
        }
    }
    
    private enum GameState { case start, firstFlipped }
    private var firstIndex: Int?
    private var secondIndex: Int?
    private var state = GameState.start {
        didSet {
            if state == .firstFlipped {
                lastStartDate = Date()
            } else {
                pastUsedTime = usedTime
                lastStartDate = nil
            }
        }
    }
    
    enum CardState { case unflipped, flipped, matched }
    struct Card: Identifiable {
        var state: CardState = .unflipped
        var pairId: PairId
        var content: CardContent
        var id: Int
    }
    
    init(numberOfPairsOfCards: Int, maxGameTime: Double,
        cardFactory: (Int) -> (PairId, CardContent, CardContent)) {
        cards = [Card]()
        for pairIndex in 0..<numberOfPairsOfCards {
            let pairContents = cardFactory(pairIndex)
            cards.append(Card(pairId: pairContents.0, content: pairContents.1, id: pairIndex*2))
            cards.append(Card(pairId: pairContents.0, content: pairContents.2, id: pairIndex*2+1))
        }
        cards.shuffle()
        gameTimeLimit = maxGameTime
    }
    
    mutating func flip(card: Card) {
        if let index = cards.firstIndex(matching: card) {
            guard cards[index].state == .unflipped else { return }
//            guard secondIndex == nil else { return }
            if secondIndex != nil { noMatch() }
            
            switch state {
            case .start:
                    firstIndex = index
                    cards[index].state = .flipped
                    state = .firstFlipped

            case .firstFlipped:
                    secondIndex = index
                    cards[index].state = .flipped
                    checkMatches()
            }
        }
    }
    
    private mutating func checkMatches() {
        guard let first = firstIndex, let second = secondIndex else {
            fatalError("There must be two flipped cards before matching.")
        }
        if cards[first].pairId == cards[second].pairId {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: match)
            match()
//        } else {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: noMatch)
//        }
        }
    }
    
    private mutating func match() {
        guard let first = firstIndex, let second = secondIndex else {
            fatalError("There must be two flipped cards before matching.")
        }
            cards[first].state = .matched
            cards[second].state = .matched
        reset()
    }

    private mutating func noMatch() {
        guard let first = firstIndex, let second = secondIndex else {
            fatalError("There must be two flipped cards before matching.")
        }
        cards[first].state = .unflipped
        cards[second].state = .unflipped
        reset()
    }

    private mutating func reset() {
        firstIndex = nil
        secondIndex = nil
        state = .start
    }
}
