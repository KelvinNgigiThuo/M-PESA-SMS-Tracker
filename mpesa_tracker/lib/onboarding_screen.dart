import 'package:flutter/material.dart';

const _green = Color(0xFF1A3C34);
const _gold = Color(0xFFC9A84C);

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToSetup() {
    Navigator.of(context).pushReplacementNamed('/setup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _green,
      body: Stack(
        children: [
          // ── Page view ────────────────────────────────────────
          PageView(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            children: [
              _buildScreen1(),
              _buildScreen2(),
              _buildScreen3(),
            ],
          ),
          // ── Progress dots ────────────────────────────────────
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? _gold
                        : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ── Screen 1 — Brand ────────────────────────────────────────
  Widget _buildScreen1() {
    return GestureDetector(
      onTap: _next,
      child: Container(
        color: _green,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo mark
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _gold, width: 1.5),
              ),
              child: const Center(
                child: Text(
                  'D',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: _gold,
                    letterSpacing: -1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Dhahiri',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: _gold,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Financial clarity.\nMoney in motion.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.45),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 80),
            // Tap hint
            Text(
              'tap to continue',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.2),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Screen 2 — Concept ──────────────────────────────────────
  Widget _buildScreen2() {
    return GestureDetector(
      onTap: _next,
      child: Container(
        color: _green,
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'THE IDEA',
              style: TextStyle(
                fontSize: 10,
                color: _gold.withOpacity(0.6),
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Not all money\nis equal.',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: _gold,
                letterSpacing: -0.5,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Some is yours to spend.\nSome you\'re holding for others.\nSome is owed back to you.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withOpacity(0.55),
                height: 1.8,
              ),
            ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.55),
                  height: 1.8,
                ),
                children: [
                  const TextSpan(text: 'Dhahiri shows you the '),
                  TextSpan(
                    text: 'real picture',
                    style: const TextStyle(
                      color: _gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(
                      text: ' — not just your M-Pesa balance.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Screen 3 — CTA ──────────────────────────────────────────
  Widget _buildScreen3() {
    return Container(
      color: _green,
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 100),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GET STARTED',
            style: TextStyle(
              fontSize: 10,
              color: _gold.withOpacity(0.6),
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Built around\nyour reality.',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: _gold,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'All your money moves through M-Pesa. Dhahiri reads every message so you never have to open another app to log an expense.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.55),
              height: 1.8,
            ),
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withOpacity(0.55),
                height: 1.8,
              ),
              children: [
                const TextSpan(text: 'Takes '),
                TextSpan(
                  text: '2 minutes',
                  style: const TextStyle(
                    color: _gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(
                    text: ' to set up. Works silently from there.'),
              ],
            ),
          ),
          const SizedBox(height: 40),
          // CTA button
          GestureDetector(
            onTap: _goToSetup,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _gold,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Set up my accounts →',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _green,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}