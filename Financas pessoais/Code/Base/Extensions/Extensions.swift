//
//  Extensions.swift
//  Financas pessoais
//
//  Created by Roberto Edgar Geiss on 16/07/25.
//

import Foundation

extension Decimal {
    var doubleValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }
}

extension Date {
    func startOfMonth() -> Date {
        Calendar.current.dateInterval(of: .month, for: self)?.start ?? self
    }
    
    func endOfMonth() -> Date {
        Calendar.current.dateInterval(of: .month, for: self)?.end ?? self
    }
}
