//
//  SearchOptions.swift
//  SearchableKit
//
//  Created by Tyler Maxwell on 3/24/26.
//

import Foundation

// MARK: - SearchOptions
/// Configuration for how a search should behave.
public struct SearchOptions {
    /// Minimum number of characters required before filtering begins.
    public var minCharacters: Int
    
    /// How multiple words in the query are handled.
    public var tokenStrategy: TokenStrategy
    
    /// Whether results should be sorted by match score (best first).
    public var rankResults: Bool
    
    /// The string comparison locale. Defaults to `nil` (current locale).
    public var locale: Locale?
    
    public init(
        minCharacters: Int = 1,
        tokenStrategy: TokenStrategy = .any,
        rankResults: Bool = false,
        locale: Locale? = nil
    ) {
        self.minCharacters = minCharacters
        self.tokenStrategy = tokenStrategy
        self.rankResults = rankResults
        self.locale = locale
    }
    
    /// Sensible defaults
    public static let `default` = SearchOptions()
    
    /// All tokens must match at least one field each.
    public static let strict = SearchOptions(tokenStrategy: .all, rankResults: true)
    
    /// Ranked results with any-token matching
    public static let ranked = SearchOptions(rankResults: true)
}

// MARK: - TokenStrategy
/// Determines how a multi-word query is evaluated.
public enum TokenStrategy {
    /// At least one word in the query must match
    case any
    
    /// Every word in the query must match at least one field.
    case all
}
