import SwiftUI

struct SummaryCard<Content: View, HeaderAction: View>: View {
    let title: String?
    let showsHeaderAction: Bool
    @ViewBuilder var headerAction: HeaderAction
    @ViewBuilder var content: Content

    init(
        title: String,
        @ViewBuilder headerAction: () -> HeaderAction,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.showsHeaderAction = true
        self.headerAction = headerAction()
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if title != nil || showsHeaderAction {
                HStack(alignment: .center, spacing: 8) {
                    if let title {
                        Text(title)
                            .font(.headline)
                            .bold()
                    }
                    Spacer()
                    if showsHeaderAction {
                        headerAction
                    }
                }
            }

            content
        }
        .padding(14)
        .background(Color(.systemBackground).opacity(0.52), in: .rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.quaternary, lineWidth: 1)
        }
        .clipShape(.rect(cornerRadius: 12))
    }
}

extension SummaryCard where HeaderAction == EmptyView {
    init(
        title: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.showsHeaderAction = false
        self.headerAction = EmptyView()
        self.content = content()
    }

    init(
        @ViewBuilder content: () -> Content
    ) {
        self.title = nil
        self.showsHeaderAction = false
        self.headerAction = EmptyView()
        self.content = content()
    }
}
