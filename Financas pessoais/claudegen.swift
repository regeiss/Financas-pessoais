// MARK: - Package.swift
// Package.swift
import PackageDescription

let package = Package(
    name: "PersonalFinanceApp",
    platforms: [
        .iOS(.v17)
    ],
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint", from: "0.54.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.20.0")
    ],
    targets: [
        .target(
            name: "PersonalFinanceApp",
            dependencies: [
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCore", package: "firebase-ios-sdk")
            ],
            plugins: [
                .plugin(name: "SwiftLintPlugin", package: "SwiftLint")
            ]
        )
    ]
)




// Sources/Views/ProfileView.swift


// Sources/Views/EditProfileView.swift

// Sources/Views/SettingsView.swift


// Sources/Views/ImagePicker.swift
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
  @Binding var selectedImage: UIImage?
  @Environment(\.dismiss) private var dismiss
  
  func makeUIViewController(context: Context) -> PHPickerViewController {
    var configuration = PHPickerConfiguration()
    configuration.filter = .images
    configuration.selectionLimit = 1
    
    let picker = PHPickerViewController(configuration: configuration)
    picker.delegate = context.coordinator
    return picker
  }
  
  func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, PHPickerViewControllerDelegate {
    let parent: ImagePicker
    
    init(_ parent: ImagePicker) {
      self.parent = parent
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
      parent.dismiss()
      
      guard let provider = results.first?.itemProvider else { return }
      
      if provider.canLoadObject(ofClass: UIImage.self) {
        provider.loadObject(ofClass: UIImage.self) { image, _ in
          DispatchQueue.main.async {
            self.parent.selectedImage = image as? UIImage
          }
        }
      }
    }
  }
}

// Sources/Models/Account.swift


// Sources/Models/Budget.swift


// Sources/Models/User.swift

// Sources/Models/Enums.swift


// MARK: - Error Management
// Sources/Core/FirebaseService.swift


// Sources/Core/AnalyticsEvent.swift


// Sources/Core/ErrorManager.swift
// Sources/Core/AppError.swift
// Sources/Core/ThemeManager.swift
import SwiftUI

enum AppTheme: String, CaseIterable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    var displayName: String {
        switch self {
        case .light: return "Claro"
        case .dark: return "Escuro"
        case .system: return "Sistema"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

@MainActor
@Observable
final class ThemeManager {
    static let shared = ThemeManager()
    
    private let userDefaults = UserDefaults.standard
    private let themeKey = "selectedTheme"
    private let firebaseService: FirebaseServiceProtocol
    
    var currentTheme: AppTheme {
        didSet {
            userDefaults.set(currentTheme.rawValue, forKey: themeKey)
            ErrorManager.shared.logInfo("Tema alterado para: \(currentTheme.displayName)", context: "ThemeManager")
            
            // Analytics event
            firebaseService.logEvent(.themeChanged(theme: currentTheme.rawValue))
        }
    }
    
    private init() {
        self.firebaseService = FirebaseService.shared
        let savedTheme = userDefaults.string(forKey: themeKey) ?? AppTheme.system.rawValue
        self.currentTheme = AppTheme(rawValue: savedTheme) ?? .system
    }
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
    }
}

// Sources/Core/AuthenticationManager.swift
import SwiftData
import Foundation

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

// MARK: - Data Service
// Sources/Services/DataService.swift
import SwiftData
import Foundation

@MainActor
final class DataService: ObservableObject {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    private let errorManager: ErrorManagerProtocol
    
    init() throws {
        self.errorManager = ErrorManager.shared
        
        let schema = Schema([
            Transaction.self,
            Account.self,
            Budget.self,
            User.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            self.modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            self.modelContext = modelContainer.mainContext
            
            errorManager.logInfo("DataService inicializado com sucesso", context: "DataService.init")
        } catch {
            errorManager.handle(error, context: "DataService.init")
            throw error
        }
    }
    
    func getModelContainer() -> ModelContainer {
        return modelContainer
    }
    
    func saveContext() throws {
        do {
            try modelContext.save()
            errorManager.logInfo("Contexto salvo com sucesso", context: "DataService.saveContext")
        } catch {
            errorManager.handle(error, context: "DataService.saveContext")
            throw error
        }
    }
    
    func generateSampleData() async throws {
        guard try await !hasExistingData() else {
            errorManager.logInfo("Dados já existem, pulando geração", context: "DataService.generateSampleData")
            return
        }
        
        do {
            let sampleUser = try await createSampleUser()
            try await createSampleAccounts(for: sampleUser)
            try await createSampleTransactions()
            try await createSampleBudgets(for: sampleUser)
            
            try saveContext()
            
            errorManager.logInfo("Dados de exemplo gerados com sucesso", context: "DataService.generateSampleData")
        } catch {
            errorManager.handle(error, context: "DataService.generateSampleData")
            throw error
        }
    }
    
    private func hasExistingData() async throws -> Bool {
        let descriptor = FetchDescriptor<User>()
        let users = try modelContext.fetch(descriptor)
        return !users.isEmpty
    }
    
    private func createSampleUser() async throws -> User {
        let user = User(
            email: "demo@exemplo.com",
            name: "Usuário Demo",
            preferredCurrency: "BRL"
        )
        
        modelContext.insert(user)
        return user
    }
    
    private func createSampleAccounts(for user: User) async throws {
        let accounts = [
            Account(name: "Conta Corrente Principal", balance: 2500.00, accountType: .checking, user: user),
            Account(name: "Poupança", balance: 15000.00, accountType: .savings, user: user),
            Account(name: "Cartão de Crédito", balance: -800.00, accountType: .credit, user: user),
            Account(name: "Investimentos", balance: 25000.00, accountType: .investment, user: user)
        ]
        
        for account in accounts {
            modelContext.insert(account)
        }
    }
    
    private func createSampleTransactions() async throws {
        let accountDescriptor = FetchDescriptor<Account>()
        let accounts = try modelContext.fetch(accountDescriptor)
        
        guard let checkingAccount = accounts.first(where: { $0.accountType == .checking }),
              let creditAccount = accounts.first(where: { $0.accountType == .credit }) else {
            throw AppError.accountNotFound
        }
        
        let transactions = [
            Transaction(
                amount: 5000.00,
                description: "Salário",
                date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
                category: .salary,
                type: .income,
                account: checkingAccount
            ),
            Transaction(
                amount: -120.50,
                description: "Supermercado",
                date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
                category: .food,
                type: .expense,
                account: checkingAccount
            ),
            Transaction(
                amount: -45.00,
                description: "Uber",
                date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                category: .transport,
                type: .expense,
                account: creditAccount
            ),
            Transaction(
                amount: -80.00,
                description: "Cinema",
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                category: .entertainment,
                type: .expense,
                account: creditAccount
            )
        ]
        
        for transaction in transactions {
            modelContext.insert(transaction)
        }
    }
    
    private func createSampleBudgets(for user: User) async throws {
        let currentDate = Date()
        let calendar = Calendar.current
        let month = calendar.component(.month, from: currentDate)
        let year = calendar.component(.year, from: currentDate)
        
        let budgets = [
            Budget(category: .food, limit: 800.00, spent: 120.50, month: month, year: year, user: user),
            Budget(category: .transport, limit: 300.00, spent: 45.00, month: month, year: year, user: user),
            Budget(category: .entertainment, limit: 200.00, spent: 80.00, month: month, year: year, user: user),
            Budget(category: .shopping, limit: 400.00, spent: 0.00, month: month, year: year, user: user)
        ]
        
        for budget in budgets {
            modelContext.insert(budget)
        }
    }
}

// MARK: - ViewModels
// Sources/ViewModels/TransactionViewModel.swift
import SwiftData
import Foundation

@MainActor
@Observable
final class TransactionViewModel {
    private let errorManager: ErrorManagerProtocol
    private var modelContext: ModelContext?
    
    var transactions: [Transaction] = []
    var isLoading = false
    var errorMessage: String?
    
    init(errorManager: ErrorManagerProtocol = ErrorManager.shared) {
        self.errorManager = errorManager
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadTransactions()
    }
    
    func loadTransactions() {
        guard let context = modelContext else {
            errorManager.logWarning("ModelContext não definido", context: "TransactionViewModel.loadTransactions")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let descriptor = FetchDescriptor<Transaction>(
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            transactions = try context.fetch(descriptor)
            
            errorManager.logInfo("Transações carregadas: \(transactions.count)", context: "TransactionViewModel.loadTransactions")
        } catch {
            errorManager.handle(error, context: "TransactionViewModel.loadTransactions")
            errorMessage = "Erro ao carregar transações"
        }
        
        isLoading = false
    }
    
    func addTransaction(
        amount: Decimal,
        description: String,
        category: TransactionCategory,
        type: TransactionType,
        account: Account?
    ) {
        guard let context = modelContext else {
            errorManager.logWarning("ModelContext não definido", context: "TransactionViewModel.addTransaction")
            return
        }
        
        guard amount > 0 else {
            errorMessage = "Valor deve ser maior que zero"
            return
        }
        
        do {
            let finalAmount = type == .expense ? -amount : amount
            let transaction = Transaction(
                amount: finalAmount,
                description: description,
                date: Date(),
                category: category,
                type: type,
                account: account
            )
            
            context.insert(transaction)
            try context.save()
            
            loadTransactions()
            
            errorManager.logInfo("Transação adicionada: \(description)", context: "TransactionViewModel.addTransaction")
        } catch {
            errorManager.handle(error, context: "TransactionViewModel.addTransaction")
            errorMessage = "Erro ao adicionar transação"
        }
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        guard let context = modelContext else {
            errorManager.logWarning("ModelContext não definido", context: "TransactionViewModel.deleteTransaction")
            return
        }
        
        do {
            context.delete(transaction)
            try context.save()
            
            loadTransactions()
            
            errorManager.logInfo("Transação deletada", context: "TransactionViewModel.deleteTransaction")
        } catch {
            errorManager.handle(error, context: "TransactionViewModel.deleteTransaction")
            errorMessage = "Erro ao deletar transação"
        }
    }
}

// Sources/ViewModels/AccountViewModel.swift
@MainActor
@Observable
final class AccountViewModel {
    private let errorManager: ErrorManagerProtocol
    private var modelContext: ModelContext?
    
    var accounts: [Account] = []
    var isLoading = false
    var errorMessage: String?
    
    init(errorManager: ErrorManagerProtocol = ErrorManager.shared) {
        self.errorManager = errorManager
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadAccounts()
    }
    
    func loadAccounts() {
        guard let context = modelContext else {
            errorManager.logWarning("ModelContext não definido", context: "AccountViewModel.loadAccounts")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let descriptor = FetchDescriptor<Account>(
                predicate: #Predicate<Account> { $0.isActive },
                sortBy: [SortDescriptor(\.name)]
            )
            accounts = try context.fetch(descriptor)
            
            errorManager.logInfo("Contas carregadas: \(accounts.count)", context: "AccountViewModel.loadAccounts")
        } catch {
            errorManager.handle(error, context: "AccountViewModel.loadAccounts")
            errorMessage = "Erro ao carregar contas"
        }
        
        isLoading = false
    }
    
    var totalBalance: Decimal {
        accounts.reduce(0) { $0 + $1.balance }
    }
}

// MARK: - Views
// Sources/Views/AuthenticationView.swift
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

// Sources/Views/SignInView.swift
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

// Sources/Views/SignUpView.swift
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

// Sources/Views/ContentView.swift
import SwiftUI
import SwiftData

struct ContentView: View {
    private let authManager = AuthenticationManager.shared
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainTabView()
            } else {
                AuthenticationView()
            }
        }
        .preferredColorScheme(themeManager.currentTheme.colorScheme)
    }
}

// Sources/Views/MainTabView.swift
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

// Sources/Views/DashboardView.swift
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

// Sources/Views/TransactionsView.swift
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

// Sources/Views/TransactionRowView.swift
struct TransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            Image(systemName: transaction.category.iconName)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading) {
                Text(transaction.transactionDescription)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(transaction.category.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(transaction.amount.formatted(.currency(code: "BRL")))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(transaction.amount >= 0 ? .green : .red)
                
                Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

// Sources/Views/AddTransactionView.swift
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
            firebaseService.logEvent(.transactionCreated(
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

// Sources/Views/AccountsView.swift

// Sources/Views/BudgetView.swift

// MARK: - App Entry Point
// Sources/PersonalFinanceApp.swift

// MARK: - Configuration Files
/*
 Para usar o Firebase no seu projeto, você precisa:
 
 1. Criar um projeto no Firebase Console (https://console.firebase.google.com)
 2. Adicionar um app iOS ao projeto
 3. Baixar o arquivo GoogleService-Info.plist
 4. Adicionar o arquivo GoogleService-Info.plist ao bundle do seu app no Xcode
 5. Configurar o Firebase Crashlytics no console
 6. Configurar o Firebase Analytics no console
 
 Exemplo de GoogleService-Info.plist:
 ```xml
 <?xml version="1.0" encoding="UTF-8"?>
 <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
 <plist version="1.0">
 <dict>
     <key>CLIENT_ID</key>
     <string>SEU_CLIENT_ID_AQUI</string>
     <key>REVERSED_CLIENT_ID</key>
     <string>SEU_REVERSED_CLIENT_ID_AQUI</string>
     <key>API_KEY</key>
     <string>SUA_API_KEY_AQUI</string>
     <key>GCM_SENDER_ID</key>
     <string>SEU_GCM_SENDER_ID_AQUI</string>
     <key>PLIST_VERSION</key>
     <string>1</string>
     <key>BUNDLE_ID</key>
     <string>com.seudominio.personalfinanceapp</string>
     <key>PROJECT_ID</key>
     <string>seu-projeto-firebase</string>
     <key>STORAGE_BUCKET</key>
     <string>seu-projeto-firebase.appspot.com</string>
     <key>IS_ADS_ENABLED</key>
     <false/>
     <key>IS_ANALYTICS_ENABLED</key>
     <true/>
     <key>IS_APPINVITE_ENABLED</key>
     <true/>
     <key>IS_GCM_ENABLED</key>
     <true/>
     <key>IS_SIGNIN_ENABLED</key>
     <true/>
     <key>GOOGLE_APP_ID</key>
     <string>SEU_GOOGLE_APP_ID_AQUI</string>
 </dict>
 </plist>
 ```
 
 Para configurar o Crashlytics no Xcode:
 1. Vá em Project Settings → Build Phases
 2. Adicione um novo "Run Script Phase"
 3. Cole este script:
 ```
 "${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run"
 ```
 4. Adicione este Input File:
 ```
 ${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${TARGET_NAME}
 ${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}
 ```
 */

// MARK: - Extensions
// Sources/Extensions/Decimal+Extensions.swift
import Foundation

extension Decimal {
    var doubleValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }
}

// Sources/Extensions/Date+Extensions.swift
extension Date {
    func startOfMonth() -> Date {
        Calendar.current.dateInterval(of: .month, for: self)?.start ?? self
    }
    
    func endOfMonth() -> Date {
        Calendar.current.dateInterval(of: .month, for: self)?.end ?? self
    }
}
*/
