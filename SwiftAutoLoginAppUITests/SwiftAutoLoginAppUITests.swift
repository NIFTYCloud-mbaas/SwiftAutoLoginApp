//
//  SwiftAutoLoginAppUITests.swift
//  SwiftAutoLoginAppUITests
//
//  Created by HungNV on 4/14/21.
//  Copyright © 2021 NIFTY Corporation. All rights reserved.
//

import XCTest

class SwiftAutoLoginAppUITests: XCTestCase {

    var app: XCUIApplication!
    let msgSignUpDone = "はじめまして！"
    let msgLoginDone = "おかえりなさい"
    let msgLastVisit = "最終ログイン"
    
    // MARK: - Setup for UI Test
    override func setUp() {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        app = XCUIApplication()
    }
    
    func testAutoLoginScreen() throws {
        app.launch()
        XCTAssert(app.staticTexts["AutoLoginApp"].exists)
        if app.staticTexts[msgSignUpDone].waitForExistence(timeout: 10) {
            XCTAssert(app.staticTexts[msgSignUpDone].exists)
        } else {
            XCTAssert(app.staticTexts[msgLoginDone].exists)
            XCTAssert(app.staticTexts[msgLastVisit].exists)
        }
    }
}
