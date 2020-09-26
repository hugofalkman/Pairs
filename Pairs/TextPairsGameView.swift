//
//  TextPairsGameView.swift
//  Pairs
//
//  Created by H Hugo Falkman on 06/09/2020.
//  Copyright © 2020 H Hugo Falkman. All rights reserved.
//

import SwiftUI

struct TextPairsGameView: View {
    @ObservedObject var viewModel: TextPairsGame
    
    @State private var timeRemainingString = " "
    @State private var timer = Timer.publish(every: timerUpdateInterval, tolerance: 0.2 * timerUpdateInterval, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .top, endPoint: .bottom)
            VStack {
                Image(decorative: "pairs")
                
                GridStack(viewModel.cards, numberOfRows: viewModel.numberOfGridRows) { card in
                    CardView(card: card)
                        .accessibility(addTraits: .isButton)
                        .accessibility(label: Text(card.content))
                        .onTapGesture {
                            withAnimation(.linear(duration: self.animationDuration)) {
                                self.viewModel.flip(card)
                            }
                        }
                        
                }
                
                Text(timeRemainingString)
                    .font(.largeTitle)
                    .foregroundColor(Color.white)
                    .padding(.bottom)
                
                Button(action: {
                    let interval = Self.timerUpdateInterval
                    timer = Timer.publish(every: interval, tolerance: 0.2 * interval, on: .main, in: .common).autoconnect()
                    withAnimation(.easeIn(duration: self.animationDuration)) {
                        self.viewModel.resetGame()
                    }
                }, label: buttonLabel)
                    .buttonStyle(PlainButtonStyle())
            }
                .padding()
        }
            .onReceive(timer) { _ in
                let unmatched = self.viewModel.cards.filter { $0.state != .matched }
                guard unmatched.count > 0 else {
                    timer.upstream.connect().cancel()
                    return
                }
                timeRemainingString = "Time remaining: \(Int(0.5 + viewModel.timeRemaining))"
            }
    }
    
    // MARK: - Drawing Constants
    
    private static let timerUpdateInterval = 1.0
    private let gradientColors = [Color(white: 0.3), .black]
    private let animationDuration = 0.75
    private func buttonLabel() -> some View {
        Text("New Game")
            .font(.title)
            .padding(5)
            .background((RoundedRectangle(cornerRadius: 10)).fill(Color.white))
    }
}

struct CardView: View {
    var card: TextPairsGame.Game.Card
    
    var body: some View {
        Group {
            if card.state != .unflipped {
                Text(card.content)
            }
        }
            .font(.title)
            .foregroundColor(.black)
            .modifier(viewAsCard(isFaceUp: card.state != .unflipped, isMatched: card.state == .matched ))
            .frame(width: cardSize.width, height: cardSize.height)
    }
    
    // MARK: - Drawing Constants
    
    private let cardSize = CGSize(width: 140, height: 100)
}

struct viewAsCard: AnimatableModifier {
    var rotation: Double
    var isMatched: Bool
    
    init(isFaceUp: Bool, isMatched: Bool) {
        rotation = isFaceUp ? 0 : 180
        self.isMatched = isMatched
    }
    
    var isFaceUp: Bool {
        rotation < 90
    }
    
    var animatableData: Double {
        get { return rotation }
        set { rotation = newValue }
    }
    
    func body(content: Content) -> some View {
        ZStack {
            // CardFront
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(isMatched ? cardColors[.match]! : cardColors[.front]!)
                content
            }
                .opacity(isFaceUp ? 1 : 0)
            // CardBack
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(cardColors[.back]!)
                .opacity(isFaceUp ? 0 : 1)
        }
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(cardColors[.edge]!, lineWidth: edgeLineWidth)
            )
            .rotation3DEffect(Angle.degrees(rotation), axis: (0,1,0))
    }
    
    // MARK: - Drawing Constants
    
    private let cornerRadius: CGFloat = 16
    private enum colorChoices { case back, front, match, edge }
    private let cardColors: [colorChoices: Color] =
        [.back: .blue, .front: .white, .match: .green, .edge: .white]
    private let edgeLineWidth: CGFloat = 2
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TextPairsGameView(viewModel: TextPairsGame())
    }
}
