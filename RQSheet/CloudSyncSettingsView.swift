import CloudKit
import SwiftUI

struct CloudSyncSettingsView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var status: CloudSyncStatus
    @State private var shareSnapshot: ShareSnapshot?
    @State private var exportFailed = false
    private let diagnostics: SyncDiagnostics

    init(diagnostics: SyncDiagnostics? = nil) {
        let isPreviewOrTest = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
            || ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        let recorder = diagnostics ?? (isPreviewOrTest ? SyncDiagnostics.none : .shared)
        self.diagnostics = recorder
        _status = State(initialValue: CloudSyncStatus(diagnostics: recorder))
    }

    private struct ShareSnapshot: Identifiable {
        let id = UUID()
        let report: String
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("iCloud Sync").font(.headline)
            Text(status.availability.message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Check iCloud Availability") {
                Task { await status.refresh() }
            }
            .disabled(status.isRefreshing)
            Button("Share Sync Diagnostics") {
                do { shareSnapshot = ShareSnapshot(report: try SyncDiagnosticsSharePreparation(diagnostics: diagnostics).prepare()) }
                catch { exportFailed = true }
            }
            Text("Use the same Apple Account on your iPhone and iPad. You can edit offline; changes sync when iCloud is available. Characters with the same name remain separate records. Deleting a character also deletes it from your synced devices.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .sheet(item: $shareSnapshot) { snapshot in SyncDiagnosticsSharingView(report: snapshot.report) }
        .alert("Unable to Prepare Diagnostics", isPresented: $exportFailed) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your characters are unaffected. Please try sharing diagnostics again.")
        }
        .task { await status.refresh(reason: .appearance) }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { Task { await status.refresh(reason: .foreground) } }
        }
        .onReceive(NotificationCenter.default.publisher(for: .CKAccountChanged)) { _ in
            Task { await status.refresh(reason: .accountChange) }
        }
    }
}
