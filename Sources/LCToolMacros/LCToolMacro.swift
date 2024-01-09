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

public struct EndpointMacro: MemberMacro, ExtensionMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, 
                                 providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
                                 in context: some SwiftSyntaxMacros.MacroExpansionContext)
    throws -> [SwiftSyntax.DeclSyntax] {
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

//        let extensionDecl = try ExtensionDeclSyntax("Test") {
//            let initializerClauseDecl = TypeInitializerClauseSyntax(value: TypeSyntax(stringLiteral: "\(identifier)Response"))
//            let typeAliasDecl = TypeAliasDeclSyntax(name: "Response", initializer: initializerClauseDecl)
//        }
        
        return [DeclSyntax(extensionDecl)]
    }
    
    
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

//        let extensionDecl = try ExtensionDeclSyntax("Test") {
//            let initializerClauseDecl = TypeInitializerClauseSyntax(value: TypeSyntax(stringLiteral: "\(identifier)Response"))
//            let typeAliasDecl = TypeAliasDeclSyntax(name: "Response", initializer: initializerClauseDecl)
//        }
        
        return [extensionDecl]
        
//        return []
    }
    
    
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, 
                                 providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
                                 in context: some SwiftSyntaxMacros.MacroExpansionContext) 
    throws -> [SwiftSyntax.DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            return []
        }
        return []
//        let identifier = structDecl.name.text.replacingOccurrences(of: "Endpoint", with: "")
//        
//        let initializerClauseDecl = TypeInitializerClauseSyntax(value: TypeSyntax(stringLiteral: "\(identifier)Response"))
//        let typeAliasDecl = TypeAliasDeclSyntax(name: "Response", initializer: initializerClauseDecl)
//        
//        return [DeclSyntax(typeAliasDecl)]
    }
}

@main
struct LCToolPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StringifyMacro.self,
        EndpointMacro.self
    ]
}
