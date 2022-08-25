//
//  WatchListTableViewCell.swift
//  Stocks Market
//
//  Created by TheGIZzz on 25/8/2565 BE.
//

import UIKit

protocol WatchListTableViewCellDelegate: AnyObject {
    func didUpdateMaxWidth()
}
class WatchListTableViewCell: UITableViewCell {

    static let identifier = "WatchListTableViewCell"
    
    weak var delegate: WatchListTableViewCellDelegate?
    
    struct ViewModel {
        let symbol: String
        let companyName: String
        let price: String
        let changeColor: UIColor
        let changePercentage: String
        let chartViewModel: StockChartView.ViewModel
    }
    
    static let preferredHeight: CGFloat = 60
    
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.layer.cornerRadius = 6
        label.layer.masksToBounds = true
        label.textAlignment = .right
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .right
        return label
    }()
    
    private var miniChartView: StockChartView = {
        let stockChartView = StockChartView()
        stockChartView.isUserInteractionEnabled = false
        stockChartView.clipsToBounds = true
        return stockChartView
    }()
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubviews(
            symbolLabel,
            nameLabel,
            changeLabel,
            priceLabel,
            miniChartView
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        symbolLabel.sizeToFit()
        nameLabel.sizeToFit()
        changeLabel.sizeToFit()
        priceLabel.sizeToFit()
        
        let yStart: CGFloat = (contentView.height - symbolLabel.height - nameLabel.height)/2
        symbolLabel.frame = CGRect(
            x: separatorInset.left,
            y: yStart,
            width: symbolLabel.width,
            height: symbolLabel.height
        )

        nameLabel.frame = CGRect(
            x: separatorInset.left,
            y: symbolLabel.bottom,
            width: nameLabel.width,
            height: nameLabel.height
        )

        let currentWidth = max(
            max(priceLabel.width, changeLabel.width),
            WatchListViewController.maxChangeWidth
        )

        if currentWidth > WatchListViewController.maxChangeWidth {
            WatchListViewController.maxChangeWidth = currentWidth
            delegate?.didUpdateMaxWidth()
        }

        priceLabel.frame = CGRect(
            x: contentView.width - 10 - currentWidth,
            y: (contentView.height - priceLabel.height - changeLabel.height)/2,
            width: currentWidth,
            height: priceLabel.height
        )

        changeLabel.frame = CGRect(
            x: contentView.width - 10 - currentWidth,
            y: priceLabel.bottom,
            width: currentWidth,
            height: changeLabel.height
        )

        miniChartView.frame = CGRect(
            x: priceLabel.left - (contentView.width/3) - 20,
            y: 6,
            width: contentView.width/3,
            height: contentView.height-12
        )
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        symbolLabel.text = nil
        nameLabel.text = nil
        changeLabel.text = nil
        priceLabel.text = nil
        miniChartView.reset()
    }
    
    public func configure(with viewModel: ViewModel) {
        symbolLabel.text = viewModel.symbol
        nameLabel.text = viewModel.companyName
        priceLabel.text = viewModel.price
        changeLabel.text = viewModel.changePercentage
        changeLabel.backgroundColor = viewModel.changeColor
        miniChartView.configure(with: viewModel.chartViewModel)
    }
}

