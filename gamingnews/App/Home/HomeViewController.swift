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
    
    private var searchbar: UISearchBar = {
        let searchbar = UISearchBar()
        searchbar.keyboardAppearance = .dark
        searchbar.placeholder = "search.placeholder".localized
        searchbar.barTintColor = .white
        
        return searchbar
    }()
    
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
        
        dismissKeyboard()
        
        guard viewModel.dataSource.isEmpty else {
            return
        }
        
        viewModel.fetchData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private Methods
    
    /**
     Method to setup the UI.
     **/
    private func setupUI() {
        searchbar.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 47)
        searchbar.delegate = self
        
        tableView.keyboardDismissMode = .interactive
        tableView.tableHeaderView = searchbar
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.registerAllCells()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(toggleSearchbar),
                                               name: NSNotification.Name(Constants.NotificationCenter.toggleSearch),
                                               object: nil)
    }
    
    @objc private func dismissKeyboard() {
        searchbar.resignFirstResponder()
    }
    
    @objc private func toggleSearchbar() {
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

// MARK: - UISearchBarDelegate
extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            viewModel.resetFilters()
            
            return
        }
        
        viewModel.filterBy(string: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else {
            viewModel.resetFilters()
            
            return
        }
        
        viewModel.filterBy(string: text)
        dismissKeyboard()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.resetFilters()
        dismissKeyboard()
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.width - 10
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(viewModel.dataSource.count) \("search.results".localized)"
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
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
    func cellTapped(_ in: NewsTableViewCell, at indexPath: IndexPath) {
        guard let currentViewModel = viewModel.dataSource.safeContains(indexPath.row)?.viewModel as? NewsCellViewModel else {
            return
        }
        
        let detailVC = NewsDetailViewController(url: currentViewModel.websiteUrl ?? "", title: currentViewModel.title)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
