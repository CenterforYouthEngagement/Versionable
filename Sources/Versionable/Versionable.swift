//
//  Versionable.swift
//  
//
//  Created by Jeremy Kelleher on 1/13/23.
//

import Foundation

/// A protocol used for versioning model types that are `Codable`. This is done using
/// a `version` property, typically implemented with an `enum` that contains
/// an `extract` function that extracts the current model from the JSON and migrates it
/// to the latest version. 
public protocol Versionable: Codable, Equatable {
    
    /// The `CodingKey` implementation used to get the properties for this model out of the JSON
    associatedtype CodingKeys: CodingKey
    
    /// A type used to represent the different versions that have been offered by this type.
    associatedtype Version: VersionType<Self>
    
    /// The version of this instance.
    ///
    /// - Note: In code, we should always have the latest version of model schemas.
    /// This property is only used to read the version from JSON in `Version.extract`
    /// and decode using the proper decoders for that version to migrate the instance to the latest version.
    /// - Note: This property can't be computed (say to always be the `Version.latest`
    /// since computed properties can't be encoded using the automatic `Encodable` conformance.
    var version: Version { get }
    
}

extension Versionable {
    
    public init(from decoder: Decoder) throws {
        
        // get the version from the JSON
        let versionContainer = try decoder.container(keyedBy: VersionableCodingKeys.self)
        let serializedVersion = try versionContainer.decode(Self.Version.self, forKey: .version)
        
        // create a decoding container that can be used to extract the actual properties for this model
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // extract the model using the version found in the JSON and migrate it to the latest version
        self = try serializedVersion.extract(from: container)
        
    }
    
    // Note: No encoding implementation is necessary as we always encode the latest version using the automatic encoder.
    
}

/// A protocol that `Versionable` types use to represent versions.
/// Typically, an `enum` is used to implement this protocol.
/// The `extract(from:)` is used to extract and migrate JSON data to the latest version.
public protocol VersionType<Model>: Codable, RawRepresentable<Int>, CaseIterable, Comparable, Hashable {
    
    /// The `Model` type that this version is referring to.
    associatedtype Model: Versionable
    
    /// Extracts the model from the `container`.
    ///
    ///
    /// This function migrates the model stored in the JSON to the latest version.
    /// If the JSON is already using the latest version, that model is simply returned.
    /// If not, the JSON is modifed to jump from the JSON's version to the latest version.
    /// - Parameter container: The `Decoder` container given to use by `Codable.init(from: Decoder)`.
    /// Conveniently, this function gets the already keyd container using the`Model.CodingKeys`
    /// so the implementer doesn't need to parse this out.
    /// - Returns: This function extracts the `Model` from the `container` and returns it.
    func extract(from container: KeyedDecodingContainer<Model.CodingKeys>) throws -> Model
    
    /// An explanation of what this version changed.
    var explanation: String { get }
    
}

public extension VersionType {
    
    /// Conformance with `Comparable` to allow for finding the latest version.
    static func < (a: Self, b: Self) -> Bool {
        return a.rawValue < b.rawValue
    }
    
    /// The latest (highest) version of this type.
    static var latest: Self {
        let allCases = Self.allCases.sorted()
        return allCases[allCases.index(allCases.endIndex, offsetBy: -1)]
    }
    
}


/// A helper `CodingKey` used to extract just the `version` from `Versionable` JSON.
enum VersionableCodingKeys: CodingKey {
    case version
}
