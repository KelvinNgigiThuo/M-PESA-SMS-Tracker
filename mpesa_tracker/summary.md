# Dhahiri — v2 Progress Summary

## Committed baseline (through `dafe9fc`, "Dhahiri 7")

The account system is fully database-backed:

- CRUD for accounts (create, update, delete) via Drift.
- Overlay bucket pickers read accounts from the DB instead of a hardcoded list.
- `Categories` table already exists in `app_database.dart` (`direction`, `isSystem`,
  `isActive`, seeded defaults) with `getCategories`, `addCategory`, `renameCategory`,
  `deactivateCategory` helpers — added alongside the account schema work, but not
  yet wired into any UI at that point.

## Uncommitted work in progress

Wiring the existing Categories infrastructure into the UI, mirroring what was just
done for accounts:

1. **Overlay tag card** (`lib/overlay/tag_card*.dart`)
   - Expense picker and the new "true income" sub-flow (`income_type` screen) now
     pull chips from `db.getCategories('out'/'in')` instead of a hardcoded
     `['Food', 'Transport', ...]` list.
   - Selecting "Other" (expense) or "Other"/"Family Support" (income) reveals an
     optional note field; the note gets appended into the saved `category` string.

2. **New screen: `lib/screens/categories_settings_screen.dart`** (untracked)
   - Shared CRUD screen for both expense categories and income types, driven by a
     `direction` param.
   - Rename works on any category; delete/deactivate is restricted to custom
     (non-system) categories.

3. **`lib/screens/settings_screen.dart`**
   - Added an "Accounts" section.
   - Rewired "Expense categories" / "Income types" rows to open the new
     `CategoriesSettingsScreen`.

4. **`lib/screens/dashboard_screen.dart`**
   - M-Pesa account balance is now special-cased in the zone totals: it always
     reads the live SMS-derived balance (`mpesaBalance`) instead of
     `manualBalance ?? opening + bucket movements`.

## Current blocker — build is broken

`errors.txt` (from a failed `flutter run`) shows:

```
lib/screens/settings_screen.dart:112:47: Error: Not a constant expression.
    builder: (_) => const AccountsSettingsScreen()),
```

`settings_screen.dart:112` references `AccountsSettingsScreen`, which does not
exist and is not imported. The real class is `AccountsScreen` in
`lib/screens/accounts_screen.dart` (present since Dhahiri 6/7); its import is
missing from `settings_screen.dart` entirely.

That "Manage accounts" row is also still flagged `comingSoon: true`, which
disables the tap handler — so even after fixing the class reference, the flag
needs to be removed too for the row to actually navigate.

**Fix needed:**
- Import `accounts_screen.dart` in `settings_screen.dart`.
- Change `const AccountsSettingsScreen()` → `const AccountsScreen()` (drop `const`
  if `AccountsScreen`'s constructor isn't const).
- Remove `comingSoon: true` from that row.
