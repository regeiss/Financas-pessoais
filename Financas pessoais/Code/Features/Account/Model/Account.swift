//
//  Account.swift
//  Financas pessoais
//
//  Created by Roberto Edgar Geiss on 13/07/25.
//

import Foundation
import SwiftData

@Model
final class Account: @unchecked Sendable {
    var id: UUID
    var name: String
    var balance: Decimal
    var accountType: AccountType
    var isActive: Bool
    var user: User?
    @Relationship(deleteRule: .cascade) var transactions: [Transaction]
    
    init(
        id: UUID = UUID(),
        name: String,
        balance: Decimal = 0,
        accountType: AccountType,
        isActive: Bool = true,
        user: User? = nil
    ) {
        self.id = id
        self.name = name
        self.balance = balance
        self.accountType = accountType
        self.isActive = isActive
        self.user = user
        self.transactions = []
    }
}
