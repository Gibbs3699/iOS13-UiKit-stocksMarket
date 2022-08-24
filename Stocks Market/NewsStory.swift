//
//  NewsStory.swift
//  Stocks Market
//
//  Created by TheGIZzz on 24/8/2565 BE.
//

import Foundation

struct NewsStory: Codable {
    let category: String
    let datetime: TimeInterval
    let headline: String
    let image: String
    let related: String
    let source: String
    let summary: String
    let url: String
}
