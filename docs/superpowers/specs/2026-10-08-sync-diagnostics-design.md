# Sync diagnostics

Status: approved scope, 8 October 2026. Rog requested the logging outlined in chat with “add those.” Routine storage and UI choices below implement that scope.

Record startup, recovery-copy preparation, schema recognition, local migration, graph verification and final container opening. Record iCloud account checks/changes and CloudKit setup/import/export start and completion, success, timing and errors. Start the CloudKit event observer before persistence bootstrap and retain it for the app lifetime, including when Settings is closed. SwiftData continues to own syncing; diagnostics must not retry, reset or change records.

Use Apple's unified Logger under subsystem com.diffeng.RQSheet and categories persistence, cloud and diagnostics. Also keep a local history of at most 200 events and 256 KiB, persisted atomically in a separate diagnostics directory so it survives relaunch. Evict oldest events. A damaged or unwritable diagnostics file must not block opening characters: keep the current session in memory and emit a system-log error. Keep logs local until the user shares them.

Use fixed event names and typed/allowlisted fields: timestamp, random launch/event identifiers, stage, success, durations, schema version, record counts when useful, configured container, app version/build, OS version and build configuration. Do not claim a runtime CloudKit environment that was not observed. Include safe error domain/category and numeric code, bounded underlying/partial error codes and finite retry-after seconds. Never include localized error descriptions, arbitrary userInfo, partial-error dictionary keys, account identifiers, paths, record IDs, character names, notes, portraits, imported text, tokens or credentials.

Settings provides Share Sync Diagnostics using the native iOS share UI with a fresh plain-text report generated when requested. The report includes metadata, current session identity, recent allowed events and a reminder that event success/account availability is not proof that every record has converged. Report preparation errors are visible and logged safely. Do not collect or export the system's entire log archive.

Alternatives considered: unified logs alone require tethered collection and miss history after relaunch; a remote telemetry service adds an account/backend and external upload. The local bounded history plus unified logs supports offline phone/iPad testing with no additional service.

Verify retention and restart, corruption/write failure tolerance, concurrency, error/partial-error privacy and retry-after capture, fresh export, account error/overlapping refresh diagnostics and bootstrap success/failure ordering with isolated temporary stores. Observe a deliberate CloudKit event/probe where available and state the real-device boundary. Run focused tests, broader unit regression and a signed generic device build. No device installation or schema promotion is included.

Sources: [Apple sync debugging](https://developer.apple.com/documentation/technotes/tn3164-debugging-the-synchronization-of-nspersistentcloudkitcontainer), [CloudKit container events](https://developer.apple.com/documentation/coredata/nspersistentcloudkitcontainer/event), [Logger](https://developer.apple.com/documentation/os/logger).
