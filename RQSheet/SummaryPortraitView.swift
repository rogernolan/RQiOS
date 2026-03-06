import SwiftUI
import UIKit

struct SummaryPortraitView: View {
    let portraitData: Data?

    var body: some View {
        Group {
            if let portraitImage {
                Image(uiImage: portraitImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Image("RuneMan")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .foregroundStyle(.secondary)
                    .saturation(0)
                    .padding(18)
                    .background(.secondary.opacity(0.08))
            }
        }
        .frame(width: 96, height: 96)
        .background(.secondary.opacity(0.06))
        .clipShape(.circle)
        .overlay {
            Circle()
                .stroke(.quaternary, lineWidth: 1)
        }
        .accessibilityLabel("Character portrait")
    }

    private var portraitImage: UIImage? {
        guard let portraitData else { return nil }
        return UIImage(data: portraitData)
    }
}
