import Foundation
import Observation

enum EditorSection: CaseIterable, Hashable {
    case identity
    case characteristics
    case combatAndDerived
    case social
    case economy
    case passions
}

@MainActor
@Observable
final class CharacterEditorViewModel {
    let character: RQCharacter

    var expandedSections: Set<EditorSection>
    let availableSections: [EditorSection]

    private(set) var statRollProfile: StatRollProfile
    private let rollExpressionHandler: (DiceExpression) -> DiceRollResult

    private var customExpressions: [CharacteristicKey: String] = [:]
    private var validationErrors: [CharacteristicKey: String] = [:]
    private var pendingRollTotals: [CharacteristicKey: Int] = [:]
    private var latestRollResults: [CharacteristicKey: DiceRollResult] = [:]

    init(
        character: RQCharacter,
        statRollProfile: StatRollProfile? = nil,
        rollExpressionHandler: ((DiceExpression) -> DiceRollResult)? = nil
    ) {
        self.character = character
        self.statRollProfile = statRollProfile ?? .defaultHuman
        self.rollExpressionHandler = rollExpressionHandler ?? { expression in
            var generator = SystemRandomNumberGenerator()
            return DefaultDiceRoller().roll(expression, using: &generator)
        }
        self.availableSections = EditorSection.allCases
        self.expandedSections = Set(EditorSection.allCases)
    }

    func toggle(_ section: EditorSection) {
        if expandedSections.contains(section) {
            expandedSections.remove(section)
        } else {
            expandedSections.insert(section)
        }
    }

    func applyCharacteristic(_ characteristic: RQCharacter.Characteristic, value: Int) {
        character.setCharacteristic(characteristic, to: value)
    }

    func expressionText(for key: CharacteristicKey) -> String {
        customExpressions[key] ?? defaultExpressionText(for: key)
    }

    func setCustomExpression(_ source: String, for key: CharacteristicKey) {
        customExpressions[key] = source
        validationErrors[key] = validationErrorMessage(for: key)
    }

    func rollValidationError(for key: CharacteristicKey) -> String? {
        validationErrors[key]
    }

    func pendingRollTotal(for key: CharacteristicKey) -> Int? {
        pendingRollTotals[key]
    }

    func latestRollSummary(for key: CharacteristicKey) -> String? {
        guard let result = latestRollResults[key] else {
            return nil
        }

        return "Rolled \(result.rolls) -> \(result.total)"
    }

    @discardableResult
    func rollCharacteristic(_ key: CharacteristicKey) -> DiceRollResult? {
        validationErrors[key] = validationErrorMessage(for: key)
        guard validationErrors[key] == nil else {
            pendingRollTotals[key] = nil
            latestRollResults[key] = nil
            return nil
        }

        guard let expression = parseExpression(for: key) else {
            pendingRollTotals[key] = nil
            latestRollResults[key] = nil
            return nil
        }

        let result = rollExpressionHandler(expression)
        pendingRollTotals[key] = result.total
        latestRollResults[key] = result
        return result
    }

    func applyPendingRoll(for key: CharacteristicKey) {
        guard let value = pendingRollTotals[key] else {
            return
        }

        applyCharacteristic(key.modelCharacteristic, value: value)
    }

    func clearPendingRoll(for key: CharacteristicKey) {
        pendingRollTotals[key] = nil
        latestRollResults[key] = nil
        validationErrors[key] = nil
    }

    func addPassion(description: String, percentage: Int) {
        character.addPassion(description: description, percentage: percentage)
        normalizePassionSortOrder()
    }

    func updatePassion(_ passion: CharacterPassion, description: String, percentage: Int) {
        passion.descriptionText = description
        passion.percentage = percentage.clampedPercentage
    }

    var sortedPassions: [CharacterPassion] {
        sortedPassionsInternal()
    }

    func movePassions(from offsets: IndexSet, to destination: Int) {
        var ordered = sortedPassionsInternal()
        ordered = move(ordered, from: offsets, to: destination)

        for (index, passion) in ordered.enumerated() {
            passion.sortOrder = index
        }
    }

    func deletePassions(at offsets: IndexSet) {
        let ordered = sortedPassionsInternal()
        let removing = offsets.compactMap { index in
            ordered.indices.contains(index) ? ordered[index] : nil
        }

        character.passions.removeAll { passion in
            removing.contains { $0 === passion }
        }

        normalizePassionSortOrder()
    }

    private func sortedPassionsInternal() -> [CharacterPassion] {
        character.passions.sorted { lhs, rhs in
            if lhs.sortOrder == rhs.sortOrder {
                return lhs.descriptionText < rhs.descriptionText
            }
            return lhs.sortOrder < rhs.sortOrder
        }
    }

    private func normalizePassionSortOrder() {
        let ordered = sortedPassionsInternal()
        for (index, passion) in ordered.enumerated() {
            passion.sortOrder = index
        }
    }

    private func defaultExpressionText(for key: CharacteristicKey) -> String {
        statRollProfile.expression(for: key).normalizedDescription
    }

    private func parseExpression(for key: CharacteristicKey) -> DiceExpression? {
        let source = customExpressions[key]?.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolved = (source?.isEmpty == false) ? source! : defaultExpressionText(for: key)
        return try? DiceExpression(parsing: resolved)
    }

    private func validationErrorMessage(for key: CharacteristicKey) -> String? {
        let source = customExpressions[key]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if source.isEmpty {
            return nil
        }

        do {
            _ = try DiceExpression(parsing: source)
            return nil
        } catch {
            return "Enter a valid dice formula like 4d6L or 3d8H-1."
        }
    }

    private func move<T>(_ array: [T], from offsets: IndexSet, to destination: Int) -> [T] {
        var result = array
        let moving = offsets.map { result[$0] }

        for index in offsets.sorted(by: >) {
            result.remove(at: index)
        }

        let adjustedDestination = destination - offsets.filter { $0 < destination }.count
        result.insert(contentsOf: moving, at: adjustedDestination)
        return result
    }
}
