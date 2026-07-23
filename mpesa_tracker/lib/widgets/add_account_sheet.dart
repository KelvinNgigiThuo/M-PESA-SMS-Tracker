import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../main.dart';

const _green = Color(0xFF1A3C34);
const _gold = Color(0xFFC9A84C);

const zoneInfo = {
  1: {'label': 'Operating', 'subtitle': 'Available right now', 'icon': Icons.bolt_outlined},
  2: {'label': 'Reserves', 'subtitle': 'Accessible same-day', 'icon': Icons.shield_outlined},
  3: {'label': 'Committed', 'subtitle': 'Locked or tied up', 'icon': Icons.lock_outline},
  4: {'label': 'Invested', 'subtitle': 'Long-term growth', 'icon': Icons.trending_up},
};

/// Shared "add new account" bottom sheet, used by both the Accounts
/// settings screen and first-run setup.
void showAddAccountSheet(BuildContext context, {required VoidCallback onAdded}) {
  final nameController = TextEditingController();
  int selectedZone = 1;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => StatefulBuilder(
      builder: (context, setModalState) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 3,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Add new account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Account name',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  hintText: 'e.g. CIC Money Market',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: _gold)),
                ),
              ),
              const SizedBox(height: 16),
              Text('Which zone?', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: zoneInfo.entries.map((e) {
                  final selected = selectedZone == e.key;
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedZone = e.key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? _gold.withOpacity(0.15) : Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: selected ? _gold.withOpacity(0.6) : Colors.white.withOpacity(0.15),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        e.value['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: selected ? _gold : Colors.white.withOpacity(0.7),
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;
                  await db.addCustomAccount(name, 'custom', selectedZone);
                  Navigator.pop(context);
                  onAdded();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(12)),
                  child: Text('Add account',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _green, fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Opens a picker for moving [account] to a different zone.
void showZonePicker(BuildContext context, Account account, {required void Function(int zone) onSelected}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 3,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text('Move "${account.name}" to which zone?',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: zoneInfo.entries.map((e) {
              final selected = account.zone == e.key;
              return GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  onSelected(e.key);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? _gold.withOpacity(0.15) : Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: selected ? _gold.withOpacity(0.6) : Colors.white.withOpacity(0.15),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    e.value['label'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: selected ? _gold : Colors.white.withOpacity(0.7),
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ),
  );
}
