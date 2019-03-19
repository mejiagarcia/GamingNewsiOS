//
//  FiltersContainerTableViewCell.swift
//  gamingnews
//
//  Created by Carlos Mejia on 3/19/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import UIKit

struct FiltersContainerCellViewModel {
    // MARK: - Properties
    let title: String
    let dataSource: [FilterCollectionViewCellDataSource]
}

protocol FiltersContainerTableViewCellDelegate: class {
    
}

class FiltersContainerTableViewCell: UITableViewCell, ConfigurableCellProtocol {
    // MARK: - UI References
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Properties
    private weak var delegate: FiltersContainerTableViewCellDelegate?
    private var viewModel: FiltersContainerCellViewModel?
    
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
        guard let dataSource = dataSource as? FiltersContainerCellViewModel else {
            return
        }
        
        self.viewModel = dataSource
        self.delegate = delegate as? FiltersContainerTableViewCellDelegate
        titleLabel.text = dataSource.title
    }
    
    // MARK: - Private Methods
    
    /**
     Method to setup the UI.
     **/
    private func setupUI() {
        collectionView.registerAllCells()
        collectionView.dataSource = self
        collectionView.delegate = self
        titleLabel.text = nil
    }
}

// MARK: - UICollectionViewDelegate
extension FiltersContainerTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let currentText = viewModel?.dataSource.safeContains(indexPath.row)?.title ?? ""
        
        let label = UILabel()
        label.text = currentText
        
        return CGSize(width: label.intrinsicContentSize.width + 60, height: collectionView.frame.height)
    }
}

// MARK: - UICollectionViewDelegate
extension FiltersContainerTableViewCell: UICollectionViewDelegate {
    
}

// MARK: - UICollectionViewDataSource
extension FiltersContainerTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.dataSource.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let currentViewModel = viewModel?.dataSource.safeContains(indexPath.row)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCollectionViewCell.getReuseIdentifier, for: indexPath)
        (cell as? ConfigurableCellProtocol)?.setupWith(dataSource: currentViewModel, indexPath: indexPath, delegate: nil)
        
        return cell
    }
}
