//
//  CreditCard.swift
//  WestpacCCTypeSorterAssignment
//
//  Created by Macbook on 2/07/23.
//

import Foundation

struct CreditCard:Decodable, Identifiable {
    let id: Int
    let uid: String
    let credit_card_number: String
    let credit_card_type: String
    let credit_card_expiry_date: String
    
}

final class CreditCardConfig: ObservableObject {
    private var service = CreditCardService()
    private let userDefaults = UserDefaults.standard
    
    @Published private(set) var creditCards: [CreditCard]?
    @Published private(set) var localizedDescription: String?
    @Published private(set) var isLoading = false
    @Published private(set) var isSorted = false
    
    func fetch() {
        isSorted = false
        isLoading = true
        
        Task {
            do {
                creditCards = try await service.fetchCredtCards()
                isLoading = false
            } catch {
                localizedDescription = error.localizedDescription
                isLoading = false
            }
            
        }
    }
    
    func sort() {
        if !isSorted {
           if ((creditCards == nil)) {
            creditCards = []
        }
            self.creditCards = creditCards?.sorted(by: {card1, card2 in
                card1.credit_card_type < card2.credit_card_type
            })
            isSorted = true
        }
    }
    
    func bookmark(id: Int) {
        let bookmarked = isBookmarked(id: id)
        userDefaults.set(!bookmarked, forKey: "saved_card_\(id)")
        objectWillChange.send()
        }
    
    func isBookmarked(id: Int) -> Bool {
        userDefaults.bool(forKey: "saved_card_\(id)")
    }
}

final class CreditCardService {
    enum ServiceError: Error, LocalizedError {
        case cannotCreateURL
        case urlSessionDidFail
        case cannotDecodeData
        
        var localizedDescription: String {
            switch self {
            case .cannotCreateURL:
                return "Cannot Create URL"
            case .urlSessionDidFail:
                return "URL Session Failed"
            case .cannotDecodeData:
                return "Cannot Decode Data"
            }
        }
    }
    
    private let urlString = "https://random-data-api.com/api/v2/credit_cards?size=100"
    private let jsonDecoder = JSONDecoder()
    
    func fetchCredtCards() async throws -> [CreditCard] {
        guard let url = URL(string: urlString) else {
            throw ServiceError.cannotCreateURL
        }
        
        let request = URLRequest(url: url)
        let data: Data
        
        do {
            data = try await URLSession.shared.data(for: request).0
        } catch {
            throw ServiceError.urlSessionDidFail
        }
        
        let creditCards: [CreditCard]
    
        
        do {
            creditCards = try jsonDecoder.decode([CreditCard].self, from: data)
        } catch {
            throw ServiceError.cannotDecodeData
        }
        
        return creditCards
    }
}
