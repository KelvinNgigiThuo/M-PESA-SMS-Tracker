import 'package:flutter/material.dart';

const _green = Color(0xFF1A3C34);
const _gold = Color(0xFFC9A84C);

/// Shared Out/In pill toggle, used on both the Dashboard ("This month")
/// and the Ledger header.
Widget buildDirectionToggle({
  required String value,
  required ValueChanged<String> onChanged,
}) {
  return Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: _green.withOpacity(0.06),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _segment('Out', 'out', value, onChanged),
        _segment('In', 'in', value, onChanged),
      ],
    ),
  );
}

Widget _segment(
    String label, String segValue, String value, ValueChanged<String> onChanged) {
  final selected = value == segValue;
  return GestureDetector(
    onTap: () => onChanged(segValue),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: selected ? _green : Colors.transparent,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? _gold : Colors.grey[500],
        ),
      ),
    ),
  );
}
