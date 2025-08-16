//
//  Formatters.swift
//  MoviesApp
//
//  Created by Muhannad El Menawy on 14/08/2025.
//

import Foundation

enum Formatters {
    private static let parse: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; f.locale = .autoupdatingCurrent; return f
    }()
    static let year: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "yyyy"; f.locale = .autoupdatingCurrent; return f
    }()
    static let yearMonth: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "LLLL yyyy"; f.locale = .autoupdatingCurrent; return f
    }()

    static func parseDate(_ s: String?) -> Date? { s.flatMap { parse.date(from: $0) } }

    static func currencyUSD(_ n: Int?) -> String {
        guard let n else { return "—" }
        let nf = NumberFormatter(); nf.numberStyle = .currency; nf.currencyCode = "USD"
        return nf.string(from: NSNumber(value: n)) ?? "$\(n)"
    }

    static func runtime(_ minutes: Int?) -> String {
        guard let m = minutes else { return "—" }
        let h = m / 60, r = m % 60; return h > 0 ? "\(h)h \(r)m" : "\(r)m"
    }
}
