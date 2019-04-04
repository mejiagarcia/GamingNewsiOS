//
//  FavoriteCollectionViewCell.swift
//  gamingnews
//
//  Created by Carlos Mejia on 4/4/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import UIKit

protocol FavoriteCellDataSource {
    var imageURL: String { get }
    var title: String { get }
    var titleFont: UIFont? { get }
    var titleColor: UIColor? { get }
}

class FavoriteCollectionViewCell: UICollectionViewCell, ConfigurableCellProtocol {
    // MARK: - UI References
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var mainTitleLabel: UILabel!
    
    // MARK: - Properties
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    // MARK: - Public Methods
    func setupWith(dataSource: Any?, indexPath: IndexPath?, delegate: Any?) {
        guard let dataSource = dataSource as? FavoriteCellDataSource else {
            return
        }
        
        if let imageURL = URL(string: dataSource.imageURL) {
            mainImageView.kf.setImage(with: imageURL)
        }
        
        mainTitleLabel.text = dataSource.title
        mainTitleLabel.textColor = dataSource.titleColor ?? mainTitleLabel.textColor
        mainTitleLabel.font = dataSource.titleFont ?? mainTitleLabel.font
    }
    
    /**
     Method to setup the UI.
     */
    private func setupUI() {
        mainImageView.image = nil
        mainTitleLabel.text = nil
    }
}
