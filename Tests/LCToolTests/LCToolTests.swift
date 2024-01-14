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
    "Repository": RepositoryMacro.self,
    "Usecase": UsecaseMacro.self
]
#endif

final class LCToolTests: XCTestCase {
    
    func testUsecase() throws {
        assertMacroExpansion(
            """
            @Usecase
            final class ChatUsecase: CAInjectionKey, ChatUsecaseProtocol {
            
                enum Key: String, CaseIterable {
                    
                    case prod, luc, jean, pierre
                    
                    var label: String {
                        switch self {
                        case .prod: return "Production"
                        default: return self.rawValue
                        }
                    }
                }
            }
            """,
            expandedSource:
            """

            final class ChatUsecase: CAInjectionKey, ChatUsecaseProtocol {
            
                enum Key: String, CaseIterable {
                    
                    case prod, luc, jean, pierre
                    
                    var label: String {
                        switch self {
                        case .prod: return "Production"
                        default: return self.rawValue
                        }
                    }
                }
            
                static var currentValue: ChatUsecaseProtocol = ChatUsecase()
                let repository: ChatRepositoryProtocol
                var config: [CAUsecaseOption] = []
                private let key: Key
            
                init(key: Key? = nil, repo: ChatRepositoryProtocol = ChatRepository()) {
                    self.repository = repo
                    self.key = key ?? .prod
                    self.config = key.flatMap({[.useTestUIServer(mock: $0.rawValue)]}) ?? []
                }
            }
            
            extension ChatUsecase: CAPreviewProtocol {
                var keys: [CAPreviewKey] {
                    Key.allCases.map({
                            .init(label: $0.label, key: $0.rawValue)
                        })
                }
                func inject(key: String?) {
                    ChatUsecase.currentValue = key.flatMap({
                            Key(rawValue: $0)
                        }).map({
                            ChatUsecase(key: $0)
                        }) ?? self
                }
                var label: String {
                    "Chat"
                }
            }
            
            extension ChatUsecase: CAUsecaseProtocol {
                func dataFetch(dto: ChatDTO?, options: [CAUsecaseOption]) async throws -> ChatDTO {
                    try await repository.dataTaskAsync(dto: dto ?? .init(), options: options)
                }
            }
            """,
            macros: testMacros
        )
    }
    
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
