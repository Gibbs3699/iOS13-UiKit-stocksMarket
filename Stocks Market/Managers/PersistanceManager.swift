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
    
    public func addToWatchList(symbol: String, companyName: String) {
        var current = watchList
        
        current.append(symbol)
        userDefault.set(current, forKey: Constants.watchListKey)
        userDefault.set(companyName, forKey: symbol)
        
        NotificationCenter.default.post(name: .didAddToWatchList, object: nil)
    }
    
    public func reMoveFromWatchList(symbol: String) {
        var newList: [String] = []
        
        userDefault.set(nil, forKey: symbol)
        for item in watchList where item != symbol {
            newList.append(item)
        }
        
        userDefault.set(newList, forKey: Constants.watchListKey)
    }
    
    public func watchListContains(symbol: String) -> Bool {
        return watchList.contains(symbol)
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
