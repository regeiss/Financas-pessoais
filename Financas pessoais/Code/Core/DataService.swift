//
//  DataService.swift
//  Financas pessoais
//
//  Created by Roberto Edgar Geiss on 16/07/25.
//

import SwiftData
import Foundation

@MainActor
final class DataService {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    private let errorManager: ErrorManagerProtocol
    
    init() throws {
        self.errorManager = ErrorManager.shared
        
        let schema = Schema([
            Transaction.self,
            Account.self,
            Budget.self,
            User.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            self.modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            self.modelContext = modelContainer.mainContext
            
            errorManager.logInfo("DataService inicializado com sucesso", context: "DataService.init")
        } catch {
            errorManager.handle(error, context: "DataService.init")
            throw error
        }
    }
    
    func getModelContainer() -> ModelContainer {
        return modelContainer
    }
    
    func saveContext() throws {
        do {
            try modelContext.save()
            errorManager.logInfo("Contexto salvo com sucesso", context: "DataService.saveContext")
        } catch {
            errorManager.handle(error, context: "DataService.saveContext")
            throw error
        }
    }
    
    func generateSampleData() async throws {
        guard try await !hasExistingData() else {
            errorManager.logInfo("Dados já existem, pulando geração", context: "DataService.generateSampleData")
            return
        }
        
        do {
            let sampleUser = try await createSampleUser()
            try await createSampleAccounts(for: sampleUser)
            try await createSampleTransactions()
            try await createSampleBudgets(for: sampleUser)
            
            try saveContext()
            
            errorManager.logInfo("Dados de exemplo gerados com sucesso", context: "DataService.generateSampleData")
        } catch {
            errorManager.handle(error, context: "DataService.generateSampleData")
            throw error
        }
    }
    
    private func hasExistingData() async throws -> Bool {
        let descriptor = FetchDescriptor<User>()
        let users = try modelContext.fetch(descriptor)
        return !users.isEmpty
    }
    
    private func createSampleUser() async throws -> User {
        let user = User(
            email: "demo@exemplo.com",
            name: "Usuário Demo",
            preferredCurrency: "BRL"
        )
        
        modelContext.insert(user)
        return user
    }
    
    private func createSampleAccounts(for user: User) async throws {
        let accounts = [
            Account(name: "Conta Corrente Principal", balance: 2500.00, accountType: .checking, user: user),
            Account(name: "Poupança", balance: 15000.00, accountType: .savings, user: user),
            Account(name: "Cartão de Crédito", balance: -800.00, accountType: .credit, user: user),
            Account(name: "Investimentos", balance: 25000.00, accountType: .investment, user: user)
        ]
        
        for account in accounts {
            modelContext.insert(account)
        }
    }
    
    private func createSampleTransactions() async throws {
        let accountDescriptor = FetchDescriptor<Account>()
        let accounts = try modelContext.fetch(accountDescriptor)
        
        guard let checkingAccount = accounts.first(where: { $0.accountType == .checking }),
              let creditAccount = accounts.first(where: { $0.accountType == .credit }) else {
            throw AppError.accountNotFound
        }
        
        let transactions = [
            Transaction(
                amount: 5000.00,
                description: "Salário",
                date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
                category: .salary,
                type: .income,
                account: checkingAccount
            ),
            Transaction(
                amount: -120.50,
                description: "Supermercado",
                date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
                category: .food,
                type: .expense,
                account: checkingAccount
            ),
            Transaction(
                amount: -45.00,
                description: "Uber",
                date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                category: .transport,
                type: .expense,
                account: creditAccount
            ),
            Transaction(
                amount: -80.00,
                description: "Cinema",
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                category: .entertainment,
                type: .expense,
                account: creditAccount
            )
        ]
        
        for transaction in transactions {
            modelContext.insert(transaction)
        }
    }
    
    private func createSampleBudgets(for user: User) async throws {
        let currentDate = Date()
        let calendar = Calendar.current
        let month = calendar.component(.month, from: currentDate)
        let year = calendar.component(.year, from: currentDate)
        
        let budgets = [
            Budget(category: .food, limit: 800.00, spent: 120.50, month: month, year: year, user: user),
            Budget(category: .transport, limit: 300.00, spent: 45.00, month: month, year: year, user: user),
            Budget(category: .entertainment, limit: 200.00, spent: 80.00, month: month, year: year, user: user),
            Budget(category: .shopping, limit: 400.00, spent: 0.00, month: month, year: year, user: user)
        ]
        
        for budget in budgets {
            modelContext.insert(budget)
        }
    }
}

