//
//  FirebaseService.swift
//  Financas pessoais
//
//  Created by Roberto Edgar Geiss on 13/07/25.
//

import Foundation
import FirebaseCore
import FirebaseCrashlytics
import FirebaseAnalytics
import OSLog

protocol FirebaseServiceProtocol: Sendable {
    func configure()
    func logEvent(_ event: AnalyticsEvent)
    func recordError(_ error: Error, context: String)
    func recordNonFatalError(_ error: Error, context: String)
    func setUserID(_ userID: String)
    func setUserProperty(_ value: String?, forName name: String)
}

final class FirebaseService: FirebaseServiceProtocol, @unchecked Sendable {
    static let shared = FirebaseService()
    
    private let logger = Logger(subsystem: "com.personalfinance.app", category: "FirebaseService")
    private var isConfigured = false
    
    private init() {}
    
    func configure() {
        guard !isConfigured else {
            logger.warning("Firebase já foi configurado")
            return
        }
        
        // Verifica se o arquivo GoogleService-Info.plist existe
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              FileManager.default.fileExists(atPath: path) else {
            logger.error("GoogleService-Info.plist não encontrado. Firebase não será configurado.")
            return
        }
        
        FirebaseApp.configure()
        isConfigured = true
        
        logger.info("Firebase configurado com sucesso")
        
        // Configura propriedades padrão
        setUserProperty("ios", forName: "platform")
        setUserProperty("1.0.0", forName: "app_version")
        
        // Log inicial
        logEvent(.appStart)
    }
    
    func logEvent(_ event: AnalyticsEvent) {
        guard isConfigured else {
            logger.warning("Firebase não configurado. Evento não será enviado: \(event.name)")
            return
        }
        
        Analytics.logEvent(event.name, parameters: event.parameters)
        logger.info("Analytics event logged: \(event.name)")
        
        #if DEBUG
        print("📊 ANALYTICS: \(event.name) - \(event.parameters)")
        #endif
    }
    
    func recordError(_ error: Error, context: String) {
        guard isConfigured else {
            logger.warning("Firebase não configurado. Erro não será enviado: \(error.localizedDescription)")
            return
        }
        
        Crashlytics.crashlytics().record(error: error)
        Crashlytics.crashlytics().setCustomValue(context, forKey: "error_context")
        
        logger.error("Crashlytics error recorded: \(error.localizedDescription) - Context: \(context)")
        
        #if DEBUG
        print("💥 CRASHLYTICS ERROR: \(error.localizedDescription) - Context: \(context)")
        #endif
    }
    
    func recordNonFatalError(_ error: Error, context: String) {
        guard isConfigured else {
            logger.warning("Firebase não configurado. Erro não-fatal não será enviado: \(error.localizedDescription)")
            return
        }
        
        let nsError = error as NSError
        let userInfo = nsError.userInfo.merging(["context": context]) { _, new in new }
        let contextError = NSError(domain: nsError.domain, code: nsError.code, userInfo: userInfo)
        
        Crashlytics.crashlytics().record(error: contextError)
        
        logger.warning("Crashlytics non-fatal error recorded: \(error.localizedDescription) - Context: \(context)")
        
        #if DEBUG
        print("⚠️ CRASHLYTICS NON-FATAL: \(error.localizedDescription) - Context: \(context)")
        #endif
    }
    
    func setUserID(_ userID: String) {
        guard isConfigured else {
            logger.warning("Firebase não configurado. UserID não será definido: \(userID)")
            return
        }
        
        Analytics.setUserID(userID)
        Crashlytics.crashlytics().setUserID(userID)
        
        logger.info("Firebase UserID definido: \(userID)")
    }
    
    func setUserProperty(_ value: String?, forName name: String) {
        guard isConfigured else {
            logger.warning("Firebase não configurado. Propriedade não será definida: \(name)")
            return
        }
        
        Analytics.setUserProperty(value, forName: name)
        
        if let value = value {
            Crashlytics.crashlytics().setCustomValue(value, forKey: name)
            logger.info("Firebase user property set: \(name) = \(value)")
        }
    }
}
