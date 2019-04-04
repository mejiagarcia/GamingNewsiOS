//
//  BaseViewController.swift
//  gamingnews
//
//  Created by Carlos Mejia on 3/14/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import UIKit
import Hero
import Lottie

class BaseViewController: UIViewController, BaseViewModelProtocol {
    // MARK: - Properties
    var animationView: AnimationView?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hero.isEnabled = true
    }
    
    // MARK: - Public Methods
    
    /**
     Method to setup the LottieView to show the loader animation.
     */
    func startLoadingAnimation() {
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
    func stopLoadingAnimation() {
        animationView?.stop()
        animationView?.removeFromSuperview()
    }
    
    // MARK: - BaseViewModelProtocol
    func performLoading(isLoadig: Bool) {}
    
    func performNetworkResult(_ result: NetworkResultType) {
        switch result {
        case let .error(meesage):
            Dialogs.showAlertDialog(in: self,
                                    title: "errors.title".localized,
                                    message: meesage ?? "errors.genericMessage".localized)
        default:
            return
        }
    }
    
    func requestLoaded() {}
}
