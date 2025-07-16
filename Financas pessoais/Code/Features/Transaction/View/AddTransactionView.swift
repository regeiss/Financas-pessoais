//
//  AddTransactionView.swift
//  Financas pessoais
//
//  Created by Roberto Edgar Geiss on 16/07/25.
//

import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allAccounts: [Account]
    
    @State private var amount = ""
    @State private var description = ""
    @State private var selectedCategory = TransactionCategory.other
    @State private var selectedType = TransactionType.expense
    @State private var selectedAccount: Account?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private let authManager = AuthenticationManager.shared
    private let firebaseService = FirebaseService.shared
    
    private var accounts: [Account] {
        guard let currentUser = authManager.currentUser else { return [] }
        return allAccounts.filter { $0.user?.id == currentUser.id }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Detalhes da Transação") {
                    TextField("Valor", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    TextField("Descrição", text: $description)
                    
                    Picker("Tipo", selection: $selectedType) {
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Picker("Categoria", selection: $selectedCategory) {
                        ForEach(TransactionCategory.allCases, id: \.self) { category in
                            Label(category.displayName, systemImage: category.iconName)
                                .tag(category)
                        }
                    }
                    
                    Picker("Conta", selection: $selectedAccount) {
                        Text("Selecione uma conta").tag(nil as Account?)
                        ForEach(accounts, id: \.id) { account in
                            Text(account.name).tag(account as Account?)
                        }
                    }
                }
            }
            .navigationTitle("Nova Transação")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salvar") {
                        saveTransaction()
                    }
                    .disabled(amount.isEmpty || description.isEmpty)
                }
            }
            .alert("Erro", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func saveTransaction() {
        guard let amountValue = Decimal(string: amount), amountValue > 0 else {
            showAlert("Valor inválido")
            return
        }
        
        guard !description.isEmpty else {
            showAlert("Descrição é obrigatória")
            return
        }
        
        let finalAmount = selectedType == .expense ? -amountValue : amountValue
        
        let transaction = Transaction(
            amount: finalAmount,
            description: description,
            date: Date(),
            category: selectedCategory,
            type: selectedType,
            account: selectedAccount
        )
        
        modelContext.insert(transaction)
        
        do {
            try modelContext.save()
            
            // Analytics - transação criada
            firebaseService.logEvent(AnalyticsEvent.transactionCreated(
                type: selectedType.rawValue,
                category: selectedCategory.rawValue,
                amount: abs(finalAmount.doubleValue)
            ))
            
            dismiss()
        } catch {
            ErrorManager.shared.handle(error, context: "AddTransactionView.saveTransaction")
            showAlert("Erro ao salvar transação")
        }
    }
    
    private func showAlert(_ message: String) {
        alertMessage = message
        showingAlert = true
    }
}

