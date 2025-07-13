//
//  SettingsView.swift
//  Financas pessoais
//
//  Created by Roberto Edgar Geiss on 13/07/25.
//

import SwiftUI

struct SettingsView: View {
    private let themeManager = ThemeManager.shared
    private let firebaseService = FirebaseService.shared
    
    var body: some View {
        List {
            Section("Aparência") {
                Picker("Tema", selection: Binding(
                    get: { themeManager.currentTheme },
                    set: { themeManager.setTheme($0) }
                )) {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        Text(theme.displayName).tag(theme)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Section("Moeda") {
                HStack {
                    Text("Moeda preferida")
                    Spacer()
                    Text("Real (BRL)")
                        .foregroundColor(.secondary)
                }
            }
            
            #if DEBUG
            Section("Debug (Apenas em desenvolvimento)") {
                Button("Testar Crash Não-Fatal") {
                    let testError = NSError(domain: "TestDomain", code: 999, userInfo: [
                        NSLocalizedDescriptionKey: "Erro de teste para demonstrar Crashlytics"
                    ])
                    ErrorManager.shared.handleNonFatal(testError, context: "SettingsView.testCrash")
                }
                .foregroundColor(.orange)
                
                Button("Testar Analytics Event") {
                    firebaseService.logEvent(AnalyticsEvent(name: "test_event", parameters: [
                        "test_parameter": "test_value",
                        "timestamp": Date().timeIntervalSince1970
                    ]))
                }
                .foregroundColor(.blue)
            }
            #endif
            
            Section("Sobre") {
                HStack {
                    Text("Versão")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Firebase")
                    Spacer()
                    Text("Ativo")
                        .foregroundColor(.green)
                }
            }
        }
        .navigationTitle("Configurações")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            firebaseService.logEvent(.settingsViewed)
        }
    }
}
