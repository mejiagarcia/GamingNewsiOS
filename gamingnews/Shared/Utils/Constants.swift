//
//  Constants.swift
//  gamingnews
//
//  Created by Carlos Mejia on 3/14/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import UIKit

struct Constants {
    struct General {
        struct Lang {
            static let english = "en"
        }
    }
    
    struct Animations {
        static let generalTime: TimeInterval = 0.3
    }
    
    struct Api {
        struct EndpointsFile {
            static let `extension` = "plist"
            static let name = "Endpoints"
        }
        
        struct Endpoints {
            static let baseUrl = "baseUrl"
        }
        
        static let authorization = "Authorization"
        static let contentTypeName = "Content-Type"
        static let contentType = "application/json; charset=utf-8"
    }
}
