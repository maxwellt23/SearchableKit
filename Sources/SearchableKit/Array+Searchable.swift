//
//  Array+Searchable.swift
//  SearchableKit
//
//  Created by Tyler Maxwell on 3/24/26.
//

import Foundation

// MARK: - Array + Searchable
public extension Array where Element: Searchable {
    // MARK: Filter
    /// Filters the array using a plain text query.
    ///
    /// - Parameters:
    ///   - searchText: The text to search for.
    ///   - minCharacters: Minimum characters before filtering activates. Default `1`.
    /// - Returns: Matching elements in their original order.
    func filter(with searchText: String, minCharacters: Int = 1) -> [Element] {
        filter(with: searchText, options: SearchOptions(minCharacters: minCharacters))
    }
    
    /// Filters the array using a query and explicit `SearchOptions`.
    ///
    /// - Parameters:
    ///   - searchText: The text to search for.
    ///   - options: A `SearchOptions` value that controls matching behaviour.
    /// - Returns: Matching elements; sorted by relevance if `options.rankResults` is `true`.
    func filter(with searchText: String, options: SearchOptions) -> [Element] {
        let cleaned = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty, cleaned.count >= options.minCharacters else { return self }
        
        if options.rankResults {
            return ranked(by: cleaned, options: options).map(\.element)
        }
        
        return self.filter { SearchEngine.matches($0, query: cleaned, options: options) }
    }
    
    // MARK: Ranked Search
    /// Returns matching elements paired with their relevance score, best match first.
    ///
    /// - Parameters:
    ///   - searchText: The text to search for.
    ///   - options: Search options. `rankResults` is implicitly `true`.
    /// - Returns: `(element, score)` tuples sorted descending by score.
    func rankedSearch(
        for searchText: String,
        options: SearchOptions = .ranked
    ) -> [(element: Element, score: Double)] {
        let cleaned = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty, cleaned.count >= options.minCharacters else { return [] }
        
        return ranked(by: cleaned, options: options)
    }
    
    // MARK: Async Variants
    /// Async version of `filter(with:options:)` — offloads work off the main actor.
    func filter(
        with searchText: String,
        options: SearchOptions = .default
    ) async -> [Element] {
        await Task.detached(priority: .userInitiated) {
            self.filter(with: searchText, options: options)
        }.value
    }
    
    /// Async version of `rankedSearch(for:options:)`.
    func rankedSearch(
        for searchText: String,
        options: SearchOptions = .ranked
    ) async -> [(element: Element, score: Double)] {
        await Task.detached(priority: .userInitiated) {
            self.rankedSearch(for: searchText, options: options)
        }.value
    }
    
    // MARK: Private
    private func ranked(
        by query: String,
        options: SearchOptions
    ) -> [(element: Element, score: Double)] {
        self.compactMap { item -> (element: Element, score: Double)? in
            let s = SearchEngine.score(item, query: query, options: options)
            return s > 0 ? (item, s) : nil
        }
        .sorted { $0.score > $1.score }
    }
}
