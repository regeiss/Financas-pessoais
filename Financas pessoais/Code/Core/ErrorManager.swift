//
//  ErrorManager.swift
//  Financas pessoais
//
//  Created by Roberto Edgar Geiss on 13/07/25.
//

import Foundation
import OSLog

protocol ErrorManagerProtocol: Sendable {
    func handle(_ error: Error, context: String)
    func handleNonFatal(_ error: Error, context: String)
    func logWarning(_ message: String, context: String)
    func logInfo(_ message: String, context: String)
}

final class ErrorManager: ErrorManagerProtocol, @unchecked Sendable {
    static let shared = ErrorManager()
    
    private let logger = Logger(subsystem: "com.personalfinance.app", category: "ErrorManager")
    private let firebaseService: FirebaseServiceProtocol
    
    private init() {
        self.firebaseService = FirebaseService.shared
    }
    
    func handle(_ error: Error, context: String) {
        let errorInfo = """
        Context: \(context)
        Error: \(error.localizedDescription)
        Type: \(type(of: error))
        """
        
        logger.error("\(errorInfo)")
        
        // Envia para Firebase Crashlytics
        firebaseService.recordError(error, context: context)
        
        // Envia evento de analytics
        firebaseService.logEvent(.errorOccurred(
            errorType: String(describing: type(of: error)),
            context: context
        ))
        
        #if DEBUG
        print("🔴 ERROR: \(errorInfo)")
        #endif
    }
    
    func handleNonFatal(_ error: Error, context: String) {
        let errorInfo = """
        Context: \(context)
        Error: \(error.localizedDescription)
        Type: \(type(of: error))
        """
        
        logger.warning("\(errorInfo)")
        
        // Envia erro não-fatal para Firebase Crashlytics
        firebaseService.recordNonFatalError(error, context: context)
        
        #if DEBUG
        print("🟡 NON-FATAL ERROR: \(errorInfo)")
        #endif
    }
    
    func logWarning(_ message: String, context: String) {
        logger.warning("[\(context)] \(message)")
        
        #if DEBUG
        print("🟡 WARNING [\(context)]: \(message)")
        #endif
    }
    
    func logInfo(_ message: String, context: String) {
        logger.info("[\(context)] \(message)")
        
        #if DEBUG
        print("🔵 INFO [\(context)]: \(message)")
        #endif
    }
}
