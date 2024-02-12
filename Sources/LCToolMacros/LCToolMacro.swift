import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct EndpointMacro: ExtensionMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, 
                                 attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
                                 providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
                                 conformingTo protocols: [SwiftSyntax.TypeSyntax],
                                 in context: some SwiftSyntaxMacros.MacroExpansionContext)
    throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            return []
        }
        
        let identifier = structDecl.name.text.replacingOccurrences(of: "Endpoint", with: "")
        
        let sendableExtension: DeclSyntax =
          """
          extension \(raw: structDecl.name.text): EndpointProtocol {
              typealias Response = \(raw: identifier)Response
          }
          """

        guard let extensionDecl = sendableExtension.as(ExtensionDeclSyntax.self) else {
          return []
        }
        
        return [extensionDecl]
    }
}

// MARK: - Repository

public struct RepositoryMacro: MemberMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, 
                                 providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
                                 in context: some SwiftSyntaxMacros.MacroExpansionContext)
    throws -> [SwiftSyntax.DeclSyntax] {
        
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            return []
        }
        
        let identifier = classDecl.name.text.replacingOccurrences(of: "Repository", with: "")
        
        let decl: DeclSyntax =
          """
          var store = CAStoreManager.shared
          var webservice = CAURLSessionManager()
          
          func dataTaskAsync(dto: \(raw: identifier)DTO, options: [CAUsecaseOption]) async throws -> \(raw: identifier)DTO {
              webservice.set(options: options)
              return try await fetch(dto: dto)
          }
          """
        
        return [DeclSyntax(decl)]
    }
}

// MARK: - Usecase

public struct UsecaseMacro: MemberMacro, ExtensionMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, 
                                 attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
                                 providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
                                 conformingTo protocols: [SwiftSyntax.TypeSyntax],
                                 in context: some SwiftSyntaxMacros.MacroExpansionContext)
    throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            return []
        }
        
        let identifier = classDecl.name.text.replacingOccurrences(of: "Usecase", with: "")
        
        let sendableExtension: DeclSyntax =
          """
          extension \(raw: classDecl.name.text): CAPreviewProtocol {
              var keys: [CAPreviewKey] { Key.allCases.map({ .init(label: $0.label, key: $0.rawValue) }) }
              func inject(key: String?) { \(raw: identifier)Usecase.currentValue = key.flatMap({Key(rawValue: $0)}).map({\(raw: identifier)Usecase(key: $0)}) ?? self }
              var label: String { "\(raw: identifier)" }
          }
          
          extension \(raw: classDecl.name.text): CAUsecaseProtocol {
              func dataFetch(dto: \(raw: identifier)DTO?, options: [CAUsecaseOption]) async throws -> \(raw: identifier)DTO {
                  try await repository.dataTaskAsync(dto: dto ?? .init(), options: options)
              }
              func hello() {
                  print("Hello")
              }
          }
          
          extension \(raw: classDecl.name.text): CAInjectionKey {
              static var currentValue: \(raw: identifier)UsecaseProtocol = \(raw: identifier)Usecase()
          }
          """

        guard let extensionDecl = sendableExtension.as(ExtensionDeclSyntax.self) else {
          return []
        }
        
        return [extensionDecl]
    }
    
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, 
                                 providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
                                 in context: some SwiftSyntaxMacros.MacroExpansionContext)
    throws -> [SwiftSyntax.DeclSyntax] {
        
        if let _ = declaration.as(ProtocolDeclSyntax.self) {
            let decl: DeclSyntax =
              """
             func hello()
             """
            return [decl]
        }
        
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            return []
        }
        
        let identifier = classDecl.name.text.replacingOccurrences(of: "Usecase", with: "")
        
        let decl: DeclSyntax =
          """
          let repository = \(raw: identifier)Repository()
          var config: [CAUsecaseOption] = []
          private let key: Key
          
          init(key: Key? = nil) {
              self.key = key ?? .prod
              self.config = key.flatMap({[.useTestUIServer(mock: $0.rawValue)]}) ?? []
          }
          """
        
        return [DeclSyntax(decl)]
    }
}

@main
struct LCToolPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        EndpointMacro.self,
        RepositoryMacro.self,
        UsecaseMacro.self
    ]
}
