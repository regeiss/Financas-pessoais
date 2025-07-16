//
//  SignUpView.swift
//  Financas pessoais
//
//  Created by Roberto Edgar Geiss on 16/07/25.
//

import SwiftUI

struct SignUpView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private let authManager = AuthenticationManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            TextField("Nome completo", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.name)
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            SecureField("Senha", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.newPassword)
            
            SecureField("Confirmar senha", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.newPassword)
            
            Button(action: signUp) {
                if authManager.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Cadastrar")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(!isFormValid || authManager.isLoading)
        }
        .alert("Erro", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 6
    }
    
    private func signUp() {
        Task {
            do {
                try await authManager.signUp(name: name, email: email, password: password)
            } catch {
                alertMessage = error.localizedDescription
                showingAlert = true
            }
        }
    }
}
