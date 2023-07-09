
//
//  ContentView.swift
//  WestpacCCTypeSorterAssignment
//
//  Created by Macbook on 2/07/23.
//

import SwiftUI
import Foundation

struct ContentView: View {
    
    @StateObject private var config = CreditCardConfig()
    
    var body: some View {
        NavigationView {
            Group {
                if config.isLoading {
                    LoadingView()
                } else if let creditCards = config.creditCards {
                    SuccessView(config: config, creditCards: creditCards)
                } else {
                    Button("Fetch Credit Cards") {
                        config.fetch()
                    }
                }
            }
            .navigationTitle("Credit Cards")
        }
    }
}

struct ErrorView: View {
    
    let localizedError: String
    
    var body: some View {
        Text(localizedError)
            .padding()
    }
}

struct LoadingView : View {
    
    var body: some View {
        Text("Loading ...")
            .font(.subheadline)
            .padding()
    }
}

struct SuccessView: View {
    
    @ObservedObject var config: CreditCardConfig
    let creditCards: [CreditCard]
    
    var body: some View {
        List {
            Section {
                ForEach(creditCards) { card in
                    
                    HStack {
                        Text("**** **** **** " + card.credit_card_number.suffix(4))
                            .frame(width: 120,  alignment: .leading)
                        Text(card.credit_card_type)
                        Spacer()
                        Text(card.credit_card_expiry_date)
                            .frame(alignment: .trailing)
                        bookmarkButton(id: card.id)
                            .font(.body)
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 10))
                }
            } header: {
                HStack {
                    Text("Card #")
                        .frame(width: 120, alignment: .leading)
                    Text("Type")
                    Spacer()
                    Text("Expiry Date")
                        .frame(alignment: .trailing)
                }
                .font(.headline)
            }
        }
        .navigationBarItems(trailing: sortButton)
    }
    
    private var sortButton: some View {
        Button(action: config.sort) {
            if config.isSorted {
                Image(systemName: "line.3.horizontal.decrease.circle.fill")
            }else {
                Image(systemName: "line.3.horizontal.decrease.circle")
            }
        }
    }
    
    private func bookmarkButton(id: Int) -> some View {
        Button {
            config.bookmark(id: id)
        } label: {
            if config.isBookmarked(id: id) {
                Image(systemName: "bookmark.fill")
            } else {
                Image(systemName: "bookmark.circle")
            }
        }
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



