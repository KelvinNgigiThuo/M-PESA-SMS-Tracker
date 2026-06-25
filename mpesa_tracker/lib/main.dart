import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database/app_database.dart';
import 'overlay_channel.dart';
import 'dashboard_screen.dart';

final AppDatabase db = AppDatabase();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MpesaTrackerApp());
}

class MpesaTrackerApp extends StatelessWidget {
  const MpesaTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'M-Pesa Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A73E8)),
        scaffoldBackgroundColor: Colors.transparent,
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

// Separate entry point for TagCardActivity — transparent scaffold only
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A73E8)),
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
  static const _channel = MethodChannel('com.kelvin.mpesa/overlay');

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
      body: SizedBox.shrink(), // Renders nothing — transparent
    );
  }
}