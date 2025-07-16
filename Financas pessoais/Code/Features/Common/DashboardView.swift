//
//  DashboardView.swift
//  Financas pessoais
//
//  Created by Roberto Edgar Geiss on 16/07/25.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    
    private let authManager = AuthenticationManager.shared
    private let firebaseService = FirebaseService.shared
    
    @Query private var allAccounts: [Account]
    @Query(sort: \Transaction.date, order: .reverse) private var allTransactions: [Transaction]
    
    private var accounts: [Account] {
        guard let currentUser = authManager.currentUser else { return [] }
        return allAccounts.filter { $0.user?.id == currentUser.id }
    }
    
    private var recentTransactions: [Transaction] {
        guard let currentUser = authManager.currentUser else { return [] }
        return allTransactions
            .filter { $0.account?.user?.id == currentUser.id }
            .prefix(5)
            .map { $0 }
    }
    
    private var totalBalance: Decimal {
        accounts.reduce(0) { $0 + $1.balance }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Message
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Olá, \(authManager.currentUser?.name ?? "Usuário")!")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Bem-vindo de volta")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Profile Image
                        Group {
                            if let imageData = authManager.currentUser?.profileImageData,
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 35))
                                    .foregroundColor(.blue)
                            }
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                    }
                    .padding(.horizontal)
                    
                    // Balance Card
                    VStack {
                        Text("Saldo Total")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(totalBalance.formatted(.currency(code: "BRL")))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(totalBalance >= 0 ? .green : .red)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    
                    // Accounts Summary
                    VStack(alignment: .leading) {
                        Text("Contas")
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        ForEach(accounts.prefix(3), id: \.id) { account in
                            HStack {
                                Text(account.name)
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                Text(account.balance.formatted(.currency(code: "BRL")))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(account.balance >= 0 ? .green : .red)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    
                    // Recent Transactions
                    VStack(alignment: .leading) {
                        Text("Transações Recentes")
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        ForEach(recentTransactions, id: \.id) { transaction in
                            TransactionRowView(transaction: transaction)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .onAppear {
                firebaseService.logEvent(.dashboardViewed)
            }
        }
    }
}

