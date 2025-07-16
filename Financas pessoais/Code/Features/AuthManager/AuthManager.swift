//
//  AuthManager.swift
//  Financas pessoais
//
//  Created by Roberto Edgar Geiss on 16/07/25.
//
import Foundation
import SwiftData

@MainActor
@Observable
final class AuthenticationManager {
    static let shared = AuthenticationManager()
    
    var currentUser: User?
    var isAuthenticated: Bool { currentUser != nil }
    var isLoading = false
    var errorMessage: String?
    
    private var modelContext: ModelContext?
    private let errorManager: ErrorManagerProtocol
    private let firebaseService: FirebaseServiceProtocol
    
    private init() {
        self.errorManager = ErrorManager.shared
        self.firebaseService = FirebaseService.shared
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadCurrentUser()
    }
    
    private func loadCurrentUser() {
        guard let context = modelContext else { return }
        
        // Simula carregar usuário logado (em produção, use KeyChain ou UserDefaults)
        let userEmail = UserDefaults.standard.string(forKey: "currentUserEmail")
        guard let email = userEmail else { return }
        
        do {
            let descriptor = FetchDescriptor<User>(
                predicate: #Predicate<User> { $0.email == email }
            )
            let users = try context.fetch(descriptor)
            currentUser = users.first
            
            if currentUser != nil {
                errorManager.logInfo("Usuário carregado: \(email)", context: "AuthenticationManager.loadCurrentUser")
            }
        } catch {
            errorManager.handle(error, context: "AuthenticationManager.loadCurrentUser")
        }
    }
    
    func signIn(email: String, password: String) async throws {
        guard let context = modelContext else {
            throw AppError.dataNotFound
        }
        
        isLoading = true
        errorMessage = nil
        
        // Analytics - tentativa de login
        firebaseService.logEvent(.signInAttempt)
        
        do {
            // Simula validação de senha (em produção, use hash/salt)
            let descriptor = FetchDescriptor<User>(
                predicate: #Predicate<User> { $0.email == email }
            )
            let users = try context.fetch(descriptor)
            
            guard let user = users.first else {
                firebaseService.logEvent(.signInFailure)
                throw AppError.userNotFound
            }
            
            // Simula verificação de senha (implemente hash apropriado)
            if password.count < 6 {
                firebaseService.logEvent(.signInFailure)
                throw AppError.invalidCredentials
            }
            
            currentUser = user
            UserDefaults.standard.set(email, forKey: "currentUserEmail")
            
            // Configura Firebase com dados do usuário
            firebaseService.setUserID(user.id.uuidString)
            firebaseService.setUserProperty(user.email, forName: "user_email")
            firebaseService.setUserProperty(user.name, forName: "user_name")
            
            // Analytics - login bem-sucedido
            firebaseService.logEvent(.signInSuccess)
            
            errorManager.logInfo("Login realizado: \(email)", context: "AuthenticationManager.signIn")
        } catch {
            errorManager.handle(error, context: "AuthenticationManager.signIn")
            errorMessage = error.localizedDescription
            throw error
        }
        
        isLoading = false
    }
    
    func signUp(name: String, email: String, password: String) async throws {
        guard let context = modelContext else {
            throw AppError.dataNotFound
        }
        
        isLoading = true
        errorMessage = nil
        
        // Analytics - tentativa de cadastro
        firebaseService.logEvent(.signUpAttempt)
        
        do {
            // Verifica se email já existe
            let descriptor = FetchDescriptor<User>(
                predicate: #Predicate<User> { $0.email == email }
            )
            let existingUsers = try context.fetch(descriptor)
            
            if !existingUsers.isEmpty {
                firebaseService.logEvent(.signUpFailure)
                throw AppError.emailAlreadyExists
            }
            
            // Cria novo usuário
            let newUser = User(email: email, name: name)
            context.insert(newUser)
            try context.save()
            
            currentUser = newUser
            UserDefaults.standard.set(email, forKey: "currentUserEmail")
            
            // Configura Firebase com dados do usuário
            firebaseService.setUserID(newUser.id.uuidString)
            firebaseService.setUserProperty(newUser.email, forName: "user_email")
            firebaseService.setUserProperty(newUser.name, forName: "user_name")
            
            // Analytics - cadastro bem-sucedido
            firebaseService.logEvent(.signUpSuccess)
            
            errorManager.logInfo("Usuário criado: \(email)", context: "AuthenticationManager.signUp")
        } catch {
            errorManager.handle(error, context: "AuthenticationManager.signUp")
            errorMessage = error.localizedDescription
            throw error
        }
        
        isLoading = false
    }
    
    func signOut() {
        // Analytics - logout
        firebaseService.logEvent(.signOut)
        
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: "currentUserEmail")
        
        // Remove dados do usuário do Firebase
        firebaseService.setUserID("")
        
        errorManager.logInfo("Logout realizado", context: "AuthenticationManager.signOut")
    }
    
    func updateProfile(name: String, profileImageData: Data?) async throws {
        guard let user = currentUser, let context = modelContext else {
            throw AppError.userNotFound
        }
        
        user.name = name
        if let imageData = profileImageData {
            user.profileImageData = imageData
            firebaseService.logEvent(.profilePhotoUpdated)
        }
        
        try context.save()
        
        // Atualiza propriedades do Firebase
        firebaseService.setUserProperty(name, forName: "user_name")
        firebaseService.logEvent(.profileEdited)
        
        errorManager.logInfo("Perfil atualizado", context: "AuthenticationManager.updateProfile")
    }
}

