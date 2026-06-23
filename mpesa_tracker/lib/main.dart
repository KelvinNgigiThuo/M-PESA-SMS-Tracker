import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database/app_database.dart';
import 'overlay_channel.dart';

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
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _channel = MethodChannel('com.kelvin.mpesa/overlay');

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  Future<dynamic> _handleNativeCall(MethodCall call) async {
    if (call.method == 'showTagCard') {
      final data = Map<String, dynamic>.from(call.arguments);
      if (mounted) {
        await showTagCard(context, data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('M-Pesa Tracker')),
      body: const Center(
        child: Text(
          'Waiting for M-Pesa SMS...',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}