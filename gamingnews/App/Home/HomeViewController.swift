//
//  HomeViewController.swift
//  gamingnews
//
//  Created by Carlos Mejia on 3/14/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import UIKit

class HomeViewController: BaseViewController {
    // MARK: - UI References
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    private var viewModel = HomeViewModel()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard viewModel.dataSource.isEmpty else {
            return
        }
        
        viewModel.fetchData()
    }
    
    // MARK: - Private Methods
    
    /**
     Method to setup the UI.
     **/
    private func setupUI() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.registerAllCells()
    }
    
    // MARK: - Override Methods
    override func performLoading(isLoadig: Bool) {
        DispatchQueue.main.async { [weak self] in
            isLoadig ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
        }
    }
    
    override func requestLoaded() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.width - 10
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentViewModel = viewModel.dataSource.safeContains(indexPath.row)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: currentViewModel?.identifier ?? "", for: indexPath)
        (cell as? ConfigurableCellProtocol)?.setupWith(dataSource: currentViewModel?.viewModel, indexPath: indexPath, delegate: self)

        return cell
    }
}

// MARK: - NewsTableViewCellDelegate
extension HomeViewController: NewsTableViewCellDelegate {
    func cellTapped(_ in: NewsTableViewCell, at: IndexPath?) {}
}
