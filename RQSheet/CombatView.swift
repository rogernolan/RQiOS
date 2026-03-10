//
//  CombatView.swift
//  RQSheet
//

import SwiftUI
import SwiftData

struct CombatView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var characters: [RQCharacter]
    @State private var presentedEditor: WeaponEditorSheet?
    @State private var pendingDeleteWeapon: Weapon?
    @State private var expandedWeaponIDs: Set<ObjectIdentifier> = []
    @State private var swipedWeaponID: ObjectIdentifier?

    var character: RQCharacter? {
        characters.first
    }

    var body: some View {
        Group {
            if let character {
                GeometryReader { geometry in
                    VStack(alignment: .leading, spacing: 12) {
                        let panelHeight = max(360, geometry.size.width)

                        ZStack {
                            Image("RuneMan")
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .foregroundStyle(Color(.systemGray3))
                                .frame(maxWidth: .infinity)

                            hitLocationOverlay(for: character)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: panelHeight)

                        combatHeader(for: character)
                            .padding(.top, 4)

                        weaponsSection(for: character)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
            } else {
                Text("Create a character in Summary to manage combat weapons.")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .sheet(item: $presentedEditor) { editor in
            WeaponEditorView(
                title: editor.title,
                name: editor.name,
                basePercentage: editor.basePercentage,
                experienceCheck: editor.experienceCheck,
                strikeRank: editor.strikeRank,
                damage: editor.damage,
                hpMax: editor.hpMax,
                hpCurrent: editor.hpCurrent,
                enc: editor.enc,
                type: editor.type,
                range: editor.range,
                isEquipped: editor.isEquipped
            ) { name, basePercentage, experienceCheck, strikeRank, damage, hpMax, hpCurrent, enc, type, range, isEquipped in
                if let weapon = editor.weapon {
                    updateWeapon(
                        weapon,
                        name: name,
                        basePercentage: basePercentage,
                        experienceCheck: experienceCheck,
                        damage: damage,
                        hpMax: hpMax,
                        hpCurrent: hpCurrent,
                        enc: enc,
                        strikeRank: strikeRank,
                        type: type,
                        range: range,
                        isEquipped: isEquipped
                    )
                } else if let character {
                    addWeapon(
                        to: character,
                        name: name,
                        basePercentage: basePercentage,
                        experienceCheck: experienceCheck,
                        damage: damage,
                        hpMax: hpMax,
                        hpCurrent: hpCurrent,
                        enc: enc,
                        strikeRank: strikeRank,
                        type: type,
                        range: range,
                        isEquipped: isEquipped
                    )
                }
            }
        }
        .alert("Confirm delete", isPresented: isShowingDeleteAlert) {
            Button("Cancel", role: .cancel) {
                pendingDeleteWeapon = nil
            }
            Button("Yes", role: .destructive) {
                confirmDelete()
            }
        } message: {
            Text("This cannot be undone")
        }
        .mainRuneBackground(runeName: "RuneDeath")
    }

    private func weaponsSection(for character: RQCharacter) -> some View {
        return weaponsList(for: character)
            .overlay(alignment: .top) {
                LinearGradient(
                    colors: [
                        Color(.systemBackground).opacity(0.78),
                        Color(.systemBackground).opacity(0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 28)
                .allowsHitTesting(false)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func combatHeader(for character: RQCharacter) -> some View {
        HStack(alignment: .center, spacing: 12) {
            HitPointsCombatChip(character: character)

            Spacer(minLength: 0)

            CombatHeaderChip(label: "Damage Bonus") {
                Text(character.damageBonusText)
                    .font(.body.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
            }
        }
    }

    private func weaponsList(for character: RQCharacter) -> some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                if character.weapons.isEmpty {
                    Text("No weapons yet")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    ForEach(character.weapons) { weapon in
                        let rowID = ObjectIdentifier(weapon)
                        WeaponSwipeRow(
                            rowID: rowID,
                            activeSwipeID: $swipedWeaponID,
                            onDelete: {
                                pendingDeleteWeapon = weapon
                            }
                        ) {
                            WeaponRowCard(
                                weapon: weapon,
                                isExpanded: isExpanded(weapon),
                                onSelect: {
                                    presentedEditor = .edit(weapon)
                                },
                                onToggleExperience: {
                                    weapon.experienceCheck.toggle()
                                },
                                onToggleExpanded: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        toggleExpanded(weapon)
                                    }
                                },
                                onToggleEquipped: {
                                    weapon.isEquipped.toggle()
                                }
                            )
                        }
                    }
                }

                addWeaponButton
                    .padding(.top, 8)
                    .padding(.bottom, 24)
            }
            .padding(.horizontal, 10)
            .padding(.top, 4)
            .padding(.bottom, 8)
        }
        .accessibilityIdentifier("combat.weaponsList")
        .scrollIndicators(.hidden)
        .background(Color.clear)
    }

    private var addWeaponButton: some View {
        Button("Add weapon") {
            presentedEditor = .add
        }
        .font(.headline)
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(.regularMaterial, in: Capsule())
        .overlay {
            Capsule()
                .stroke(.quaternary, lineWidth: 1)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("combat.addWeapon")
    }

    private func isExpanded(_ weapon: Weapon) -> Bool {
        expandedWeaponIDs.contains(ObjectIdentifier(weapon))
    }

    private func toggleExpanded(_ weapon: Weapon) {
        let id = ObjectIdentifier(weapon)
        if expandedWeaponIDs.contains(id) {
            expandedWeaponIDs.remove(id)
        } else {
            expandedWeaponIDs.insert(id)
        }
    }

    private func weaponTypeText(for weapon: Weapon) -> String {
        weapon.type?.rawValue ?? "-"
    }

    private func weaponHPText(for weapon: Weapon) -> String {
        guard let hpMax = weapon.hpMax, let hpCurrent = weapon.hpCurrent else { return "-" }
        return "\(hpMax)/\(hpCurrent)"
    }

    private func weaponEncText(for weapon: Weapon) -> String {
        guard let enc = weapon.enc else { return "-" }
        return "\(enc)"
    }

    private func weaponStrikeRankText(for weapon: Weapon) -> String {
        return weapon.strikeRank.isEmpty ? "-" : weapon.strikeRank
    }

    private func weaponRangeText(for weapon: Weapon) -> String? {
        let trimmed = weapon.range.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func hitLocationOverlay(for character: RQCharacter) -> some View {
        GeometryReader { geo in
            let locationsByType = Dictionary(uniqueKeysWithValues: character.hitLocations.map { ($0.location, $0) })
            let yOffset: CGFloat = 20
            ZStack {
                hitLocationCard(locationsByType[.head])
                    .position(x: geo.size.width * 0.50, y: (geo.size.height * 0.15) + yOffset)
                hitLocationCard(locationsByType[.chest])
                    .position(x: geo.size.width * 0.50, y: (geo.size.height * 0.40) + yOffset )
                hitLocationCard(locationsByType[.abdomen])
                    .position(x: geo.size.width * 0.50, y: (geo.size.height * 0.65) + yOffset )
                hitLocationCard(locationsByType[.leftArm])
                    .position(x: (geo.size.width * 0.20) , y: (geo.size.height * 0.40) + yOffset )
                hitLocationCard(locationsByType[.rightArm])
                    .position(x: (geo.size.width * 0.80) , y: (geo.size.height * 0.40) + yOffset )
                hitLocationCard(locationsByType[.leftLeg])
                    .position(x: (geo.size.width * 0.25) , y: (geo.size.height * 0.80) + yOffset )
                hitLocationCard(locationsByType[.rightLeg])
                    .position(x: (geo.size.width * 0.75) , y: (geo.size.height * 0.80) + yOffset )
            }
        }
    }

    private func hitLocationCard(_ location: CharacterHitLocation?) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(shortName(for: location?.location))
                .font(.footnote)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .center)

            HStack(spacing: 4) {
                Text("AP")
                    .font(.footnote)
                    .frame(width: 18, alignment: .leading)
                TextField(
                    "",
                    text: Binding<String>(
                        get: { armourText(for: location) },
                        set: { newValue in
                            guard let location else { return }
                            let digits = newValue.filter(\.isNumber)
                            if digits.isEmpty {
                                location.armour = 0
                            } else if let value = Int(digits) {
                                location.armour = value
                            }
                        }
                    )
                )
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .font(.footnote.monospacedDigit())
                .textFieldStyle(.roundedBorder)
                .frame(width: 34)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 2)

            HStack(spacing: 4) {
                Text("HP")
                    .font(.footnote)
                    .frame(width: 18, alignment: .leading)
                TextField(
                    "",
                    text: Binding<String>(
                        get: { currentHPText(for: location) },
                        set: { newValue in
                            guard let location else { return }
                            let digits = newValue.filter(\.isNumber)
                            if digits.isEmpty {
                                location.currentHP = 0
                            } else if let value = Int(digits) {
                                location.currentHP = value
                            }
                        }
                    )
                )
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .font(.footnote.monospacedDigit())
                .textFieldStyle(.roundedBorder)
                .frame(width: 34)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 2)
        }
        .padding(.horizontal, 2)
        .padding(.vertical, 2)
        .frame(width: 85, alignment: .leading)
        .background(Color(.systemBackground).opacity(0.9))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func shortName(for location: HitLocation?) -> String {
        switch location {
        case .head: return "Head"
        case .chest: return "Chest"
        case .abdomen: return "Abd"
        case .leftArm: return "L Arm"
        case .rightArm: return "R Arm"
        case .leftLeg: return "L Leg"
        case .rightLeg: return "R Leg"
        case .none: return "-"
        }
    }

    private func currentHPText(for location: CharacterHitLocation?) -> String {
        guard let location else { return "" }
        return String(location.currentHP)
    }

    private func armourText(for location: CharacterHitLocation?) -> String {
        guard let location else { return "" }
        return String(location.armour)
    }

    private func addWeapon(
        to character: RQCharacter,
        name: String,
        basePercentage: Int,
        experienceCheck: Bool,
        damage: String,
        hpMax: Int?,
        hpCurrent: Int?,
        enc: Int?,
        strikeRank: String,
        type: WeaponType?,
        range: String,
        isEquipped: Bool
    ) {
        let weapon = Weapon(
            character: character,
            name: name,
            basePercentage: basePercentage,
            experienceCheck: experienceCheck,
            damage: damage,
            hpMax: hpMax,
            hpCurrent: hpCurrent,
            enc: enc,
            strikeRank: strikeRank,
            type: type,
            range: range,
            isEquipped: isEquipped
        )
        modelContext.insert(weapon)
        character.weapons.append(weapon)
    }

    private func confirmDelete() {
        guard let pendingDeleteWeapon else { return }
        if isExpanded(pendingDeleteWeapon) {
            expandedWeaponIDs.remove(ObjectIdentifier(pendingDeleteWeapon))
        }
        if swipedWeaponID == ObjectIdentifier(pendingDeleteWeapon) {
            swipedWeaponID = nil
        }
        character?.weapons.removeAll { $0 == pendingDeleteWeapon }
        modelContext.delete(pendingDeleteWeapon)
        self.pendingDeleteWeapon = nil
    }

    private var isShowingDeleteAlert: Binding<Bool> {
        Binding(
            get: { pendingDeleteWeapon != nil },
            set: { isPresented in
                if isPresented == false {
                    pendingDeleteWeapon = nil
                }
            }
        )
    }

    private func updateWeapon(
        _ weapon: Weapon,
        name: String,
        basePercentage: Int,
        experienceCheck: Bool,
        damage: String,
        hpMax: Int?,
        hpCurrent: Int?,
        enc: Int?,
        strikeRank: String,
        type: WeaponType?,
        range: String,
        isEquipped: Bool
    ) {
        weapon.name = name
        weapon.basePercentage = basePercentage
        weapon.experienceCheck = experienceCheck
        weapon.damage = damage
        weapon.hpMax = hpMax
        weapon.hpCurrent = hpCurrent
        weapon.enc = enc
        weapon.strikeRank = strikeRank
        weapon.type = type
        weapon.range = range
        weapon.isEquipped = isEquipped
    }
}

private struct WeaponRowCard: View {
    private let weaponDetailRowHeight: CGFloat = 34
    private let weaponDetailVerticalSpacing: CGFloat = 8
    private let weaponDetailDividerHeight: CGFloat = 17
    private let weaponDetailTopPadding: CGFloat = 16
    private let weaponDetailBottomPadding: CGFloat = 8

    let weapon: Weapon
    let isExpanded: Bool
    let onSelect: () -> Void
    let onToggleExperience: () -> Void
    let onToggleExpanded: () -> Void
    let onToggleEquipped: () -> Void

    @State private var detailOpacity: Double = 0
    @State private var detailFadeTask: Task<Void, Never>?

    private var displayName: String {
        let trimmed = weapon.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Weapon" : trimmed
    }

    private var displayStrikeRank: String {
        let trimmed = weapon.strikeRank.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "-" : trimmed
    }

    private var displayHP: String {
        guard let hpMax = weapon.hpMax, let hpCurrent = weapon.hpCurrent else { return "-" }
        return "\(hpCurrent)/\(hpMax)"
    }

    private var displayENC: String {
        guard let enc = weapon.enc else { return "-" }
        return "\(enc)"
    }

    private var displayType: String {
        weapon.type?.rawValue.capitalized ?? "-"
    }

    private var displayRange: String? {
        let trimmed = weapon.range.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private var expandedDetailHeight: CGFloat {
        weaponDetailTopPadding
        + weaponDetailDividerHeight
        + weaponDetailRowHeight
        + weaponDetailVerticalSpacing
        + weaponDetailRowHeight
        + weaponDetailBottomPadding
    }

    private var detailContent: some View {
        VStack(alignment: .leading, spacing: weaponDetailVerticalSpacing) {
            Divider()
                .padding(.vertical, 8)

            detailPrimaryRow
            detailSecondaryRow
        }
    }

    private var detailPrimaryRow: some View {
        HStack(spacing: 12) {
            WeaponDetailSlot(label: "HP", value: displayHP)
            WeaponDetailSlot(label: "ENC", value: displayENC)
            WeaponDetailSlot(label: "Type", value: displayType)
        }
        .frame(height: weaponDetailRowHeight)
    }

    private var detailSecondaryRow: some View {
        HStack(spacing: 12) {
            Button(action: onToggleEquipped) {
                WeaponDetailSlot(label: "Equipped", value: weapon.isEquipped ? "Yes" : "No")
            }
            .buttonStyle(.plain)

            WeaponDetailSlot(label: "", value: "", isVisible: false)
            WeaponDetailSlot(label: "Range", value: displayRange ?? "", isVisible: displayRange != nil)
        }
        .frame(height: weaponDetailRowHeight)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 5) {
                Text(displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("\(weapon.basePercentage)%")
                    .font(.subheadline)
                    .monospacedDigit()
                    .frame(width: 38, alignment: .trailing)

                Button(action: onToggleExperience) {
                    Image(systemName: weapon.experienceCheck ? "checkmark.square.fill" : "square")
                        .font(.body)
                        .foregroundStyle(weapon.experienceCheck ? .primary : .secondary)
                }
                .buttonStyle(.plain)
                .frame(width: 24, alignment: .center)

                HStack(spacing: 2) {
                    Text("SR")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(displayStrikeRank)
                        .font(.subheadline)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .frame(width: 56, alignment: .leading)

                Text(weapon.damage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .frame(width: 54, alignment: .trailing)

                Button(action: onToggleExpanded) {
                    DisclosureTriangle(isFilled: isExpanded)
                        .frame(width: 22, height: 22)
                }
                .buttonStyle(.plain)
            }
            .contentShape(Rectangle())
            .onTapGesture(perform: onSelect)

            detailContent
                .opacity(detailOpacity)
                .frame(height: isExpanded ? expandedDetailHeight : 0, alignment: .top)
                .clipped()
        }
        .padding(10)
        .onAppear {
            detailOpacity = isExpanded ? 1 : 0
        }
        .onDisappear {
            detailFadeTask?.cancel()
        }
        .onChange(of: isExpanded) { _, expanded in
            detailFadeTask?.cancel()

            if expanded {
                scheduleDetailFadeIn()
            } else {
                withAnimation(.easeOut(duration: 0.08)) {
                    detailOpacity = 0
                }
            }
        }
        .background(Color(.systemBackground).opacity(0.52), in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.quaternary, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("combat.weaponRow.\(displayName)")
    }

    private func scheduleDetailFadeIn() {
        detailOpacity = 0
        detailFadeTask?.cancel()
        detailFadeTask = Task {
            try? await Task.sleep(for: .milliseconds(140))
            guard Task.isCancelled == false else { return }
            await MainActor.run {
                withAnimation(.easeIn(duration: 0.12)) {
                    detailOpacity = 1
                }
            }
        }
    }
}

private struct DisclosureTriangle: View {
    let isFilled: Bool

    var body: some View {
        TriangleShape()
            .rotation(.degrees(180))
            .fill(isFilled ? Color.secondary : Color.clear)
            .overlay {
                TriangleShape()
                    .rotation(.degrees(180))
                    .stroke(Color.secondary, lineWidth: 1.6)
            }
            .padding(4)
    }
}

private struct CombatHeaderChip: View {
    let label: String
    let content: AnyView

    init(label: String, @ViewBuilder content: () -> some View) {
        self.label = label
        self.content = AnyView(content())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.footnote)
                .foregroundStyle(.secondary)

            content
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemBackground).opacity(0.58), in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.quaternary, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct HitPointsCombatChip: View {
    let character: RQCharacter
    @State private var currentHitpointsText: String = ""

    var body: some View {
        CombatHeaderChip(label: "HP") {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                TextField("", text: $currentHitpointsText)
                    .font(.body.weight(.semibold))
                    .monospacedDigit()
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
                    .frame(minWidth: 28)
                    .onChange(of: currentHitpointsText) { _, newValue in
                        applyHitPointInput(newValue)
                    }

                Text("/\(character.maxHitpoints)")
                    .font(.body.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
            }
        }
        .onAppear {
            syncCurrentHitpointsText()
        }
        .onChange(of: character.currentHitpoints) { _, _ in
            syncCurrentHitpointsText()
        }
        .onChange(of: character.maxHitpoints) { _, _ in
            syncCurrentHitpointsText()
        }
    }

    private func applyHitPointInput(_ input: String) {
        let digits = input.filter(\.isNumber)
        if digits != input {
            currentHitpointsText = digits
            return
        }

        guard let value = Int(digits) else { return }
        character.currentHitpoints = value
        syncCurrentHitpointsText()
    }

    private func syncCurrentHitpointsText() {
        let clamped = String(character.currentHitpoints)
        if currentHitpointsText != clamped {
            currentHitpointsText = clamped
        }
    }
}

private struct WeaponSwipeRow<Content: View>: View {
    private let deleteWidth: CGFloat = 92
    private let overswipeLimit: CGFloat = 20
    private let deleteTrailingPadding: CGFloat = 8

    let rowID: ObjectIdentifier
    @Binding var activeSwipeID: ObjectIdentifier?
    let onDelete: () -> Void
    @ViewBuilder let content: () -> Content

    @State private var offset: CGFloat = 0
    @State private var dragStartOffset: CGFloat = 0
    @State private var isHandlingHorizontalDrag = false

    private var revealWidth: CGFloat {
        deleteWidth + deleteTrailingPadding
    }

    private var deleteProgress: CGFloat {
        min(1, max(0, -offset / revealWidth))
    }

    private var deleteOverswipeOffset: CGFloat {
        min(0, offset + revealWidth)
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
                    .font(.subheadline.weight(.semibold))
                    .frame(width: deleteWidth)
                    .frame(height: 36)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .background(.red.opacity(0.92), in: Capsule())
            .scaleEffect(0.78 + (0.22 * deleteProgress))
            .opacity(deleteProgress == 0 ? 0 : 0.5 + (0.5 * deleteProgress))
            .offset(x: deleteOverswipeOffset)
            .padding(.trailing, deleteTrailingPadding)
            .allowsHitTesting(deleteProgress > 0.95)

            content()
                .offset(x: offset)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 12, coordinateSpace: .local)
                        .onChanged { value in
                            guard isHandlingHorizontalDrag || SwipeDirectionLock.isHorizontalSwipe(value.translation) else {
                                return
                            }

                            if isHandlingHorizontalDrag == false {
                                isHandlingHorizontalDrag = true
                                handleSwipeBegan()
                            }

                            handleSwipeChanged(value.translation.width)
                        }
                        .onEnded { value in
                            defer { isHandlingHorizontalDrag = false }
                            guard isHandlingHorizontalDrag else { return }
                            handleSwipeEnded(value.translation.width)
                        }
                )
        }
        .clipped()
        .onChange(of: activeSwipeID) { _, newValue in
            if newValue != rowID {
                withAnimation(.spring(response: 0.24, dampingFraction: 0.82)) {
                    offset = 0
                }
            }
        }
    }

    private func handleSwipeBegan() {
        dragStartOffset = activeSwipeID == rowID ? offset : 0
        if activeSwipeID != rowID {
            activeSwipeID = rowID
        }
    }

    private func handleSwipeChanged(_ translation: CGFloat) {
        let proposed = dragStartOffset + translation
        if proposed <= 0 {
            offset = max(-(revealWidth + overswipeLimit), proposed)
        } else {
            offset = min(0, proposed)
        }
    }

    private func handleSwipeEnded(_ translation: CGFloat) {
        let finalOffset = dragStartOffset + translation

        withAnimation(.spring(response: 0.24, dampingFraction: 0.82)) {
            if finalOffset <= -(revealWidth * 0.5) {
                offset = -revealWidth
                activeSwipeID = rowID
            } else {
                offset = 0
                if activeSwipeID == rowID {
                    activeSwipeID = nil
                }
            }
        }
    }
}

enum SwipeDirectionLock {
    static func isHorizontalSwipe(_ translation: CGSize) -> Bool {
        abs(translation.width) > (abs(translation.height) * 1.2)
    }

    static func isHorizontalSwipe(_ translation: CGPoint) -> Bool {
        abs(translation.x) > (abs(translation.y) * 1.2)
    }
}

private struct WeaponDetailSlot: View {
    let label: String
    let value: String
    var isVisible = true

    var body: some View {
        Group {
            if isVisible {
                HStack(spacing: 4) {
                    Text("\(label):")
                        .foregroundStyle(.secondary)
                    Text(value)
                        .foregroundStyle(.primary)
                        .monospacedDigit()
                }
                .font(.subheadline)
            } else {
                Color.clear
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct WeaponEditorSheet: Identifiable {
    let id: UUID
    let weapon: Weapon?
    let title: String
    let name: String
    let basePercentage: Int
    let experienceCheck: Bool
    let strikeRank: String
    let damage: String
    let hpMax: Int?
    let hpCurrent: Int?
    let enc: Int?
    let type: WeaponType?
    let range: String
    let isEquipped: Bool

    static var add: WeaponEditorSheet {
        WeaponEditorSheet(
            id: UUID(),
            weapon: nil,
            title: "Add Weapon",
            name: "",
            basePercentage: 0,
            experienceCheck: false,
            strikeRank: "",
            damage: "",
            hpMax: nil,
            hpCurrent: nil,
            enc: nil,
            type: nil,
            range: "",
            isEquipped: false
        )
    }

    static func edit(_ weapon: Weapon) -> WeaponEditorSheet {
        WeaponEditorSheet(
            id: UUID(),
            weapon: weapon,
            title: "Edit Weapon",
            name: weapon.name,
            basePercentage: weapon.basePercentage,
            experienceCheck: weapon.experienceCheck,
            strikeRank: weapon.strikeRank,
            damage: weapon.damage,
            hpMax: weapon.hpMax,
            hpCurrent: weapon.hpCurrent,
            enc: weapon.enc,
            type: weapon.type,
            range: weapon.range,
            isEquipped: weapon.isEquipped
        )
    }
}
