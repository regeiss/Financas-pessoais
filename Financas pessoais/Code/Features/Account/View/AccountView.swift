//
//  AccountView.swift
//  Financas pessoais
//
//  Created by Roberto Edgar Geiss on 13/07/25.
//

import SwiftUI
import SwiftData

struct AccountsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allAccounts: [Account]
    
    private let authManager = AuthenticationManager.shared
    private let firebaseService = FirebaseService.shared
    
    private var accounts: [Account] {
        guard let currentUser = authManager.currentUser else { return [] }
        return allAccounts.filter { $0.user?.id == currentUser.id }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(accounts, id: \.id) { account in
                    AccountRowView(account: account)
                }
            }
            .navigationTitle("Contas")
            .onAppear {
                firebaseService.logEvent(.accountsViewed)
            }
        }
    }
}

// Sources/Views/AccountRowView.swift
struct AccountRowView: View {
    let account: Account
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(account.name)
                    .font(.headline)
                
                Text(account.accountType.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(account.balance.formatted(.currency(code: "BRL")))
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(account.balance >= 0 ? .green : .red)
        }
        .padding(.vertical, 4)
    }
}

