// The Swift Programming Language
// https://docs.swift.org/swift-book

/// A macro that produces both a value and a string containing the
/// source code that generated the value. For example,
///
///     #stringify(x + y)
///
/// produces a tuple `(x + y, "x + y")`.
@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(module: "LCToolMacros", type: "StringifyMacro")

@attached(extension, conformances: EndpointProtocol, names: named(Response))
public macro Endpoint() = #externalMacro(module: "LCToolMacros", type: "EndpointMacro")

@attached(member, names: named(store), named(webservice), named(dataTaskAsync(dto:options:)))
public macro Repository() = #externalMacro(module: "LCToolMacros", type: "RepositoryMacro")

@attached(member, names: named(repository), named(init(key:repo:)), named(dataFetch(dto:options:)))
public macro Usecase() = #externalMacro(module: "LCToolMacros", type: "UsecaseMacro")

import Foundation

// MARK: Endpoint

struct ChatResponse: Codable {
    
}

@Endpoint
struct ChatEndpoint {
    var request: URLRequest?
}


// MARK: - Repository

struct ChatDTO {
    
}

protocol ChatRepositoryProtocol {
    func dataTaskAsync(dto: ChatDTO, options: [CAUsecaseOption]) async throws -> ChatDTO
}

@Repository
final class ChatRepository: ChatRepositoryProtocol {

    private func fetchEndpoint(dto: ChatDTO) async throws -> ChatDTO {
        dto
    }
        
    private func fetch(dto: ChatDTO) async throws -> ChatDTO {
        do {
            return try await fetchEndpoint(dto: dto)
        } catch let error {
            throw error
        }
    }
}

// MARK: - Usecase

protocol ChatUsecaseProtocol {
    func dataTaskAsync(dto: ChatDTO?, options: [CAUsecaseOption]) async throws -> ChatDTO
 }

extension CAInjectedValues {
    var keyChat: ChatUsecaseProtocol {
        get { Self[ChatUsecase.self] }
        set { Self[ChatUsecase.self] = newValue }
    }
}

extension ChatUsecase: CAInjectionKey, CAPreviewProtocol, ChatUsecaseProtocol {
    
    var keys: [CAPreviewKey] { Key.allCases.map({ .init(label: $0.label, key: $0.rawValue) }) }
    func inject(key: String?) { ChatUsecase.currentValue = key.flatMap({Key(rawValue: $0)}).map({ChatUsecase(key: $0)}) ?? self }
}

final class ChatUsecase: CAUsecaseProtocol {
    
    static var currentValue: ChatUsecaseProtocol = ChatUsecase()
    
    private let key: Key
    private let repository: ChatRepositoryProtocol
    
    var config: [CAUsecaseOption] = []
    
    init(key: Key? = nil, repo: ChatRepositoryProtocol = ChatRepository()) {
        self.repository = repo
        self.key = key ?? .prod
        self.config = key.flatMap({[.useTestUIServer(mock: $0.rawValue)]}) ?? []
    }
    
    enum Key: String, CaseIterable {
        
        case prod, luc, jean, pierre
        
        var label: String {
            switch self {
            case .prod: return "Production"
            default: return self.rawValue
            }
        }
    }
    
    func dataFetch(dto: ChatDTO?, options: [CAUsecaseOption]) async throws -> ChatDTO {
        try await repository.dataTaskAsync(dto: dto ?? .init(), options: options)
    }
}
