//
//  Searchable.swift
//  SearchableKit
//
//  Created by Tyler Maxwell on 3/24/26.
//

import Foundation

// MARK: - SearchableField
/// Represents a single searchable field with an optional weight.
/// Higher weight means this field ranks more strongly in scored results.
public struct SearchableField {
    public let value: String?
    public let weight: Double
    
    public init(_ value: String?, weight: Double = 1.0) {
        self.value = value
        self.weight = max(0, weight)
    }
}

// MARK - Searchable Protocol
/// Conform your model types to `Searchable` to enable filtering and ranked search.
///
/// **Basic usage:**
/// ```swift
/// struct Contact: Searchable {
///     var name: String
///     var email: String
///
///     func searchableFields() -> [SearchableField] {
///         [
///             SearchableField(name, weight: 2.0), // name ranks higher
///             SearchableField(email)
///         ]
///     }
/// }
/// ```
public protocol Searchable {
    /// Return the fields that should be searched, with optional weights.
    /// Default weight is `1.0`. Use higher values to promote certain fields.
    func searchableFields() -> [SearchableField]
}
