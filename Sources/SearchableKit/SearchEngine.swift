//
//  SearchEngine.swift
//  SearchableKit
//
//  Created by Tyler Maxwell on 3/24/26.
//

import Foundation

// MARK: - SearchEngine
/// Internal engine that computes scores and matches.
enum SearchEngine {
    // MARK: Tokenisation
    static func tokens(from query: String) -> [String] {
        query
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespacesAndNewlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    // MARK: Match Check
    /// Returns `true` if `item` satisfies the query under `options`.
    static func matches<T: Searchable>(
        _ item: T,
        query: String,
        options: SearchOptions
    ) -> Bool {
        score(item, query: query, options: options) > 0
    }
    
    // MARK: Scoring
    /// Returns a relevance score >= 0. Zero means no match.
    ///
    /// Scoring rules:
    /// - Prefix match: weight x 2.0
    /// - Contains match: weight x 1.0
    /// - Each matching token contributes independently.
    static func score<T: Searchable>(
        _ item: T,
        query: String,
        options: SearchOptions
    ) -> Double {
        let queryTokens = tokens(from: query)
        guard !queryTokens.isEmpty else { return 0 }
        
        let fields = item.searchableFields()
            .compactMap { field -> (value: String, weight: Double)? in
                guard let v = field.value, !v.isEmpty else { return nil }
                return (v, field.weight)
            }
        
        guard !fields.isEmpty else { return 0 }
        
        switch options.tokenStrategy {
        case .any:
            return queryTokens.reduce(0.0) { total, token in
                total + bestFieldScore(for: token, in: fields, locale: options.locale)
            }
        case .all:
            var total = 0.0
            for token in queryTokens {
                let s = bestFieldScore(for: token, in: fields, locale: options.locale)
                guard s > 0 else { return 0 } // all tokens must match
                total += s
            }
            
            return total
        }
    }
    
    // MARK: Private Helpers
    private static func bestFieldScore(
        for token: String,
        in fields: [(value: String, weight: Double)],
        locale: Locale?
    ) -> Double {
        fields.reduce(0.0) { best, field in
            let s = fieldScore(token: token, fieldValue: field.value, weight: field.weight, locale: locale)
            return max(best, s)
        }
    }
    
    private static func fieldScore(
        token: String,
        fieldValue: String,
        weight: Double,
        locale: Locale?
    ) -> Double {
        let compareOptions: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
        
        // Prefix match - stronger signal
        if fieldValue.range(of: token, options: compareOptions.union(.anchored), locale: locale) != nil {
            return weight * 2.0
        }
        
        // Substring match
        if fieldValue.range(of: token, options: compareOptions, locale: locale) != nil {
            return weight * 1.0
        }
        
        return 0
    }
}
