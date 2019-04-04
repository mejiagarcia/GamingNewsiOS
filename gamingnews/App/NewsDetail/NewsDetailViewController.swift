//
//  NewsDetailViewController.swift
//  gamingnews
//
//  Created by Carlos Mejia on 3/15/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import UIKit
import Lottie

class NewsDetailViewController: BaseViewController {
    // MARK: - UI References
    @IBOutlet weak var webview: UIWebView!
    
    // MARK: - Properties
    private var viewModel: NewsDetailViewModel!
    private var favoriteButton: UIButton!
    
    // MARK: - Life Cycle
    convenience init(viewModel: NewsDetailViewModel) {
        self.init()
        
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if viewModel == nil {
            safeDismiss()
            
            return
        }
    }
    
    // MARK: - Private Methods
    
    /**
     Method to setup the UI.
     */
    private func setupUI() {
        title = viewModel.customTitle
        webview.delegate = self
        
        startLoadingAnimation()
        setupFavoriteIcon()
        loadUrl()
    }
    
    /**
     Method to the icons.
     **/
    private func setupFavoriteIcon() {
        favoriteButton = UIButton(type: .roundedRect)
        favoriteButton.addTarget(self, action: #selector(performFavoriteAction), for: .touchUpInside)
        favoriteButton.tintColor = viewModel.isCurrentFavoriteSaved() ? .yellow : .white
        favoriteButton.setImage(UIImage(named: "ic_star_on"), for: .normal)
        favoriteButton.frame = CGRect(x: 0, y: 0, width: 22, height: 15)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: favoriteButton)
    }
   
    @objc private func performFavoriteAction() {
        viewModel.toggleFavorite()
        favoriteButton.tintColor = viewModel.isCurrentFavoriteSaved() ? .yellow : .white
    }
    
    /**
     Method to load the URL requested in the current WebView.
     */
    private func loadUrl() {
        guard let url = URL(string: viewModel.webUrl) else {
            return
        }
        
        webview.loadRequest(URLRequest(url: url))
    }
    
    // MARK: - Override Methods
    override func performLoading(isLoadig: Bool) {}
}

// MARK: - UIWebViewDelegate
extension NewsDetailViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.webview.stringByEvaluatingJavaScript(from: "document.getElementsByClassName('touch-header')[0].remove()")
        self.webview.stringByEvaluatingJavaScript(from: "document.getElementsByClassName('footer')[0].remove()")
        
        stopLoadingAnimation()
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        if navigationType == .linkClicked {
            return false
        }
        
        return true
    }
}
