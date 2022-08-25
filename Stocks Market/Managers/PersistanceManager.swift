//
//  PersistanceManager.swift
//  Stocks Market
//
//  Created by TheGIZzz on 25/8/2565 BE.
//

import Foundation

final class PersistanceManager {
    
    static let shared = PersistanceManager()
    
    private let userDefault: UserDefaults = .standard
    
    private struct Constants {
        static let onBoardKey = "hasOnBoard"
        static let watchListKey = "watchList"
    }
    
    private init() {}
    
    // MARK: - Public
    
    public var watchList: [String] {
        if !hasOnBoarded {
            userDefault.set(true, forKey: Constants.onBoardKey)
            setUpDefaults()
        }
        return userDefault.stringArray(forKey: Constants.watchListKey) ?? []
    }
    
    public func addToWatchList() {
        
    }
    
    
    // MARK: - Private
    
    private var hasOnBoarded: Bool {
        return userDefault.bool(forKey: Constants.onBoardKey)
    }
    
    private func setUpDefaults() {
        let map: [String: String] = [
            "AAPL": "Apple Inc",
            "MSFT": "Microsoft Corporation",
            "SNAP": "Snap Inc.",
            "GOOG": "Alphabet",
            "AMZN": "Amazon.com, Inc.",
            "WORK": "Slack Technologies",
            "FB": "Facebook Inc.",
            "NVDA": "Nvidia Inc.",
            "NKE": "Nike",
            "PINS": "Pinterest Inc."
        ]
        
        let symbols = map.keys.map{ $0 }
        userDefault.set(symbols, forKey: "watchList")
        
        for (symbol, name) in map {
            userDefault.set(name, forKey: symbol)
        }
    }
}
