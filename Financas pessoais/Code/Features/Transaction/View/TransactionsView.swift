//
//  TransactionsView.swift
//  Financas pessoais
//
//  Created by Roberto Edgar Geiss on 16/07/25.
//

import SwiftUI
import SwiftData

struct TransactionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.date, order: .reverse) private var allTransactions: [Transaction]
    @State private var showingAddTransaction = false
    
    private let authManager = AuthenticationManager.shared
    private let firebaseService = FirebaseService.shared
    
    private var transactions: [Transaction] {
        guard let currentUser = authManager.currentUser else { return [] }
        return allTransactions.filter { $0.account?.user?.id == currentUser.id }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(transactions, id: \.id) { transaction in
                    TransactionRowView(transaction: transaction)
                }
                .onDelete(perform: deleteTransactions)
            }
            .navigationTitle("Transações")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Adicionar") {
                        showingAddTransaction = true
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView()
            }
            .onAppear {
                firebaseService.logEvent(.transactionsViewed)
            }
        }
    }
    
    private func deleteTransactions(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let transaction = transactions[index]
                
                // Analytics - transação deletada
                firebaseService.logEvent(.transactionDeleted(
                    type: transaction.type.rawValue,
                    category: transaction.category.rawValue
                ))
                
                modelContext.delete(transaction)
            }
            
            do {
                try modelContext.save()
            } catch {
                ErrorManager.shared.handle(error, context: "TransactionsView.deleteTransactions")
            }
        }
    }
}

