import CoreData
import SwiftData
import Testing
@testable import RQSheet

struct CloudKitSchemaTests {
    @Test @MainActor
    func persistedModelSatisfiesCloudKitRequirements() throws {
        let model = try #require(NSManagedObjectModel.makeManagedObjectModel(for: RQSchemaV2.schema))
        for entity in model.entities {
            #expect(entity.uniquenessConstraints.isEmpty, "Uniqueness: \(entity.name ?? "?")")
            for attribute in entity.attributesByName.values {
                #expect(attribute.isOptional || attribute.defaultValue != nil, "Required default: \(entity.name ?? "?").\(attribute.name)")
            }
            for relationship in entity.relationshipsByName.values {
                #expect(relationship.isOptional, "Optional relationship: \(entity.name ?? "?").\(relationship.name)")
                #expect(relationship.inverseRelationship != nil, "Inverse: \(entity.name ?? "?").\(relationship.name)")
                #expect(relationship.deleteRule != .denyDeleteRule)
            }
        }
    }
}
