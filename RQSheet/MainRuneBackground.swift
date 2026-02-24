//
//  MainRuneBackground.swift
//  RQSheet
//

import SwiftUI

private struct MainRuneBackgroundView: View {
    let runeName: String
    let fixedRotation: Double?

    @State private var rotation = Double.random(in: -25...25)
    @State private var verticalFactor = Double.random(in: -0.25...0.25)

    var body: some View {
        GeometryReader { geometry in
            let size = max(geometry.size.width, geometry.size.height) * 0.85
            let yOffset = geometry.size.height * verticalFactor

            Image(runeName)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .foregroundStyle(Color(red: 0.78, green: 0.73, blue: 0.64).opacity(0.18))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(fixedRotation ?? rotation))
                .position(
                    x: geometry.size.width / 2,
                    y: (geometry.size.height / 2) + yOffset
                )
                .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }
}

private struct MainRuneBackgroundModifier: ViewModifier {
    let runeName: String
    let fixedRotation: Double?

    func body(content: Content) -> some View {
        ZStack {
            MainRuneBackgroundView(runeName: runeName, fixedRotation: fixedRotation)
            content
        }
    }
}

extension View {
    func mainRuneBackground(runeName: String, fixedRotation: Double? = nil) -> some View {
        modifier(MainRuneBackgroundModifier(runeName: runeName, fixedRotation: fixedRotation))
    }
}
