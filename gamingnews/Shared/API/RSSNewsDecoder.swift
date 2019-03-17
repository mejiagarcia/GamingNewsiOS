//
//  RSSNewsDecoder.swift
//  gamingnews
//
//  Created by Carlos Mejia on 3/17/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import Foundation
import SWXMLHash

enum RssDecodeStrategy: CaseIterable {
    case itemsParent
    case singleItems
}

class RSSNewsDecoder {
    // MARK: - Properties
    private(set) var dataSource = [News]()
    private let keys = News.XMLKeys.self
    
    // MARK: - Public Methods
    func tryToDecodeWithAllStrategies(_ index: Int = 0, xml: XMLIndexer) {
        let strategies: [RssDecodeStrategy] = RssDecodeStrategy.allCases
        
        let result = setupNewsModelsFromRSSData(strategy: strategies[index], with: xml)
        
        if result.isEmpty {
            tryToDecodeWithAllStrategies(index + 1, xml: xml)
            
            return
        }
        
        dataSource = result
    }
    
    // MARK: - Private Methods
    
    private func setupNewsModelsFromRSSData(strategy: RssDecodeStrategy, with data: XMLIndexer) -> [News] {
        if strategy == .itemsParent {
            return performItemsParentStrategy(data: data)
        }
        
        if strategy == .singleItems {
            return performSingleItemStrategy(data: data)
        }
        
        return []
    }
    
    private func performItemsParentStrategy(data: XMLIndexer) -> [News] {
        let xmlItems = data[keys.rss][keys.channel][keys.item].all
        var result = [News]()
        
        xmlItems.forEach {
            guard
                let title = $0[keys.title].element?.text,
                let desc = $0[keys.description].element?.text else {
                    return
            }
            
            let model = News(title: title,
                             description: desc,
                             link: $0[keys.link].element?.text ?? "",
                             pubDate: $0[keys.pubDate].element?.text ?? "")
            
            result.append(model)
        }
        
        return result
    }
    
    private func performSingleItemStrategy(data: XMLIndexer) -> [News] {
        let xmlItems = data[keys.rss][keys.channel].all
        var result = [News]()
        
        xmlItems.forEach {
            guard
                let title = $0[keys.title].element?.text,
                let desc = $0[keys.description].element?.text else {
                    return
            }
            
            let model = News(title: title,
                             description: desc,
                             link: $0[keys.link].element?.text ?? "",
                             pubDate: $0[keys.pubDate].element?.text ?? "")
            
            result.append(model)
        }
        
        return result
    }
}
