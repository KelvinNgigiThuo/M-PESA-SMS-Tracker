# CLAUDE.md

## Project

"Dhahiri" — Flutter/Kotlin Android app that intercepts M-PESA SMS, parses them natively, and shows a draggable overlay bubble for transaction tagging.

- Package: `com.kelvin.mpesa.mpesa_tracker` | pubspec name: `dhahiri`
- Repo dir is `mpesa_tracker/` (pre-rebrand). Run all commands from `mpesa_tracker/`

## Critical constraints

- `MpesaParser.kt` is core — changes to SMS parsing logic require careful regex testing
- v1 parsing behavior must not regress; v2 adds features on top
- Never hand-edit `app_database.g.dart` — run build_runner after any schema change
- `test/widget_test.dart` is broken boilerplate (references `MyApp`, not `DhahiriApp`) — ignore it
- No iOS target, no CI

## Commands

```bash
flutter pub get
flutter analyze
flutter run -d <device-id>
dart run build_runner build --delete-conflicting-outputs  # after schema changes
flutter build apk
```

## Architecture (summary)

Two cooperating halves:

1. **Native (Kotlin):** `SmsReceiver` → `MpesaParser` → `OverlayService` → `TagCardActivity` (separate Flutter engine via `tagCardMain` entrypoint, `com.kelvin.mpesa/overlay` MethodChannel)
2. **Flutter:** Main app (`DhahiriApp`) with 4-tab shell. Overlay side (`tagCardMain`) is a separate minimal entrypoint.

Database: Drift/SQLite — 3 tables: `Transactions`, `Accounts`, `Categories`. DB file: `ApplicationDocumentsDirectory/dhahiri.sqlite`

Setup gate: `SetupService` (shared_preferences) + `AppDatabase.hasCompletedSetup()` — keep these in sync.
