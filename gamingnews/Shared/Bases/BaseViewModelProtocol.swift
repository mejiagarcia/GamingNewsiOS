//
//  BaseViewModelProtocol.swift
//  gamingnews
//
//  Created by Carlos Mejia on 3/14/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import Foundation

enum NetworkResultType {
    case success(result: Any?)
    case error(meesage: String?)
}

protocol BaseViewModelProtocol: class {
    func performLoading(isLoadig: Bool)
    func performNetworkResult(_ result: NetworkResultType)
    func requestLoaded()
}
