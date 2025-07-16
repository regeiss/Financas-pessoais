//
//  SignInView.swift
//  Financas pessoais
//
//  Created by Roberto Edgar Geiss on 16/07/25.
//

import SwiftUI

struct SignInView: View {
    @State private var email = "demo@exemplo.com"
    @State private var password = "123456"
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private let authManager = AuthenticationManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            SecureField("Senha", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.password)
            
            Button(action: signIn) {
                if authManager.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Entrar")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(email.isEmpty || password.isEmpty || authManager.isLoading)
        }
        .alert("Erro", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func signIn() {
        Task {
            do {
                try await authManager.signIn(email: email, password: password)
            } catch {
                alertMessage = error.localizedDescription
                showingAlert = true
            }
        }
    }
}
