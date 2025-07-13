//
//  User.swift
//  Financas pessoais
//
//  Created by Roberto Edgar Geiss on 13/07/25.
//

import Foundation

@Model
final class User: @unchecked Sendable {
    var id: UUID
    var email: String
    var name: String
    var profileImageData: Data?
    var createdAt: Date
    var preferredCurrency: String
    @Relationship(deleteRule: .cascade) var accounts: [Account]
    @Relationship(deleteRule: .cascade) var budgets: [Budget]
    
    init(
        id: UUID = UUID(),
        email: String,
        name: String,
        profileImageData: Data? = nil,
        createdAt: Date = Date(),
        preferredCurrency: String = "BRL"
    ) {
        self.id = id
        self.email = email
        self.name = name
        self.profileImageData = profileImageData
        self.createdAt = createdAt
        self.preferredCurrency = preferredCurrency
        self.accounts = []
        self.budgets = []
    }
}
