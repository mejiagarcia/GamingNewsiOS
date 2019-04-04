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
    private var animationView: AnimationView?
    
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
        
        setupLoadAnimation()
        loadUrl()
    }
    
    /**
     Method to setup the LottieView to show the loader animation.
     */
    private func setupLoadAnimation() {
        animationView = AnimationView(name: Animations.detail)
        animationView?.translatesAutoresizingMaskIntoConstraints = false
        animationView?.loopMode = .loop
        
        guard let animationView = animationView else {
            return
        }
        
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: animationView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: animationView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: animationView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 100),
            NSLayoutConstraint(item: animationView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 100)
        ])
        
        animationView.play()
    }
    
    /**
     Method to stop and remove from the view hierarchy the LottieView.
     */
    private func stopAnimation() {
        animationView?.stop()
        animationView?.removeFromSuperview()
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
        
        stopAnimation()
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        if navigationType == .linkClicked {
            return false
        }
        
        return true
    }
}
