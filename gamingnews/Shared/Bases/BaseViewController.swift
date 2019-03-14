//
//  BaseViewController.swift
//  gamingnews
//
//  Created by Carlos Mejia on 3/14/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import UIKit
import Hero

class BaseViewController: UIViewController, BaseViewModelProtocol {
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hero.isEnabled = true
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
