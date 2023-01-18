//
//  VersionableTests.swift
//  
//
//  Created by Jeremy Kelleher on 1/17/23.
//

import XCTest
import Versionable

open class VersionableTests<Model>: XCTestCase where Model: Versionable, Model: Decodable {
    
    public struct DecodingExpectation {
        
        let model: Model
        let json: String
        
        public init(model: Model, json: String) {
            self.model = model
            self.json = json
        }
        
    }
    
    /// A dictionary with `DecodingExpectation` for each `Version`.
    ///
    /// This allows the tester to specify, for each version, what the JSON
    /// should look like for a model and the output of decoding of that JSON.
    /// Allows us to test all of the versions of this model and how decoding of files
    /// containing any version of this model would be migrated forward to the latest version.
    open var expectations: [Model.Version: DecodingExpectation] {
        [:] // empty since this would be implemented in subclasses of `VersionableTests`
    }
    
    /// Tests that the versions are in order in the actual enum's implementation.
    func test_Ordered_Versions() {

        let allCases = Model.Version.allCases
        
        let sortedCases = allCases.sorted()
        let arrayAllCases = allCases.map { $0 } // necessary since `allCases` is a special type: `Model.Version.AllCases`
        
        XCTAssertEqual(arrayAllCases, sortedCases, "The cases in \(Model.Version.self) should be in order. Update the ordering to be: \(sortedCases)")

    }
    
    /// Tests that `Model.Version.latest` is using the last version in enum.
    func test_Last_Version_Is_Latest_Version() throws {
        
        let lastCase = try XCTUnwrap(Model.Version.allCases.reversed().first)
        XCTAssertEqual(lastCase, Model.Version.latest, "The last case (\(lastCase)) in \(Model.Version.self) should be the latest version.")
        
    }
    
    func test_Current_Model_Uses_Latest_Version() throws {
        
        let decodingExpectation = try XCTUnwrap(expectations[Model.Version.latest], "The latest version (\(Model.Version.latest)) of \(Model.self) did not have a decoding expectation.")
        
        let latestModel = decodingExpectation.model
        
        XCTAssertEqual(latestModel.version, Model.Version.latest, "Models created in code should always have the latest version. The \(Model.self) created in code for version \(Model.Version.latest) didn't have the latest version for it's `.version` property.")
        
    }
    
    func test_Encoding_Uses_Latest_Version() throws {
        
        let decodingExpectation = try XCTUnwrap(expectations[Model.Version.latest], "The latest version (\(Model.Version.latest)) of \(Model.self) did not have a decoding expectation.")
        
        let latestModel = decodingExpectation.model
        
        let encodedData = try JSONEncoder().encode(latestModel)
        let decodedModel = try JSONDecoder().decode(Model.self, from: encodedData)
        
        XCTAssertEqual(decodedModel.version, Model.Version.latest, "The latest version (\(Model.Version.latest)) wasn't use in encoding \(Model.self)")
        XCTAssertEqual(decodedModel, latestModel)
        
    }
    
    /// Tests that all versions have a sample JSON and the expected model
    /// from decoding that JSON. Also ensures that all properties from
    /// the expected model and the output of decoding the JSON match.
    func test_Decoding_All_Versions() throws {

        for version in Model.Version.allCases {

            // ensures that all versions have test data
            let decodingExpectation = try XCTUnwrap(expectations[version], "No input JSON and expected output were found for \(Model.self) version \(version)")

            let output = try decode(json: decodingExpectation.json)
            
            // use `Mirror` to dynamically extract all of the properties of this object
            let outputMirror = Mirror(reflecting: output)
            let expectedOutputMirror = Mirror(reflecting: decodingExpectation.model)

            // compare all of the properties in the decoded object to what was expected
            for (outputProperty, expectedProperty) in zip(outputMirror.children, expectedOutputMirror.children) {
                
                guard outputProperty.label == expectedProperty.label else {
                    XCTFail("The labels of properties in the output and expected models should match: \(String(describing: outputProperty.label)) != \(String(describing: expectedProperty.label))")
                    continue // moves to the next property
                }
                
                // need to use strings here since `.value` is `Any`.
                let outputValue = String(describing: outputProperty.value)
                let expectedValue = String(describing: expectedProperty.value)
                
                XCTAssertEqual(outputValue, expectedValue, "The output of decoding \(String(describing: outputProperty.label)) in version \(version) of \(Model.self) was \(outputValue) and it was expected to be \(expectedValue).")
            }

        }

    }
    
    /// Decodes JSON to the `Model` type.
    func decode(json: String) throws -> Model {
        
        let data = try XCTUnwrap(json.data(using: .utf8))
        let output = try JSONDecoder().decode(Model.self, from: data)
        
        XCTAssertEqual(output.version, Model.Version.latest, "No matter, the input's version, the output decoding of a `Versionable` should have the `Version.latest` as it's `version`. Make sure to update \(Model.self).version to be \(Model.Version.latest).")
                
        return output
        
    }
    
}
