//___FILEHEADER___
//  Template: 7.0

import Testing
@testable import Integration

@Suite("___VARIABLE_ModuleName:identifier___")
struct ___VARIABLE_ModuleName:identifier___UsecaseUnitTests {
    
    let sut: ___VARIABLE_ModuleName:identifier___UsecaseProtocol
    let repository: MockRepository
    
    init() async throws {
        repository = MockRepository()
        sut = ___VARIABLE_ModuleName:identifier___Usecase(repository: repository)
    }
    
    // MARK: - Success
    
    @Test()
    func testExampleSuccess() async throws {
        // Given
        let input = ___VARIABLE_ModuleName:identifier___Usecase.Input()
        
        // When
        let result = try await sut.execute(input: input)

        // Then
        #expect(true)
    }
    
    // MARK: - Failures
    
    @Test()
    func testExampleFailure() async throws {
        // Given
        let input = ___VARIABLE_ModuleName:identifier___Usecase.Input()
        
        // When

        // Then
        await #expect(throws: ___VARIABLE_ModuleName:identifier___Usecase.Failure.missingInput) {
            try await sut.execute(input: input)
        }
    }
}

// MARK: - Mock

actor Mock___VARIABLE_ModuleName:identifier___Usecase: ___VARIABLE_ModuleName:identifier___UsecaseProtocol {
    
    private let mockUsecase = GenericMockUsecase<___VARIABLE_ModuleName:identifier___Usecase.Result, ___VARIABLE_ModuleName:identifier___Usecase.Input>()
    
    func execute(input: ___VARIABLE_ModuleName:identifier___Usecase.Input) async throws -> ___VARIABLE_ModuleName:identifier___Usecase.Result {
        try await mockUsecase.execute(input: input)
    }
    
    func setFakeResult(_ result: ___VARIABLE_ModuleName:identifier___Usecase.Result) async {
        await mockUsecase.set(result: result)
    }
    
    func setFakeError(_ error: Error) async {
        await mockUsecase.set(error: error)
    }
}
