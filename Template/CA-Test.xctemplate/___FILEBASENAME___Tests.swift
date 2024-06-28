//___FILEHEADER___
//  Template: 6.0

import XCTest
@testable import Integration

final class ___VARIABLE_ModuleName:identifier___Tests: XCTestCase {
    
    var mock: ___VARIABLE_ModuleName:identifier___RepositoryProtocol!
    var sut: ___VARIABLE_ModuleName:identifier___Usecase!
            
    override func setUpWithError() throws {
        mock = nil
        sut = nil
    }
    
    // MARK: - Assertion
    
    
    // MARK: - Tests
    
    func testExample() async throws {
        // Given
        mock = Mock___VARIABLE_ModuleName:identifier___Repository()
        sut = .init(repository: mock)
        
        // When
        let result = try await sut.dataTaskAsync(dto: .init())
        
        // Then
        XCTAssert(true)
    }
}

// MARK: - Mocks

private class Mock___VARIABLE_ModuleName:identifier___Repository: ___VARIABLE_ModuleName:identifier___RepositoryProtocol {

}
