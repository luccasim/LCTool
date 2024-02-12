import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(LCToolMacros)
import LCToolMacros

let testMacros: [String: Macro.Type] = [
    "Endpoint": EndpointMacro.self,
    "Repository": RepositoryMacro.self,
    "Usecase": UsecaseMacro.self
]
#endif

final class LCToolTests: XCTestCase {
    
    func testUsecaseProtocols() throws {
        assertMacroExpansion(
            """
            @Usecase
            protocol ChatUsecaseProtocol {
                func dataTaskAsync(dto: ChatDTO?, options: [CAUsecaseOption]) async throws -> ChatDTO
            }
            """,
            expandedSource: """
            
            protocol ChatUsecaseProtocol {
                func dataTaskAsync(dto: ChatDTO?, options: [CAUsecaseOption]) async throws -> ChatDTO
            
                func hello()
            }
            """,
            macros: testMacros
        )
    }
    
    func testUsecase() throws {
        assertMacroExpansion(
            """
            @Usecase
            final class ChatUsecase: ChatUsecaseProtocol {
            
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

            final class ChatUsecase: ChatUsecaseProtocol {
            
                enum Key: String, CaseIterable {
                    
                    case prod, luc, jean, pierre
                    
                    var label: String {
                        switch self {
                        case .prod: return "Production"
                        default: return self.rawValue
                        }
                    }
                }
            
                let repository = ChatRepository()
                var config: [CAUsecaseOption] = []
                private let key: Key
            
                init(key: Key? = nil) {
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
                func hello() {
                    print("Hello")
                }
            }
            
            extension ChatUsecase: CAInjectionKey {
                static var currentValue: ChatUsecaseProtocol = ChatUsecase()
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
}
