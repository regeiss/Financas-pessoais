// MARK: - Package.swift
// Package.swift
//import PackageDescription
//
//let package = Package(
//    name: "PersonalFinanceApp",
//    platforms: [
//        .iOS(.v17)
//    ],
//    dependencies: [
//        .package(url: "https://github.com/realm/SwiftLint", from: "0.54.0"),
//        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.20.0")
//    ],
//    targets: [
//        .target(
//            name: "PersonalFinanceApp",
//            dependencies: [
//                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
//                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
//                .product(name: "FirebaseCore", package: "firebase-ios-sdk")
//            ],
//            plugins: [
//                .plugin(name: "SwiftLintPlugin", package: "SwiftLint")
//            ]
//        )
//    ]
//)


// MARK: - ViewModels
// Sources/ViewModels/TransactionViewModel.swift

// Sources/ViewModels/AccountViewModel.swift

// MARK: - Views
// Sources/Views/AuthenticationView.swift

// Sources/Views/SignInView.swift


// Sources/Views/SignUpView.swift

// Sources/Views/ContentView.swift


// Sources/Views/MainTabView.swift

// Sources/Views/DashboardView.swift

// Sources/Views/TransactionsView.swift

// Sources/Views/TransactionRowView.swift


// Sources/Views/AddTransactionView.swift


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
                     */*/
