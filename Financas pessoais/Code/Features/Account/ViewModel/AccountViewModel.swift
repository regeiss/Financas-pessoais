//
//  AccountViewModel.swift
//  Financas pessoais
//
//  Created by Roberto Edgar Geiss on 16/07/25.
//
import Foundation
import SwiftData

@MainActor
@Observable
final class AccountViewModel {
    private let errorManager: ErrorManagerProtocol
    private var modelContext: ModelContext?
    
    var accounts: [Account] = []
    var isLoading = false
    var errorMessage: String?
    
    init(errorManager: ErrorManagerProtocol = ErrorManager.shared) {
        self.errorManager = errorManager
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadAccounts()
    }
    
    func loadAccounts() {
        guard let context = modelContext else {
            errorManager.logWarning("ModelContext não definido", context: "AccountViewModel.loadAccounts")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let descriptor = FetchDescriptor<Account>(
                predicate: #Predicate<Account> { $0.isActive },
                sortBy: [SortDescriptor(\.name)]
            )
            accounts = try context.fetch(descriptor)
            
            errorManager.logInfo("Contas carregadas: \(accounts.count)", context: "AccountViewModel.loadAccounts")
        } catch {
            errorManager.handle(error, context: "AccountViewModel.loadAccounts")
            errorMessage = "Erro ao carregar contas"
        }
        
        isLoading = false
    }
    
    var totalBalance: Decimal {
        accounts.reduce(0) { $0 + $1.balance }
    }
}

