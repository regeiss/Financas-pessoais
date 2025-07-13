//
//  AppError.swift
//  Financas pessoais
//
//  Created by Roberto Edgar Geiss on 13/07/25.
//

import Foundation

enum AppError: LocalizedError, Sendable {
    case dataNotFound
    case invalidAmount
    case accountNotFound
    case transactionCreationFailed
    case budgetExceeded(category: String, limit: Decimal)
    case networkError(underlying: Error)
    case authenticationFailed
    case userNotFound
    case invalidCredentials
    case emailAlreadyExists
    case unknown(underlying: Error)
    
    var errorDescription: String? {
        switch self {
        case .dataNotFound:
            return "Dados não encontrados"
        case .invalidAmount:
            return "Valor inválido"
        case .accountNotFound:
            return "Conta não encontrada"
        case .transactionCreationFailed:
            return "Falha ao criar transação"
        case .budgetExceeded(let category, let limit):
            return "Orçamento da categoria \(category) excedido. Limite: \(limit)"
        case .networkError(let underlying):
            return "Erro de rede: \(underlying.localizedDescription)"
        case .authenticationFailed:
            return "Falha na autenticação"
        case .userNotFound:
            return "Usuário não encontrado"
        case .invalidCredentials:
            return "Email ou senha inválidos"
        case .emailAlreadyExists:
            return "Email já está em uso"
        case .unknown(let underlying):
            return "Erro desconhecido: \(underlying.localizedDescription)"
        }
    }
}
