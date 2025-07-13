//
//  Budget.swift
//  Financas pessoais
//
//  Created by Roberto Edgar Geiss on 13/07/25.
//

@Model
final class Budget: @unchecked Sendable {
    var id: UUID
    var category: TransactionCategory
    var limit: Decimal
    var spent: Decimal
    var month: Int
    var year: Int
    var user: User?
    
    init(
        id: UUID = UUID(),
        category: TransactionCategory,
        limit: Decimal,
        spent: Decimal = 0,
        month: Int,
        year: Int,
        user: User? = nil
    ) {
        self.id = id
        self.category = category
        self.limit = limit
        self.spent = spent
        self.month = month
        self.year = year
        self.user = user
    }
}
