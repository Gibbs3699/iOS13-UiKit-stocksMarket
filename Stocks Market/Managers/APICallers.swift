//
//  APICallers.swift
//  Stocks Market
//
//  Created by TheGIZzz on 1/8/2565 BE.
//

import Foundation

final class APICallers {
    
    static let shared = APICallers()
    
    private struct Constants {
        static let apiKey = "cbbsfe2ad3ibhoa2ac2g"
        static let sandboxApiKey = "sandbox_cbbsfe2ad3ibhoa2ac30"
        static let baseURL = "https://finnhub.io/api/v1/"
        static let day: TimeInterval = 3600 * 24
    }
    
    private init() {}
    
    // MARK: - Public
    public func search(query: String, completion: @escaping (Result<SearchResults, Error>) -> Void) {
        guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        request(url: url(for: .search, queryParams: ["q":safeQuery]), expecting: SearchResults.self, completion: completion)
    }
    
    public func news(type: NewsViewController.`Type`, completion: @escaping (Result<[NewsStory], Error>) -> Void) {
        switch type {
        case .topStories:
            request(url: url(for: .topStories, queryParams: ["category":"general"]), expecting: [NewsStory].self, completion: completion)
        case .company(let symbol):
            let today = Date()
            let oneMonthBack = today.addingTimeInterval(-(Constants.day * 7))
            request(url: url(for: .companyNews, queryParams: ["symbol":symbol, "from": DateFormatter.newsDateformatter.string(from: oneMonthBack), "to": DateFormatter.newsDateformatter.string(from: today)]), expecting: [NewsStory].self, completion: completion)
        }
    }
    
    // MARK: - Private
    private enum EndPoint: String {
        case search
        case topStories = "news"
        case companyNews = "company-news"
    }
    
    private enum APIError: Error {
        case invalidURL
        case noDataReturned
    }
    
    private func url(for endPoint: EndPoint, queryParams: [String: String] = [:]) -> URL? {
        var urlString = Constants.baseURL + endPoint.rawValue
        
        var queryItems = [URLQueryItem]()
        
        for (name, value) in queryParams {
            queryItems.append(.init(name: name, value: value))
        }
        
        queryItems.append(.init(name: "token", value: Constants.apiKey))
        
        urlString += "?" + queryItems.map {"\($0.name)=\($0.value ?? "")"}.joined(separator: "&")
        
        return URL(string: urlString)
    }
    
    private func request<T: Codable>(url: URL?, expecting: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = url else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                if let error = error {
                    completion(.failure(error))
                }else {
                    completion(.failure(APIError.noDataReturned))
                }
                return
            }
        
            do {
                let result = try JSONDecoder().decode(expecting, from: data)
                completion(.success(result))
            } catch  {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }

}
