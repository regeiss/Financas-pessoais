//
//  ThemeManager.swift
//  Financas pessoais
//
//  Created by Roberto Edgar Geiss on 16/07/25.
//

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
