//
//  AuthenticationView.swift
//  Financas pessoais
//
//  Created by Roberto Edgar Geiss on 16/07/25.
//

import SwiftUI

struct AuthenticationView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var isSignUp = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Logo/Header
                VStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("Finanças Pessoais")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Gerencie suas finanças de forma inteligente")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Forms
                if isSignUp {
                    SignUpView()
                } else {
                    SignInView()
                }
                
                Spacer()
                
                // Toggle between Sign In / Sign Up
                Button(action: {
                    withAnimation(.easeInOut) {
                        isSignUp.toggle()
                    }
                }) {
                    Text(isSignUp ? "Já tem uma conta? Entrar" : "Não tem conta? Cadastrar")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal)
        }
        .onAppear {
            AuthenticationManager.shared.setModelContext(modelContext)
        }
    }
}
