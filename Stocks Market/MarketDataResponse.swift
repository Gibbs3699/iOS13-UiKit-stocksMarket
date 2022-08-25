//
//  MarketDataResponse.swift
//  Stocks Market
//
//  Created by TheGIZzz on 25/8/2565 BE.
//

import Foundation

struct MarketDataResponse: Codable {
    let open: [Double]
    let close: [Double]
    let low: [Double]
    let high: [Double]
    let status: String
    let timeStamps: [TimeInterval]
    
    enum CodingKeys: String, CodingKey {
        case open = "o"
        case close = "c"
        case low = "l"
        case high = "h"
        case status = "s"
        case timeStamps = "t"
    }
    
    var candleSticks: [CandleStick] {
        var result = [CandleStick]()
        
        for index in 0..<open.count {
            result.append(.init(
                date: Date(timeIntervalSince1970: timeStamps[index]),
                open: open[index],
                close: close[index],
                low: low[index],
                high: high[index])
            )
        }
        
        let sortedData = result.sorted(by: { $0.date > $1.date})
        return sortedData
    }
}

struct CandleStick {
    let date: Date
    let open: Double
    let close: Double
    let low: Double
    let high: Double
}
