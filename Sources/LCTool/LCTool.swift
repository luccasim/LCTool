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

import Foundation

// MARK: Endpoint

struct ChatResponse: Codable {
    
}

@Endpoint
struct ChatEndpoint {
    var request: URLRequest?
}


// MARK: - Repository

struct TestDTO {
    
}

protocol TestRepositoryProtocol {
    func dataTaskAsync(dto: TestDTO, options: [CAUsecaseOption]) async throws -> TestDTO
}

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
