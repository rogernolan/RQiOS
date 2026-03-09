import SwiftUI
import UIKit

struct SummaryPortraitView: View {
    let portraitData: Data?
    var width: CGFloat = 96
    var height: CGFloat = 96
    var cornerRadius: CGFloat = 48
    var fallbackPadding: CGFloat = 18

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
                    .padding(fallbackPadding)
                    .background(.secondary.opacity(0.08))
            }
        }
        .frame(width: width, height: height)
        .background(.secondary.opacity(0.06))
        .clipShape(.rect(cornerRadius: cornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(.quaternary, lineWidth: 1)
        }
        .accessibilityLabel("Character portrait")
    }

    private var portraitImage: UIImage? {
        guard let portraitData else { return nil }
        return UIImage(data: portraitData)
    }
}
