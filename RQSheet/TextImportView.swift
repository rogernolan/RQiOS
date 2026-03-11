import SwiftUI
import SwiftData

struct TextImportView: View {
    @Environment(\.modelContext) private var modelContext

    let character: RQCharacter
    let onOpenCharacter: (RQCharacter) -> Void

    @State private var rawText = ""
    @State private var importResult: TextImportResult?
    @State private var importError: String?
    @State private var editableName = ""
    @State private var isShowingNamePrompt = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextEditor(text: $rawText)
                .frame(height: 220)
                .padding(10)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(.quaternary, lineWidth: 1)
                }

            if let importError {
                Text(importError)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            Button("Import") {
                runImport()
            }
            .buttonStyle(.borderedProminent)
            .disabled(rawText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            if let importResult {
                importReview(result: importResult)
            }
        }
        .alert("Character Name", isPresented: $isShowingNamePrompt) {
            TextField("Name", text: $editableName)
            Button("Save") {
                saveImportedCharacter(nameOverride: editableName)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Review or edit the imported name before saving.")
        }
    }

    @ViewBuilder
    private func importReview(result: TextImportResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Import Review")
                .font(.headline)

            VStack(spacing: 10) {
                ForEach(result.review(), id: \.section) { review in
                    HStack(spacing: 10) {
                        Circle()
                            .fill(color(for: review.status))
                            .frame(width: 10, height: 10)

                        Text(review.section.rawValue)
                            .font(.subheadline.weight(.semibold))

                        Spacer()

                        Text(review.detail)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

            HStack(spacing: 12) {
                Button("Cancel") {
                    self.importResult = nil
                    importError = nil
                }
                .buttonStyle(.bordered)

                Button("Save") {
                    beginSave(for: result)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private func runImport() {
        do {
            importResult = try TextImportPipeline.parse(rawText)
            importError = nil
        } catch {
            importResult = nil
            importError = "Import failed. Check the pasted text and try again."
        }
    }

    private func beginSave(for result: TextImportResult) {
        let parsedName = result.characterInfo.candidateName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if parsedName.isEmpty == false {
            editableName = parsedName
            isShowingNamePrompt = true
        } else {
            saveImportedCharacter(nameOverride: nil)
        }
    }

    private func saveImportedCharacter(nameOverride: String?) {
        guard let importResult else { return }

        do {
            let importedCharacter = try TextImportApplier.apply(result: importResult, nameOverride: nameOverride, in: modelContext)
            onOpenCharacter(importedCharacter)
            self.importResult = nil
            importError = nil
            rawText = ""
        } catch {
            importError = "Save failed. The imported character was not created."
        }
    }

    private func color(for status: TextImportSectionStatus) -> Color {
        switch status {
        case .green:
            return .green
        case .yellow:
            return .yellow
        case .red:
            return .red
        }
    }
}
