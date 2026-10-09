import SwiftUI
import UIKit

nonisolated struct SyncDiagnosticsSharePreparation {
    private let diagnostics: SyncDiagnostics
    private let report: () throws -> String
    init(diagnostics: SyncDiagnostics = .shared, report: (() throws -> String)? = nil) {
        self.diagnostics = diagnostics
        self.report = report ?? { try diagnostics.freshShareReport() }
    }
    func prepare() throws -> String {
        do {
            let snapshot = try report()
            diagnostics.record(.reportPreparation, stage: .completed, success: true)
            return snapshot
        } catch {
            diagnostics.record(.reportPreparation, stage: .completed, success: false, error: error)
            throw error
        }
    }
}

/// A fresh snapshot is supplied only after the user requests sharing.
struct SyncDiagnosticsSharingView: UIViewControllerRepresentable {
    let report: String
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: [report], applicationActivities: nil)
        // Anchor the native presentation when UIKit uses an iPad popover.
        if let popover = controller.popoverPresentationController {
            popover.sourceView = controller.view
            popover.sourceRect = CGRect(x: controller.view.bounds.midX, y: controller.view.bounds.midY, width: 1, height: 1)
            popover.permittedArrowDirections = []
        }
        return controller
    }
    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
