//
//  estrutra.swift
//  Financas pessoais
//
//  Created by Roberto Edgar Geiss on 12/07/25.
//

import Foundation
# 📁 Estrutura do Projeto - Personal Finance App

```
PersonalFinanceApp/
├── 📄 Package.swift                           # Configuração SPM com dependências
├── 📄 .swiftlint.yml                         # Regras do SwiftLint
├── 📄 GoogleService-Info.plist               # Configuração Firebase (adicionar)
├── 📄 Info.plist                             # Configurações do app iOS
│
├── 📁 Sources/
│   ├── 📁 Models/                            # Modelos SwiftData
│   │   ├── 📄 User.swift                     # Modelo de usuário
│   │   ├── 📄 Account.swift                  # Modelo de conta bancária
│   │   ├── 📄 Transaction.swift              # Modelo de transação
│   │   ├── 📄 Budget.swift                   # Modelo de orçamento
│   │   └── 📄 Enums.swift                    # Enums (TransactionType, etc.)
│   │
│   ├── 📁 Core/                              # Serviços centrais
│   │   ├── 📄 ErrorManager.swift             # Gerenciamento de erros
│   │   ├── 📄 AppError.swift                 # Tipos de erro customizados
│   │   ├── 📄 FirebaseService.swift          # Serviço Firebase
│   │   ├── 📄 AnalyticsEvent.swift           # Eventos de analytics
│   │   ├── 📄 ThemeManager.swift             # Gerenciamento de temas
│   │   └── 📄 AuthenticationManager.swift    # Gerenciamento de auth
│   │
│   ├── 📁 Services/                          # Serviços de dados
│   │   └── 📄 DataService.swift              # Serviço principal de dados
│   │
│   ├── 📁 ViewModels/                        # ViewModels observáveis
│   │   ├── 📄 TransactionViewModel.swift     # ViewModel de transações
│   │   └── 📄 AccountViewModel.swift         # ViewModel de contas
│   │
│   ├── 📁 Views/                             # Views SwiftUI
│   │   ├── 📁 Authentication/                # Telas de autenticação
│   │   │   ├── 📄 AuthenticationView.swift   # Tela principal de auth
│   │   │   ├── 📄 SignInView.swift           # Tela de login
│   │   │   └── 📄 SignUpView.swift           # Tela de cadastro
│   │   │
│   │   ├── 📁 Dashboard/                     # Dashboard principal
│   │   │   └── 📄 DashboardView.swift        # Tela inicial com resumo
│   │   │
│   │   ├── 📁 Transactions/                  # Gestão de transações
│   │   │   ├── 📄 TransactionsView.swift     # Lista de transações
│   │   │   ├── 📄 TransactionRowView.swift   # Row component
│   │   │   └── 📄 AddTransactionView.swift   # Adicionar transação
│   │   │
│   │   ├── 📁 Accounts/                      # Gestão de contas
│   │   │   ├── 📄 AccountsView.swift         # Lista de contas
│   │   │   └── 📄 AccountRowView.swift       # Row component
│   │   │
│   │   ├── 📁 Budget/                        # Orçamentos
│   │   │   ├── 📄 BudgetView.swift           # Lista de orçamentos
│   │   │   └── 📄 BudgetRowView.swift        # Row component
│   │   │
│   │   ├── 📁 Profile/                       # Perfil do usuário
│   │   │   ├── 📄 ProfileView.swift          # Tela de perfil
│   │   │   ├── 📄 EditProfileView.swift      # Editar perfil
│   │   │   └── 📄 ImagePicker.swift          # Seletor de imagem
│   │   │
│   │   ├── 📁 Settings/                      # Configurações
│   │   │   └── 📄 SettingsView.swift         # Tela de configurações
│   │   │
│   │   ├── 📄 ContentView.swift              # View principal (auth gate)
│   │   └── 📄 MainTabView.swift              # TabView principal
│   │
│   ├── 📁 Extensions/                        # Extensões úteis
│   │   ├── 📄 Decimal+Extensions.swift       # Extensões para Decimal
│   │   └── 📄 Date+Extensions.swift          # Extensões para Date
│   │
│   └── 📄 PersonalFinanceApp.swift           # Entry point da aplicação
│
├── 📁 Resources/                             # Recursos do app
│   ├── 📄 Assets.xcassets                    # Imagens e cores
│   ├── 📄 LaunchScreen.storyboard            # Tela de launch
│   └── 📄 Localizable.strings                # Strings localizadas
│
├── 📁 Tests/                                 # Testes unitários
│   ├── 📄 PersonalFinanceAppTests.swift      # Testes principais
│   ├── 📄 ModelTests.swift                   # Testes de modelos
│   ├── 📄 ViewModelTests.swift               # Testes de ViewModels
│   └── 📄 ServiceTests.swift                 # Testes de serviços
│
├── 📁 UITests/                               # Testes de interface
│   └── 📄 PersonalFinanceAppUITests.swift    # Testes de UI
│
└── 📁 Documentation/                         # Documentação
    ├── 📄 README.md                          # Documentação principal
    ├── 📄 ARCHITECTURE.md                    # Arquitetura do projeto
    ├── 📄 FIREBASE_SETUP.md                  # Setup do Firebase
    └── 📄 API_DOCUMENTATION.md               # Documentação da API
```

## 📊 **Estatísticas do Projeto**

| Categoria | Arquivos | Descrição |
|-----------|----------|-----------|
| **Models** | 5 | SwiftData models com relacionamentos |
| **Core Services** | 6 | Gerenciamento central (auth, errors, Firebase) |
| **Views** | 16 | Interface SwiftUI organizada por features |
| **ViewModels** | 2 | Lógica de apresentação observável |
| **Extensions** | 2 | Extensões úteis para tipos base |
| **Tests** | 4 | Cobertura de testes unitários e UI |
| **Config** | 3 | Configuração e setup do projeto |

## 🏗️ **Arquitetura por Camadas**

```
┌─────────────────────────────────────┐
│             Views (SwiftUI)          │ ← Interface do usuário
├─────────────────────────────────────┤
│           ViewModels (@Observable)   │ ← Lógica de apresentação
├─────────────────────────────────────┤
│         Services & Managers         │ ← Lógica de negócio
├─────────────────────────────────────┤
│          Models (SwiftData)         │ ← Modelos de dados
├─────────────────────────────────────┤
│      External Services (Firebase)   │ ← Serviços externos
└─────────────────────────────────────┘
```

## 🔥 **Recursos Implementados por Feature**

### 🔐 **Autenticação**
- [x] Login/Logout
- [x] Cadastro de usuários
- [x] Persistência de sessão
- [x] Validação de dados

### 💰 **Gestão Financeira**
- [x] Múltiplas contas
- [x] Transações categorizadas
- [x] Orçamentos mensais
- [x] Dashboard com resumos

### 👤 **Perfil de Usuário**
- [x] Edição de dados pessoais
- [x] Upload de foto de perfil
- [x] Configurações personalizadas

### 🎨 **Interface**
- [x] Tema claro/escuro/automático
- [x] Design responsivo
- [x] Navegação intuitiva
- [x] Componentes reutilizáveis

### 📊 **Analytics & Monitoring**
- [x] Firebase Analytics
- [x] Firebase Crashlytics
- [x] Logging estruturado
- [x] Métricas de uso

### 🛠️ **Qualidade de Código**
- [x] SwiftLint configurado
- [x] Tratamento de erros robusto
- [x] Arquitetura MVVM
- [x] Testes unitários preparados

## 🚀 **Como Executar**

1. **Clone e configure:**
   ```bash
   git clone <repository>
   cd PersonalFinanceApp
   ```

2. **Adicione Firebase:**
   - Baixe `GoogleService-Info.plist` do console Firebase
   - Adicione ao projeto no Xcode

3. **Execute:**
   ```bash
   open PersonalFinanceApp.xcworkspace
   ```

4. **Credenciais de teste:**
   - Email: `demo@exemplo.com`
   - Senha: `123456`

Esta estrutura fornece uma base sólida e escalável para um app de finanças pessoais completo! 🎯


