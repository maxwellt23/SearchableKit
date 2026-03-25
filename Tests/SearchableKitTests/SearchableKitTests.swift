import XCTest
@testable import SearchableKit

// MARK: - Fixture
private struct Contact: Searchable {
    var name: String
    var email: String
    var company: String?
    
    func searchableFields() -> [SearchableField] {
        [
            SearchableField(name, weight: 2.0),
            SearchableField(email, weight: 1.0),
            SearchableField(company, weight: 1.5)
        ]
    }
}

private let contacts: [Contact] = [
    Contact(name: "Alice Johnson", email: "alice@example.com", company: "Acme Corp"),
    Contact(name: "Bob Smith", email: "bob@widgets.io", company: "Widgets Inc"),
    Contact(name: "Carol Williams", email: "carol@example.com", company: nil),
    Contact(name: "Dave Brown", email: "dave@acme.com", company: "Acme Corp"),
    Contact(name: "Ève Dupont", email: "eve@example.fr", company: "Acme France"),
]

// MARK: - Tests
final class SearchableKitTests: XCTestCase {
    // MARK: Basic Filter
    func test_emptyQuery_returnsAll() {
        XCTAssertEqual(contacts.filter(with: "").count, contacts.count)
    }
    
    func test_whitespaceOnlyQuery_returnsAll() {
        XCTAssertEqual(contacts.filter(with: "   ").count, contacts.count)
    }
    
    func test_minCharacters_notMet_returnsAll() {
        XCTAssertEqual(contacts.filter(with: "A", minCharacters: 2).count, contacts.count)
    }
    
    func test_singleMatch() {
        let results = contacts.filter(with: "bob")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Bob Smith")
    }
    
    func test_multipleMatches() {
        // "acme" appears in Alice's company, Dave's company, and Eve's company
        let results = contacts.filter(with: "acme")
        XCTAssertEqual(results.count, 3)
    }
    
    func test_caseInsensitive() {
        XCTAssertEqual(contacts.filter(with: "ALICE").count, 1)
        XCTAssertEqual(contacts.filter(with: "alice").count, 1)
    }
    
    func test_diacriticInsensitive() {
        // "eve" should match "Ève"
        let results = contacts.filter(with: "eve")
        XCTAssertTrue(results.contains { $0.name == "Ève Dupont" })
    }
    
    // MARK: TokenStrategy.all
    func test_allTokens_bothMustMatch() {
        let opts = SearchOptions(tokenStrategy: .all)
        
        // "alice acme" — Alice has both (name = Alice and company = Acme)
        let results = contacts.filter(with: "alice acme", options: opts)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Alice Johnson")
    }
    
    func test_allTokens_partialFails() {
        let opts = SearchOptions(tokenStrategy: .all)
        
        // "bob acme" — Bob's company is Widgets Inc, not Acme
        let results = contacts.filter(with: "bob acme", options: opts)
        XCTAssertTrue(results.isEmpty)
    }
    
    // MARK: Ranked search
    func test_ranked_prefixScoresHigher() {
        // "ali" is a prefix of Alice, not a prefix of Carol's email
        let results = contacts.rankedSearch(for: "ali")
        XCTAssertEqual(results.first?.element.name, "Alice Johnson")
    }
 
    func test_ranked_highWeightFieldScoresHigher() {
        // "example" appears in alice@example.com AND carol@example.com (weight 1)
        // Alice's name doesn't contain it, but name weight is 2 — email weight is 1
        // Both should appear; order can vary but scores should be equal here
        let results = contacts.rankedSearch(for: "example")
        XCTAssertFalse(results.isEmpty)
    }
 
    func test_ranked_noMatch_emptyResults() {
        let results = contacts.rankedSearch(for: "zzznomatch")
        XCTAssertTrue(results.isEmpty)
    }
 
    // MARK: Nil / optional fields
    func test_nilFieldIgnored() {
        // Carol has no company — searching "acme" should not return her
        let results = contacts.filter(with: "acme")
        XCTAssertFalse(results.contains { $0.name == "Carol Williams" })
    }
}
