//
//  News.swift
//  gamingnews
//
//  Created by Carlos Mejia on 3/15/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import Foundation

protocol NewsItemProtocol {
    var title: String { get }
    var description: String { get }
    var link: String { get }
    var pubDate: String? { get }
}

struct News: NewsItemProtocol, Codable {
    let title: String
    let description: String
    let link: String
    let pubDate: String?
    
    var createdAt: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        
        let finalDate = dateFormatter.date(from: pubDate ?? "")
        
        return finalDate ?? Date()
    }
    
    var fullDescription: String {
        return description.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
    
    var imageUrl: String? {
        guard let regex = try? NSRegularExpression(pattern: "<img src=\u{22}(.*?)\u{22} alt=\u{22}\u{22}/>", options: []) else {
            return ""
        }
        
        var results = [String]()
        
        let range = NSRange(location: 0, length: description.utf16.count)
        
        regex.enumerateMatches(in: description, options: [], range: range) { result, _, _ in
            if let reses = result?.range(at: 1), let range = Range(reses, in: description) {
                results.append(String(description[range]))
            }
        }
        
        let finalResult = results.first?.replacingOccurrences(of: "300x", with: "500x")
        
        return finalResult
    }
    
    struct XMLKeys {
        static let rss = "rss"
        static let channel = "channel"
        static let item = "item"
        static let title = "title"
        static let description = "description"
        static let link = "link"
        static let pubDate = "pubDate"
    }
}
