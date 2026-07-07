import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database/app_database.dart';
import 'services/setup_service.dart';
import 'screens/main_shell.dart';
import 'screens/setup_screen.dart';
import 'screens/onboarding_screen.dart';
import 'app.dart';
import 'overlay_channel.dart';

final AppDatabase db = AppDatabase();
final ValueNotifier<bool> isPrivacyMode = ValueNotifier(false);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DhahiriApp(home: AppEntry()));
}

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    final setupDone = await SetupService.hasCompletedSetup();
    if (!mounted) return;
    if (setupDone) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      Navigator.of(context).pushReplacementNamed('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1A3C34),
      body: Center(
        child: CircularProgressIndicator(
            color: Color(0xFFC9A84C)),
      ),
    );
  }
}

// ── TagCard entry point (used by TagCardActivity) ─────────────
@pragma('vm:entry-point')
void tagCardMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TagCardApp());
}

class TagCardApp extends StatelessWidget {
  const TagCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1A3C34)),
        useMaterial3: true,
      ),
      home: const TagCardHost(),
    );
  }
}

class TagCardHost extends StatefulWidget {
  const TagCardHost({super.key});

  @override
  State<TagCardHost> createState() => _TagCardHostState();
}

class _TagCardHostState extends State<TagCardHost> {
  static const _channel =
      MethodChannel('com.kelvin.mpesa/overlay');

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler(_handleNativeCall);
    _signalReady();
  }

  Future<void> _signalReady() async {
    try {
      await _channel.invokeMethod('flutterReady');
    } catch (e) {}
  }

  Future<dynamic> _handleNativeCall(MethodCall call) async {
    if (call.method == 'showTagCard') {
      final data = Map<String, dynamic>.from(call.arguments);
      if (mounted) {
        await showTagCard(context, data);
        try {
          await _channel.invokeMethod('closeTagCard');
        } catch (e) {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox.shrink(),
    );
  }
}