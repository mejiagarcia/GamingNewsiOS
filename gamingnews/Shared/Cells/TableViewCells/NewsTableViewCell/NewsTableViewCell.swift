//
//  NewsTableViewCell.swift
//  gamingnews
//
//  Created by Carlos Mejia on 3/14/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import UIKit
import Kingfisher

protocol NewsTableViewCellDataSource {
    var backgroundImageUrl: String? { get }
    var title: String { get }
    var titleFont: UIFont? { get }
    var titleColor: UIColor? { get }
}

protocol NewsTableViewCellDelegate: class {
    func cellTapped(_ in: NewsTableViewCell, at: IndexPath?)
}

class NewsTableViewCell: UITableViewCell, ConfigurableCellProtocol {
    // MARK: - UI References
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Properties
    private weak var delegate: NewsTableViewCellDelegate?
    private var indexPath: IndexPath?
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        setupUI()
    }
    
    // MARK: - Public Methods
    
    func setupWith(dataSource: Any, indexPath: IndexPath?, delegate: Any?) {
        guard let dataSource = dataSource as? NewsTableViewCellDataSource else {
            return
        }
        
        titleLabel.text = dataSource.title
        titleLabel.font = dataSource.titleFont ?? titleLabel.font
        titleLabel.textColor = dataSource.titleColor ?? titleLabel.textColor
    }
    
    // MARK: - Private Methods
    
    /**
     Method to setup the UI.
     **/
    private func setupUI() {
        cardView.clipsToBounds = true
        cardView.layer.cornerRadius = 4
        
        titleLabel.text = nil
        
        backgroundImageView.image = nil
        backgroundImageView.kf.cancelDownloadTask()
        
        // Setup the tap gesture.
        gestureRecognizers?.removeAll()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cellTapped)))
    }
    
    /**
     Method to catch the tap of the cell.
     **/
    @objc private func cellTapped() {
        if let indexPath = indexPath {
            delegate?.cellTapped(self, at: indexPath)
        }
    }
}
