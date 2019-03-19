//
//  FilterCollectionViewCell.swift
//  gamingnews
//
//  Created by Carlos Mejia on 3/19/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import UIKit

protocol FilterCollectionViewCellDataSource {
    var title: String { get }
    var titleFont: UIFont? { get }
    var titleColor: UIColor? { get }
    var backgroundColor: UIColor? { get }
    var iconImage: UIImage? { get }
    var iconImageTintColor: UIColor? { get }
}

class FilterCollectionViewCell: UICollectionViewCell, ConfigurableCellProtocol {
    // MARK: - UI References
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    
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
    
    func setupWith(dataSource: Any?, indexPath: IndexPath?, delegate: Any?) {
        guard let dataSource = dataSource as? FilterCollectionViewCellDataSource else {
            return
        }
        
        nameLabel.text = dataSource.title
        nameLabel.font = dataSource.titleFont ?? nameLabel.font
        nameLabel.textColor = dataSource.titleColor ?? nameLabel.textColor
        iconImageView.backgroundColor = dataSource.backgroundColor ?? UIColor.GamingNews.red
        iconImageView.image = dataSource.iconImage
        iconImageView.tintColor = dataSource.iconImageTintColor ?? .white
    }
    
    // MARK: - Private Methods
    
    /**
     Method to setup the UI.
     **/
    private func setupUI() {
        cardView.clipsToBounds = true
        cardView.layer.cornerRadius = 22
        nameLabel.text = nil
        iconImageView.image = nil
    }
}
