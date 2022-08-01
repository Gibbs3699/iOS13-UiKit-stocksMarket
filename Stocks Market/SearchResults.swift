//
//  SearchResults.swift
//  Stocks Market
//
//  Created by TheGIZzz on 1/8/2565 BE.
//

import Foundation

struct SearchResults: Codable {
    let count: Int
    let result: [SearchResult]
}

struct SearchResult: Codable {
    let description: String
    let displaySymbol: String
    let symbol: String
    let type: String
}
