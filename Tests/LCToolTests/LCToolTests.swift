import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
//import LCLib

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(LCToolMacros)
import LCToolMacros

let testMacros: [String: Macro.Type] = [
    "stringify": StringifyMacro.self,
    "Endpoint": EndpointMacro.self,
    "Repository": RepositoryMacro.self
]
#endif

final class LCToolTests: XCTestCase {
    
    func testRepository() throws {
        assertMacroExpansion(
            """
            @Repository
            final class TestRepository: TestRepositoryProtocol {
                    
                private func fetchEndpoint(dto: TestDTO) async throws -> TestDTO {
                    dto
                }
                    
                private func fetch(dto: TestDTO) async throws -> TestDTO {
                    do {
                        return try await fetchEndpoint(dto: dto)
                    } catch let error {
                        throw error
                    }
                }
            }
            """,
            expandedSource: 
            """
            
            final class TestRepository: TestRepositoryProtocol {
                    
                private func fetchEndpoint(dto: TestDTO) async throws -> TestDTO {
                    dto
                }
                    
                private func fetch(dto: TestDTO) async throws -> TestDTO {
                    do {
                        return try await fetchEndpoint(dto: dto)
                    } catch let error {
                        throw error
                    }
                }
            
                var store = CAStoreManager.shared
                var webservice = CAURLSessionManager()
            
                func dataTaskAsync(dto: TestDTO, options: [CAUsecaseOption]) async throws -> TestDTO {
                    webservice.set(options: options)
                    return try await fetch(dto: dto)
                }
            }
            """,
            macros: testMacros
        )
    }
    
    func testEndpoint() throws {
        assertMacroExpansion(
            """
            @Endpoint
            struct TestEndpoint: Codable {
                var httpHeader: [String: String] = [:]
            }
            """,
            expandedSource: """
            
            struct TestEndpoint: Codable {
                var httpHeader: [String: String] = [:]
            }
            
            extension TestEndpoint: EndpointProtocol {
                typealias Response = TestResponse
            }
            """,
            macros: testMacros
        )
    }
    
    func testMacro() throws {
        #if canImport(LCToolMacros)
        assertMacroExpansion(
            """
            #stringify(a + b)
            """,
            expandedSource: """
            (a + b, "a + b")
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithStringLiteral() throws {
        #if canImport(LCToolMacros)
        assertMacroExpansion(
            #"""
            #stringify("Hello, \(name)")
            """#,
            expandedSource: #"""
            ("Hello, \(name)", #""Hello, \(name)""#)
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
