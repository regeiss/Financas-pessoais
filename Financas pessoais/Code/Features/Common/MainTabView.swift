//
//  MainTabView.swift
//  Financas pessoais
//
//  Created by Roberto Edgar Geiss on 16/07/25.
//

import SwiftUI
import SwiftData 

struct MainTabView: View {
    var body: some View {
        TabView {
          DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Início")
                }
            
            TransactionsView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Transações")
                }
            
            AccountsView()
                .tabItem {
                    Image(systemName: "creditcard.fill")
                    Text("Contas")
                }
            
            BudgetView()
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Orçamento")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Perfil")
                }
        }
        .accentColor(.blue)
    }
}

