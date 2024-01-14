// The Swift Programming Language
// https://docs.swift.org/swift-book

@attached(extension, conformances: EndpointProtocol, names: named(Response))
public macro Endpoint() = #externalMacro(module: "LCToolMacros", type: "EndpointMacro")

@attached(member, names: named(store), named(webservice), named(dataTaskAsync(dto:options:)))
public macro Repository() = #externalMacro(module: "LCToolMacros", type: "RepositoryMacro")

@attached(member, names: named(repository), named(init(key:repo:)), named(currentValue), named(config), named(key))
@attached(extension, conformances: CAPreviewProtocol, CAUsecaseProtocol,
          names: named(inject(key:)), named(keys), named(label), named(dataFetch(dto:options:)))
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
