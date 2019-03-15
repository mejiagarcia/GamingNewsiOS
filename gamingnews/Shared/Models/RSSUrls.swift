//
//  RSSUrls.swift
//  gamingnews
//
//  Created by Carlos Mejia on 3/14/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import Foundation

struct RSSUrls: Codable {
    let language: RSSUrlsLang
    let all: [String]
    let ps4: [String]
    let xboxO: [String]
    let `switch`: [String]
    let pc: [String]
    
    private enum CodingKeys: String, CodingKey {
        case language, all = "all_urls", ps4 = "ps4_urls", xboxO = "xboxO_urls", `switch` = "switch_urls", pc = "pc_urls"
    }
}

enum RSSUrlsLang: String, Codable {
    case english = "en"
    case spanish = "es"
}
