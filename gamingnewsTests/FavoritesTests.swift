//
//  FavoritesTests.swift
//  gamingnewsTests
//
//  Created by Carlos Mejia on 4/4/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import Foundation

import XCTest
@testable import gamingnews

class FavoritesTests: XCTestCase {
    // MARK: - Properties
    private var diskManager = FavoritesManager.shared
    private var mockModels = [News]()
    
    override func setUp() {
        for index in 0...10 {
            mockModels.append(News(title: "item_\(index)", description: "", link: "link_\(index)", pubDate: ""))
        }
    }
    
    override func tearDown() {
        mockModels = []
    }
    
    func testSave() {
        diskManager.deleteAll()
        let testItem = getRandomItem()
        
        diskManager.save(testItem)
      
        let retrievedItem = diskManager.getAll().filter { $0.link == testItem.link }.first
        
        XCTAssertTrue(retrievedItem != nil, "Unable to test `testSave`")
    }
    
    func testSingleRemove() {
        diskManager.deleteAll()
        
        // save 10 random items
        for _ in 0...9 {
            diskManager.save(getRandomItem())
        }
        
        let randomItemToDelete = diskManager.getAll()[Int.random(in: 0...9)]
        
        diskManager.delete(randomItemToDelete)
        
        let itemsSaved = diskManager.getAll()
        
        XCTAssertTrue(itemsSaved.filter { $0.link == randomItemToDelete.link }.isEmpty && itemsSaved.count == 9, "Unable to test `testSingleRemove`")
    }
    
    func testDeleteAll() {
        diskManager.deleteAll()
        
        XCTAssertTrue(diskManager.getAll().isEmpty, "Unable to test `testDeleteAll`")
    }
    
    private func getRandomItem() -> News {
        return mockModels[Int.random(in: 0...10)]
    }
}
