//
//  TransactionViewModel.swift
//  Financas pessoais
//
//  Created by Roberto Edgar Geiss on 16/07/25.
//

import SwiftData
import Foundation

@MainActor
@Observable
final class TransactionViewModel {
    private let errorManager: ErrorManagerProtocol
    private var modelContext: ModelContext?
    
    var transactions: [Transaction] = []
    var isLoading = false
    var errorMessage: String?
    
    init(errorManager: ErrorManagerProtocol = ErrorManager.shared) {
        self.errorManager = errorManager
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadTransactions()
    }
    
    func loadTransactions() {
        guard let context = modelContext else {
            errorManager.logWarning("ModelContext não definido", context: "TransactionViewModel.loadTransactions")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let descriptor = FetchDescriptor<Transaction>(
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            transactions = try context.fetch(descriptor)
            
            errorManager.logInfo("Transações carregadas: \(transactions.count)", context: "TransactionViewModel.loadTransactions")
        } catch {
            errorManager.handle(error, context: "TransactionViewModel.loadTransactions")
            errorMessage = "Erro ao carregar transações"
        }
        
        isLoading = false
    }
    
    func addTransaction(
        amount: Decimal,
        description: String,
        category: TransactionCategory,
        type: TransactionType,
        account: Account?
    ) {
        guard let context = modelContext else {
            errorManager.logWarning("ModelContext não definido", context: "TransactionViewModel.addTransaction")
            return
        }
        
        guard amount > 0 else {
            errorMessage = "Valor deve ser maior que zero"
            return
        }
        
        do {
            let finalAmount = type == .expense ? -amount : amount
            let transaction = Transaction(
                amount: finalAmount,
                description: description,
                date: Date(),
                category: category,
                type: type,
                account: account
            )
            
            context.insert(transaction)
            try context.save()
            
            loadTransactions()
            
            errorManager.logInfo("Transação adicionada: \(description)", context: "TransactionViewModel.addTransaction")
        } catch {
            errorManager.handle(error, context: "TransactionViewModel.addTransaction")
            errorMessage = "Erro ao adicionar transação"
        }
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        guard let context = modelContext else {
            errorManager.logWarning("ModelContext não definido", context: "TransactionViewModel.deleteTransaction")
            return
        }
        
        do {
            context.delete(transaction)
            try context.save()
            
            loadTransactions()
            
            errorManager.logInfo("Transação deletada", context: "TransactionViewModel.deleteTransaction")
        } catch {
            errorManager.handle(error, context: "TransactionViewModel.deleteTransaction")
            errorMessage = "Erro ao deletar transação"
        }
    }
}

