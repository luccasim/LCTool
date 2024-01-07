//___FILEHEADER___
//  Template: 5.0

import XCTest

final class ___VARIABLE_ModuleName:identifier___UITests: XCTestCase {
    
    let app = XCUIApplication()

    override func setUpWithError() throws {
        app.setupFreebox()
//        app.addCommandLine(arguement: "-COMMUN_ARGUMENT")
    }
    
    // Example
    func test_ExplicitTestName() throws {
        
        // Given
//        app.addCommandLine(arguement: "-TEST_ARGUMENT")
        app.launch()

        // When
        app.rootToHome()
        
        
        // Then
        app.assertAnalytics(key: "__Analytics_Key__")
    }
    
}
