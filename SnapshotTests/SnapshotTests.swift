//
//  SnapshotTests.swift
//  SnapshotTests
//
//  Created by Mason Phillips on 11/30/21.
//

import XCTest

class SnapshotTests: XCTestCase {

    override func setUpWithError() throws {
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        
        continueAfterFailure = false    
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGetSnapshots() {
        let app = XCUIApplication()
        
        snapshot("currLoc")
        
        let homeNavigationBar = app.navigationBars["Home"]
        homeNavigationBar.buttons["Item"].tap()
        let search = homeNavigationBar.children(matching: .other).element.children(matching: .other).element.children(matching: .searchField).element
        search.tap()
        search.typeText("Austin, TX")
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Austin, Texas, United States of America"]/*[[".cells.staticTexts[\"Austin, Texas, United States of America\"]",".staticTexts[\"Austin, Texas, United States of America\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.scrollViews.children(matching: .other).element.children(matching: .other).element.swipeLeft()
        
        snapshot("chosenLoc")
    }
}
