//
//  SearchResultsViewController.swift
//  Stocks Market
//
//  Created by TheGIZzz on 1/8/2565 BE.
//

import UIKit

class SearchResultsViewController: UIViewController {
    
    private var results = [SearchResult]()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .secondarySystemBackground
        tableView.register(
            SearchResultsTableViewCell.self,
            forCellReuseIdentifier: SearchResultsTableViewCell.identifier
        )
        tableView.isHidden = true
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func setUpTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func update(with results: [SearchResult]) {
        self.results = results
        tableView.isHidden = results.isEmpty
        tableView.reloadData()
    }

}

extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = results[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultsTableViewCell.identifier, for: indexPath)
        
        cell.textLabel?.text = model.displaySymbol
        cell.detailTextLabel?.text = model.description
        
        return cell
    }
    
    
}
