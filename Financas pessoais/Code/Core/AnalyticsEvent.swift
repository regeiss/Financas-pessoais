//
//  AnalyticsEvent.swift
//  Financas pessoais
//
//  Created by Roberto Edgar Geiss on 13/07/25.
//

import Foundation

struct AnalyticsEvent {
    let name: String
    let parameters: [String: Any]
    
    init(name: String, parameters: [String: Any] = [:]) {
        self.name = name
        self.parameters = parameters
    }
}

extension AnalyticsEvent {
    // App Events
    static let appStart = AnalyticsEvent(name: "app_start")
    static let appBackground = AnalyticsEvent(name: "app_background")
    static let appForeground = AnalyticsEvent(name: "app_foreground")
    
    // Authentication Events
    static let signInAttempt = AnalyticsEvent(name: "sign_in_attempt")
    static let signInSuccess = AnalyticsEvent(name: "sign_in_success")
    static let signInFailure = AnalyticsEvent(name: "sign_in_failure")
    static let signUpAttempt = AnalyticsEvent(name: "sign_up_attempt")
    static let signUpSuccess = AnalyticsEvent(name: "sign_up_success")
    static let signUpFailure = AnalyticsEvent(name: "sign_up_failure")
    static let signOut = AnalyticsEvent(name: "sign_out")
    
    // Transaction Events
    static func transactionCreated(type: String, category: String, amount: Double) -> AnalyticsEvent {
        return AnalyticsEvent(name: "transaction_created", parameters: [
            "transaction_type": type,
            "category": category,
            "amount": amount
        ])
    }
    
    static func transactionDeleted(type: String, category: String) -> AnalyticsEvent {
        return AnalyticsEvent(name: "transaction_deleted", parameters: [
            "transaction_type": type,
            "category": category
        ])
    }
    
    // Profile Events
    static let profileViewed = AnalyticsEvent(name: "profile_viewed")
    static let profileEdited = AnalyticsEvent(name: "profile_edited")
    static let profilePhotoUpdated = AnalyticsEvent(name: "profile_photo_updated")
    
    // Settings Events
    static func themeChanged(theme: String) -> AnalyticsEvent {
        return AnalyticsEvent(name: "theme_changed", parameters: [
            "theme": theme
        ])
    }
    
    static let settingsViewed = AnalyticsEvent(name: "settings_viewed")
    
    // Navigation Events
    static func screenViewed(screenName: String) -> AnalyticsEvent {
        return AnalyticsEvent(name: "screen_view", parameters: [
            "screen_name": screenName
        ])
    }
    
    // Error Events
    static func errorOccurred(errorType: String, context: String) -> AnalyticsEvent {
        return AnalyticsEvent(name: "error_occurred", parameters: [
            "error_type": errorType,
            "context": context
        ])
    }
    
    // Feature Usage Events
    static let dashboardViewed = AnalyticsEvent(name: "dashboard_viewed")
    static let accountsViewed = AnalyticsEvent(name: "accounts_viewed")
    static let budgetViewed = AnalyticsEvent(name: "budget_viewed")
    static let transactionsViewed = AnalyticsEvent(name: "transactions_viewed")
}
