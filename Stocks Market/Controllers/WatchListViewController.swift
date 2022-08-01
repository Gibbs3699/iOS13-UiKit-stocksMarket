//
//  WatchListViewController.swift
//  Stocks Market
//
//  Created by TheGIZzz on 1/8/2565 BE.
//

import UIKit

class WatchListViewController: UIViewController {

    private var seachTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        setupSearchController()
    }

    private func setupSearchController() {
        let resultVC = SearchResultsViewController()
        let searchVC = UISearchController(searchResultsController: resultVC)
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
    }
    
}
 
extension WatchListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
            let resultVC = searchController.searchResultsController as? SearchResultsViewController, !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        seachTimer?.invalidate()
        
        seachTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
            APICallers.shared.search(query: query) { result in
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        resultVC.update(with: response.result)
                        print("PPPP check result ---> \(response.result)")
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        resultVC.update(with: [])
                    }
                    print(error)
                }
                
            }
        })

    }
    
}

