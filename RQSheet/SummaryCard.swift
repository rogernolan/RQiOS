import SwiftUI

struct SummaryCard<Content: View, HeaderAction: View>: View {
    let title: String
    @ViewBuilder var headerAction: HeaderAction
    @ViewBuilder var content: Content

    init(
        title: String,
        @ViewBuilder headerAction: () -> HeaderAction,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.headerAction = headerAction()
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .bold()
                Spacer()
                headerAction
            }

            content
        }
        .padding(14)
        .background(.thinMaterial, in: .rect(cornerRadius: 12))
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
        self.init(title: title, headerAction: { EmptyView() }, content: content)
    }
}
