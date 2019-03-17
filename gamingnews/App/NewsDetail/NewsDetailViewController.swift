//
//  NewsDetailViewController.swift
//  gamingnews
//
//  Created by Carlos Mejia on 3/15/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import UIKit

class NewsDetailViewController: BaseViewController {
    // MARK: - UI References
    @IBOutlet weak var webview: UIWebView!
    
    // MARK: - Properties
    private var webUrl: String?
    private var customTitle: String?
    
    convenience init(url: String, title: String) {
        self.init()
        
        customTitle = title
        webUrl = url
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = customTitle
        webview.delegate = self
        
        guard let url = URL(string: webUrl ?? "") else {
            return
        }
        
        webview.loadRequest(URLRequest(url: url))
    }
}

// MARK: - UIWebViewDelegate
extension NewsDetailViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.webview.stringByEvaluatingJavaScript(from: "document.getElementsByClassName('touch-header')[0].remove()")
        self.webview.stringByEvaluatingJavaScript(from: "document.getElementsByClassName('footer')[0].remove()")
    }
}
