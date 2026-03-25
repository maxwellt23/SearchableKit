# SearchableKit

A lightweight Swift package for filtering and ranking any collection of model types by text search.

---

## Installation

### Swift Package Manager

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/maxwellt23/SearchableKit", from: "1.0.0")
]
```

Or add it via **File › Add Package Dependencies…** in Xcode.

---

## Quick Start

### 1. Conform your model

```swift
import SearchableKit

struct Contact: Searchable {
    var name: String
    var email: String
    var company: String?

    func searchableFields() -> [SearchableField] {
        [
            SearchableField(name,    weight: 2.0),  // name ranks higher
            SearchableField(email,   weight: 1.0),
            SearchableField(company, weight: 1.5),
        ]
    }
}
```

### 2. Filter a collection

```swift
let results = contacts.filter(with: searchText)
```

### 3. Ranked results

```swift
let ranked = contacts.rankedSearch(for: searchText)
// returns [(element: Contact, score: Double)] sorted best-first
```

---

## SearchOptions

| Property | Type | Default | Description |
|---|---|---|---|
| `minCharacters` | `Int` | `1` | Minimum query length before filtering activates |
| `tokenStrategy` | `TokenStrategy` | `.any` | `.any` = at least one word matches; `.all` = every word must match |
| `rankResults` | `Bool` | `false` | Sort results by relevance score |
| `locale` | `Locale?` | `nil` | Locale for string comparison |

**Presets:**

```swift
.default  // minCharacters: 1, any-token, unranked
.strict   // all-token, ranked
.ranked   // any-token, ranked
```

### Custom options example

```swift
let options = SearchOptions(
    minCharacters: 2,
    tokenStrategy: .all,   // every word must appear somewhere
    rankResults: true
)
let results = contacts.filter(with: "alice acme", options: options)
```

---

## Scoring

| Match type | Score multiplier |
|---|---|
| Field starts with token | `weight × 2.0` |
| Field contains token | `weight × 1.0` |

Higher-weight fields push their items to the top of ranked results.

---

## Async API

Both methods have async variants that run off the main actor — useful for large data sets:

```swift
let results = await contacts.filter(with: searchText)
let ranked  = await contacts.rankedSearch(for: searchText)
```

---

## Platforms

| Platform | Minimum version |
|---|---|
| iOS | 15 |
| macOS | 12 |
| tvOS | 15 |
| watchOS | 8 |
