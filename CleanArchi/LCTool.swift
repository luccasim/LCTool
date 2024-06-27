// The Swift Programming Language
// https://docs.swift.org/swift-book

@attached(extension, 
          conformances: EndpointProtocol,
          names: named(Response))
public macro Endpoint() = #externalMacro(module: "LCToolMacros", type: "EndpointMacro")

@attached(member, 
          names: named(store),
          named(webservice),
          named(dataTaskAsync(dto:options:)))
public macro Repository() = #externalMacro(module: "LCToolMacros", type: "RepositoryMacro")

@attached(member, 
          names: named(repository),
          named(init(key:)),
          named(config),
          named(key),
          named(hello))
@attached(extension, 
          conformances: CAPreviewProtocol, CAUsecaseProtocol, CAInjectionKey,
          names: named(inject(key:)),
          named(keys), 
          named(label),
          named(currentValue),
          named(dataFetch(dto:options:)),
          named(hello))
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

@Repository
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

@Usecase
protocol ChatUsecaseProtocol {
    func dataTaskAsync(dto: ChatDTO?, options: [CAUsecaseOption]) async throws -> ChatDTO
 }

@Usecase
final class ChatUsecase: ChatUsecaseProtocol {
    
    // @Repository(\.Chat) var repository
    
    func input(dto: ChatDTO?) throws -> ChatDTO? {
        return dto
    }
    
    func output(dto: ChatDTO) throws -> ChatDTO {
        return dto
    }
    
    // Errors
    
    enum Error {
        
    }
    
    func mapError() {
        
    }

    enum Key: String, CaseIterable, PostmanKey {
        case prod, test, un, deux, trois
    }
}
