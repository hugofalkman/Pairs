//
//  JsonABPairsView.swift
//  Pairs
//
//  Created by H Hugo Falkman on 06/09/2020.
//  Copyright © 2020 H Hugo Falkman. All rights reserved.
//

import SwiftUI

//class Deck: ObservableObject {
//    let allCards: [Card] = Bundle.main.decode("capitals.json")
//    @Published var cardParts = [CardPart]()
//
//    init() {
//        let selectedCards = allCards.shuffled().prefix(12)
//
//        for card in selectedCards {
//            cardParts.append(CardPart(id: card.id, text: card.a))
//            cardParts.append(CardPart(id: card.id, text: card.b))
//        }
//
//        cardParts.shuffle()
//    }
//
//    func set(_ index: Int, to state: CardState) {
//        cardParts[index].state = state
//    }
//}
//
//struct Card: Codable {
//    let id = UUID()
//    let a: String
//    let b: String
//
//}

struct CardView: View {
    var card: PairsGame<UUID,String>.Card
    
    var body: some View {
        ZStack {
            CardBack()
                .rotation3DEffect(.degrees(card.state == .unflipped ? 0 : 180), axis: (x: 0, y: 1, z: 0))
                .opacity(card.state == .unflipped ? 1 : 0)
            CardFront(card: card)
                .rotation3DEffect(.degrees(card.state != .unflipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
                .opacity(card.state != .unflipped ? 1 : -1)
        }
    }
}

enum CardState {
    case unflipped, flipped, matched
}

struct CardPart {
    let id: UUID
    let text: String
    var state = CardState.unflipped
}

struct CardBack: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.blue)
            .frame(width: 140, height: 100)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.white, lineWidth: 2)
            )
    }
}

struct CardFront: View {
    var card: PairsGame<UUID,String>.Card
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(card.state == .matched ? Color.green : Color.white)
                .frame(width: 140, height: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.white, lineWidth: 2)
                )
            Text(card.content)
                .font(.title)
                .foregroundColor(.black)
        }
    }
}

enum GameState {
    case start, firstFlipped
}

struct GridStack<Content: View>: View {
    let rows: Int
    let columns: Int
    let content: (Int, Int) -> Content
    
    var body: some View {
        VStack {
            ForEach(0..<rows, id: \.self) { row in
                HStack{
                    ForEach(0..<self.columns, id: \.self) { column in
                        self.content(row, column)
                    }
                }
            }
        }
    }
}

struct TextPairsGameView: View {
    var viewModel: TextPairsGame
    
//    @ObservedObject var deck = Deck()
    
    @State private var state = GameState.start
    @State private var firstIndex: Int?
    @State private var secondIndex: Int?
    
    @State private var timeRemaining = 100
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let rowCount = 4
    let columnCount = 6
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(white: 0.3), .black]), startPoint: .top, endPoint: .bottom)
            VStack {
                Image(decorative: "pairs")
                
                GridStack(rows: rowCount, columns: columnCount, content: card)
                
                Text("Time: \(100 - timeRemaining)")
                    .font(.largeTitle)
                    .foregroundColor(Color.white)
            }
                .padding()
        }
//            .onReceive(timer, perform: updateTimer)
    }
    
    func card(atRow row: Int, column: Int) -> some View {
        let index = (row * columnCount) + column
        let card = viewModel.cards[index]
        
        return CardView(card: card)
            .accessibility(addTraits: .isButton)
            .accessibility(label: Text(card.content))
            .onTapGesture {
                self.viewModel.choose(card: card)
            }
    }
    
//    func flip(_ index: Int) {
//        guard deck.cardParts[index].state == .unflipped else { return }
//        guard secondIndex == nil else { return }
//
//        switch state {
//        case .start:
//            withAnimation {
//                firstIndex = index
//                deck.set(index, to: .flipped)
//                state = .firstFlipped
//            }
//        case .firstFlipped:
//            withAnimation {
//                secondIndex = index
//                deck.set(index, to: .flipped)
//                checkMatches()
//            }
//        }
//    }
//
//    func match() {
//        guard let first = firstIndex, let second = secondIndex else {
//            fatalError("There must be two flipped cards before matching.")
//        }
//        withAnimation {
//            deck.set(first, to: .matched)
//            deck.set(second, to: .matched)
//        }
//        reset()
//    }
//
//    func noMatch() {
//        guard let first = firstIndex, let second = secondIndex else {
//            fatalError("There must be two flipped cards before matching.")
//        }
//        withAnimation {
//            deck.set(first, to: .unflipped)
//            deck.set(second, to: .unflipped)
//        }
//        reset()
//    }
//
//    func reset() {
//        firstIndex = nil
//        secondIndex = nil
//        state = .start
//    }
//
//    func checkMatches() {
//        guard let first = firstIndex, let second = secondIndex else {
//            fatalError("There must be two flipped cards before matching.")
//        }
//        if deck.cardParts[first].id == deck.cardParts[second].id {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: match)
//        } else {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: noMatch)
//        }
//    }
//
//    func updateTimer(_ currentTime: Date) {
//        let unmatched = deck.cardParts.filter { $0.state != .matched }
//        guard unmatched.count > 0 else { return }
//
//        if timeRemaining > 0 {
//            timeRemaining -= 1
//        }
//    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TextPairsGameView(viewModel: TextPairsGame())
    }
}
