//
//  DecodingTests.swift
//  
//
//  Created by Jeremy Kelleher on 1/24/23.
//

import XCTest

/// An "Abstract" test class meant to be subclassed that has tests for decoding enums or other types that can't be versioned.
/// These tests ensure that all non-versioned models in our Swift code are decoded in their expected way.
/// We can also include older versions of our JSON in case we remove or change cases to ensure these get migrated properly.
open class DecodingTests<Model>: XCTestCase where Model: Codable, Model: Equatable {

    /// An expectation that the tester defines declaring what the model should look like for a given piece of JSON
    public struct DecodingExpectation {
        
        public let model: Model
        public let json: String
        
        public init(model: Model, json: String) {
            self.model = model
            self.json = json
        }
        
    }
    
    /// An array with `DecodingExpectation` for each model instance (case for enums).
    ///
    /// This allows the tester to specify, for each model, what the JSON
    /// should look like for that model and the output of decoding of that JSON.
    /// Allows us to test all of the cases of this enum or models of a struct and how decoding of files
    /// containing any version of them would be migrated forward to the latest version.
    open var expectations: [DecodingExpectation] {
        [] // empty since this would be implemented in subclasses of `DecodingTests`
    }
    
    /// Test all of the JSON matches the specified case.
    func test_Expectations() throws {
        
        for expectation in expectations {
            
            let data = try XCTUnwrap(expectation.json.data(using: .utf8))
            let output = try JSONDecoder().decode(Model.self, from: data)
            
            XCTAssertEqual(expectation.model, output, "The JSON provided for the type \(Model.self) didn't decode into expected model: \(expectation.model).")
            
        }
        
    }
    
}
