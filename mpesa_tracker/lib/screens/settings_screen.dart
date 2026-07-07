import 'package:flutter/material.dart';

const _green = Color(0xFF1A3C34);
const _gold = Color(0xFFC9A84C);

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: _green,
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'M-PESA TRACKER',
                    style: TextStyle(
                      fontSize: 9,
                      color: _gold.withOpacity(0.6),
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: _gold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _sectionTitle('App'),
                _settingRow(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Opening balances',
                  subtitle: 'Update your account starting balances',
                  onTap: () {},
                ),
                _settingRow(
                  icon: Icons.category_outlined,
                  label: 'Categories',
                  subtitle: 'Manage expense categories',
                  onTap: () {},
                  comingSoon: true,
                ),
                _settingRow(
                  icon: Icons.label_outline,
                  label: 'Tags',
                  subtitle: 'Customise your tagging options',
                  onTap: () {},
                  comingSoon: true,
                ),
                const SizedBox(height: 8),
                _sectionTitle('Data'),
                _settingRow(
                  icon: Icons.download_outlined,
                  label: 'Export',
                  subtitle: 'Export transactions to CSV',
                  onTap: () {},
                  comingSoon: true,
                ),
                _settingRow(
                  icon: Icons.delete_outline,
                  label: 'Clear all data',
                  subtitle: 'Reset the app to a clean state',
                  onTap: () {},
                  isDestructive: true,
                ),
                const SizedBox(height: 8),
                _sectionTitle('About'),
                _settingRow(
                  icon: Icons.info_outline,
                  label: 'Version',
                  subtitle: 'v1.0.0 — M-Pesa Tracker',
                  onTap: () {},
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.grey[400],
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _settingRow({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    bool comingSoon = false,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red[400]! : _green;

    return GestureDetector(
      onTap: comingSoon ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withOpacity(0.08)
                    : _green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 17, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDestructive
                              ? Colors.red[400]
                              : Colors.black87)),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey[400])),
                ],
              ),
            ),
            if (comingSoon)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: _gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Soon',
                    style: TextStyle(
                        fontSize: 9,
                        color: _gold,
                        fontWeight: FontWeight.w600)),
              )
            else
              Icon(Icons.chevron_right,
                  color: Colors.grey[300], size: 16),
          ],
        ),
      ),
    );
  }
}