import CloudKit
import SwiftUI

struct CloudSyncSettingsView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var status = CloudSyncStatus()

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
            Text("Use the same Apple Account on your iPhone and iPad. You can edit offline; changes sync when iCloud is available. Characters with the same name remain separate records. Deleting a character also deletes it from your synced devices.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .task { await status.refresh() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { Task { await status.refresh() } }
        }
        .onReceive(NotificationCenter.default.publisher(for: .CKAccountChanged)) { _ in
            Task { await status.refresh() }
        }
    }
}
