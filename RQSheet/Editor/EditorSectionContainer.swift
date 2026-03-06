import SwiftUI

struct EditorSectionContainer<Content: View>: View {
    let title: String
    let isExpanded: Bool
    let onToggle: () -> Void
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                onToggle()
            } label: {
                HStack(alignment: .center, spacing: 8) {
                    Text(title)
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(title) section")
            .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")

            if isExpanded {
                content
            }
        }
        .padding(14)
        .background(.regularMaterial, in: .rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.quaternary, lineWidth: 1)
        }
        .clipShape(.rect(cornerRadius: 12))
    }
}
