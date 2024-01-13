import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Implementation of the `stringify` macro, which takes an expression
/// of any type and produces a tuple containing the value of that expression
/// and the source code that produced the value. For example
///
///     #stringify(x + y)
///
///  will expand to
///
///     (x + y, "x + y")
public struct StringifyMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.argumentList.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }

        return "(\(argument), \(literal: argument.description))"
    }
}

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

@main
struct LCToolPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StringifyMacro.self,
        EndpointMacro.self,
        RepositoryMacro.self
    ]
}
