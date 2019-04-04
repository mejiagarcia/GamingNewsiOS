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
    private var webUrl: String?
    private var customTitle: String?
    
    // MARK: - Life Cycle
    convenience init(url: String, title: String) {
        self.init()
        
        customTitle = title
        webUrl = url
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Private Methods
    
    /**
     Method to setup the UI.
     */
    private func setupUI() {
        title = customTitle
        webview.delegate = self
        
        startLoadingAnimation()
        loadUrl()
    }
   
    /**
     Method to load the URL requested in the current WebView.
     */
    private func loadUrl() {
        guard let url = URL(string: webUrl ?? "") else {
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
