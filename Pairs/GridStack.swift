//
//  GridStack.swift
//  Pairs
//
//  Created by H Hugo Falkman on 13/09/2020.
//  Copyright © 2020 H Hugo Falkman. All rights reserved.
//

import SwiftUI

struct GridStack<Item: Identifiable, ItemView: View>: View {
    private var items: [Item]
    private var viewForItem: (Item) -> ItemView
    private var rows: Int
    private var columns: Int
    
    init(_ items: [Item], numberOfRows: Int, viewForItem: @escaping (Item) -> ItemView) {
        guard items.count % numberOfRows == 0  else {
            fatalError("Number of items not a multiple of \(numberOfRows)")
        }
        self.items = items
        self.viewForItem = viewForItem
        self.rows = numberOfRows
        self.columns = items.count / numberOfRows
    }
    
    var body: some View {
        VStack {
            ForEach(0..<rows, id: \.self) { row in
                HStack{
                    ForEach(0..<self.columns, id: \.self) { column in
                        self.viewForItem(self.items[row*self.columns + column])
                    }
                }
            }
        }
    }
}
