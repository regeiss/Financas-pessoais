//
//  Enums.swift
//  Financas pessoais
//
//  Created by Roberto Edgar Geiss on 13/07/25.
//

import Foundation

enum TransactionType: String, CaseIterable, Codable {
    case income = "income"
    case expense = "expense"
    
    var displayName: String {
        switch self {
        case .income: return "Receita"
        case .expense: return "Despesa"
        }
    }
}

enum TransactionCategory: String, CaseIterable, Codable {
    case food = "food"
    case transport = "transport"
    case entertainment = "entertainment"
    case healthcare = "healthcare"
    case shopping = "shopping"
    case bills = "bills"
    case salary = "salary"
    case investment = "investment"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .food: return "Alimentação"
        case .transport: return "Transporte"
        case .entertainment: return "Entretenimento"
        case .healthcare: return "Saúde"
        case .shopping: return "Compras"
        case .bills: return "Contas"
        case .salary: return "Salário"
        case .investment: return "Investimento"
        case .other: return "Outros"
        }
    }
    
    var iconName: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "car"
        case .entertainment: return "gamecontroller"
        case .healthcare: return "cross"
        case .shopping: return "bag"
        case .bills: return "doc.text"
        case .salary: return "dollarsign.circle"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .other: return "questionmark.circle"
        }
    }
}

enum AccountType: String, CaseIterable, Codable {
    case checking = "checking"
    case savings = "savings"
    case credit = "credit"
    case investment = "investment"
    
    var displayName: String {
        switch self {
        case .checking: return "Conta Corrente"
        case .savings: return "Poupança"
        case .credit: return "Cartão de Crédito"
        case .investment: return "Investimento"
        }
    }
}
