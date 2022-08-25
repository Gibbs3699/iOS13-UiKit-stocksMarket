//
//  WatchListViewController.swift
//  Stocks Market
//
//  Created by TheGIZzz on 1/8/2565 BE.
//

import UIKit
import FloatingPanel

class WatchListViewController: UIViewController {

    private var seachTimer: Timer?
    
    private var panel: FloatingPanelController?
    
    private var watchListMap: [String : [CandleStick]] = [:]
    
    private var viewModels: [WatchListTableViewCell.ViewModel] = []
    
    static var maxChangeWidth: CGFloat = 0
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(
            WatchListTableViewCell.self,
            forCellReuseIdentifier: WatchListTableViewCell.identifier
        )
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        setupSearchController()
        setUpTableView()
        setUpFloatingPanel()
        fetchWatchListData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func setupSearchController() {
        let resultVC = SearchResultsViewController()
        resultVC.delegate = self
        let searchVC = UISearchController(searchResultsController: resultVC)
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
    }
    
    private func setUpFloatingPanel() {
        let vc = NewsViewController(type: .topStories)
        let panel = FloatingPanelController(delegate: self)
        panel.surfaceView.backgroundColor = .secondarySystemBackground
        panel.set(contentViewController: vc)
        panel.addPanel(toParent: self)
        panel.track(scrollView: vc.tableView)
    }
    
    private func setUpTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchWatchListData() {
        let symbols = PersistanceManager.shared.watchList

        let group = DispatchGroup()

        for symbol in symbols where watchListMap[symbol] == nil {
            group.enter()

            APICallers.shared.marketData(for: symbol) { [weak self] result in
                defer {
                    group.leave()
                }

                switch result {
                case .success(let data):
                    let candleSticks = data.candleSticks
                    self?.watchListMap[symbol] = candleSticks
                case .failure(let error):
                    print(error)
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?.createViewModels()
            self?.tableView.reloadData()
        }
    }
    
    private func createViewModels() {
        var viewModels = [WatchListTableViewCell.ViewModel]()
        
        for (symbol, candleSticks) in watchListMap {
            let changePercentage = getChangePercentage(from: candleSticks)
            viewModels.append(.init(
                symbol: symbol,
                companyName: UserDefaults.standard.string(forKey: symbol) ?? "Company",
                price: getLastestClosingPrice(from: candleSticks),
                changeColor: changePercentage < 0 ? .systemRed : .systemGreen,
                changePercentage: .percentage(from: changePercentage), chartViewModel: .init(data: candleSticks.reversed().map { $0.close }, showLegend: false, showAxis: false, fillColor: changePercentage < 0 ? .systemRed : .systemGreen))
            )
        }
        
        self.viewModels = viewModels
    }
    
    private func getLastestClosingPrice(from data: [CandleStick]) -> String {
        guard let closingPrice = data.first?.close else {
            return ""
        }
        
        return .formatted(number: closingPrice)
    }
    
    private func getChangePercentage(from data: [CandleStick]) -> Double {
        let lastestDate = data[0].date
        guard let lastestClose = data.first?.close,
              let priorClose = data.first(where: {
                  !Calendar.current.isDate($0.date, inSameDayAs: lastestDate)
              })?.close else {
            return 0
        }
        
        let diff = 1 - (priorClose/lastestClose)
        return diff
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

extension WatchListViewController: SearchResultsViewControllerDelegate {
    func searchResultsViewControllerDidSelect(searchResult: SearchResult) {
        navigationItem.searchController?.searchBar.resignFirstResponder()
        
        let vc = StockDetailsViewController()
        let navVC = UINavigationController(rootViewController: vc)
        vc.title = searchResult.description
        present(navVC, animated: true)
    }
}

extension WatchListViewController: FloatingPanelControllerDelegate {
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        navigationItem.searchController?.searchBar.isHidden = fpc.state == .full
    }
}

extension WatchListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WatchListTableViewCell.identifier, for: indexPath) as? WatchListTableViewCell else {
            fatalError()
        }
        
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WatchListTableViewCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            // Update persistance
            PersistanceManager.shared.reMoveFromWatchList(symbol: viewModels[indexPath.row].symbol)
            // Update viewModel
            viewModels.remove(at: indexPath.row)
            // Delete row
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let viewModel = viewModels[indexPath.row]

//        let vc = StockDetailsViewController(
//            symbol: viewModel.symbol,
//            companyName: viewModel.companyName,
//            candleStickData: watchListMap[viewModel.symbol] ?? []
//        )
//        vc.title =  viewModel.companyName
//        let navVC = UINavigationController(rootViewController: vc)
//        present(navVC, animated: true)
    }
    
}
