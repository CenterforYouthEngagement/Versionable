# Versionable

A Swift package that provides versioning and migration for `Codable` model types. Versionable allows you to evolve your data models over time while maintaining backward compatibility with older JSON data.

## Features

- **Version Migration**: Seamlessly migrate JSON data from older versions to the latest version
- **Type-Safe Versioning**: Use enums to define version types with automatic migration logic
- **Testing Utilities**: Built-in test helpers to verify version migrations work correctly
- **Debug Tools**: Save JSON files for testing and development

## How It Works

Conform your model to the `Versionable` protocol and implement a `Version` enum. The framework automatically handles reading the version from JSON and migrating data to the latest version using your custom migration logic.

Perfect for apps that need to handle evolving data schemas while maintaining compatibility with user data stored in older formats.

## Example

Here's a simple example showing how to version a user model:

```swift
import Foundation
import Versionable

public struct User: Identifiable, Hashable {
    
    public let id: UUID
    public let displayName: String
    public let email: String?
    
    public var version: Version = .v2
    
    public init(id: UUID = UUID(), displayName: String, email: String? = nil) {
        self.id = id
        self.displayName = displayName
        self.email = email
    }
}

extension User: Versionable {
    
    public enum CodingKeys: CodingKey {
        case version
        case id
        case displayName
        case email
    }
    
    public enum Version: Int, VersionType {
        
        case v1 = 1
        case v2 = 2
        
        public func extract(from container: KeyedDecodingContainer<User.CodingKeys>) throws -> User {
            
            switch self {
                
            case .v1:
                // Extract v1 properties (only displayName)
                let id = try container.decode(User.ID.self, forKey: .id)
                let displayName = try container.decode(String.self, forKey: .displayName)
                
                // Migrate v1 to v2: email is nil for v1 data
                return User(id: id, displayName: displayName, email: nil)
                
            case .v2:
                // Extract v2 properties (displayName and optional email)
                let id = try container.decode(User.ID.self, forKey: .id)
                let displayName = try container.decode(String.self, forKey: .displayName)
                let email = try container.decodeIfPresent(String.self, forKey: .email)
                
                return User(id: id, displayName: displayName, email: email)
                
            }
            
        }
        
        public var explanation: String {
            switch self {
            case .v1: return "Initial version with display name only"
            case .v2: return "Added optional email field"
            }
        }
        
    }
}
```

### Example JSON Migration

**v1 JSON:**
```json
{
  "version": 1,
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "displayName": "Jane Doe"
}
```

**When decoded, it becomes a v2 User with:**
- `id`: `123e4567-e89b-12d3-a456-426614174000`
- `displayName`: "Jane Doe"
- `email`: `nil`
- `version`: `.v1`

**v2 JSON:**
```json
{
  "version": 2,
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "displayName": "Jane Doe",
  "email": "jane@example.com"
}
```

**When decoded, it becomes a v2 User with:**
- `id`: `123e4567-e89b-12d3-a456-426614174000`
- `displayName`: "Jane Doe"
- `email`: "jane@example.com"
- `version`: `.v2`

## Testing

Here's how to test the User model's versioning functionality:

```swift
import XCTest
import Versionable
import VersionableTests

final class UserVersionableTests: VersionableTests<User> {

    override var expectations: [User.Version: DecodingExpectation] {
        [
            .v1: DecodingExpectation(
                model: User(id: UUID(uuidString: "07159D39-262F-415D-9B08-F762A5099A3D")!, displayName: "Jane Doe", email: nil),
                json: """
                {
                    "id" : "07159D39-262F-415D-9B08-F762A5099A3D",
                    "displayName" : "Jane Doe",
                    "version": 1
                }
                """),
            
            .v2: DecodingExpectation(
                model: User(id: UUID(uuidString: "07159D39-262F-415D-9B08-F762A5099A3D")!, displayName: "Jane Doe", email: "jane@example.com"),
                json: """
                {
                    "id" : "07159D39-262F-415D-9B08-F762A5099A3D",
                    "displayName" : "Jane Doe",
                    "email" : "jane@example.com",
                    "version": 2
                }
                """)
        ]
    }

}
```

This test verifies that:
- v1 JSON with only `displayName` correctly migrates to a v2 User with `email: nil`
- v2 JSON with both `displayName` and `email` correctly decodes to a v2 User
- The framework automatically handles version migration and ensures all decoded models have the latest version
