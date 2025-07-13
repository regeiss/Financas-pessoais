//
//  BudgetView.swift
//  Financas pessoais
//
//  Created by Roberto Edgar Geiss on 13/07/25.
//

import SwiftUI

struct BudgetView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allBudgets: [Budget]
    
    private let authManager = AuthenticationManager.shared
    private let firebaseService = FirebaseService.shared
    
    private var budgets: [Budget] {
        guard let currentUser = authManager.currentUser else { return [] }
        return allBudgets.filter { $0.user?.id == currentUser.id }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(budgets, id: \.id) { budget in
                    BudgetRowView(budget: budget)
                }
            }
            .navigationTitle("Orçamentos")
            .onAppear {
                firebaseService.logEvent(.budgetViewed)
            }
        }
    }
}

// Sources/Views/BudgetRowView.swift
struct BudgetRowView: View {
    let budget: Budget
    
    private var progressPercentage: Double {
        guard budget.limit > 0 else { return 0 }
        return min(Double(budget.spent / budget.limit), 1.0)
    }
    
    private var remainingAmount: Decimal {
        budget.limit - budget.spent
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(budget.category.displayName, systemImage: budget.category.iconName)
                    .font(.headline)
                
                Spacer()
                
                Text(budget.limit.formatted(.currency(code: "BRL")))
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            ProgressView(value: progressPercentage)
                .progressViewStyle(LinearProgressViewStyle(tint: progressPercentage > 0.8 ? .red : .blue))
            
            HStack {
                Text("Gasto: \(budget.spent.formatted(.currency(code: "BRL")))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Restante: \(remainingAmount.formatted(.currency(code: "BRL")))")
                    .font(.caption)
                    .foregroundColor(remainingAmount >= 0 ? .green : .red)
            }
        }
        .padding(.vertical, 4)
    }
}
