//
//  Transaction.swift
//  Financas pessoais
//
//  Created by Roberto Edgar Geiss on 13/07/25.
//

// MARK: - Models
import SwiftData
import Foundation

@Model
final class Transaction: @unchecked Sendable {
    var id: UUID
    var amount: Decimal
    var transactionDescription: String
    var date: Date
    var category: TransactionCategory
    var type: TransactionType
    var account: Account?
    
    init(
      id: UUID = UUID(),
        amount: Decimal,
      description: String,
        date: Date,
        category: TransactionCategory,
        type: TransactionType,
        account: Account? = nil
    ) {
        self.id = id
        self.amount = amount
        self.transactionDescription = description
        self.date = date
        self.category = category
        self.type = type
        self.account = account
    }
}

