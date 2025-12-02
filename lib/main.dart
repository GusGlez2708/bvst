// lib/main.dart
import 'package:bvst/game/audio_manager.dart';
import 'package:bvst/screens/game_screen.dart';
import 'package:bvst/screens/menu_screen.dart';
import 'package:bvst/screens/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bvst/screens/options_screen.dart';
// Importamos la nueva pantalla
import 'package:bvst/screens/login_screen.dart'; // <- NUEVO
import 'package:bvst/screens/level_selection_screen.dart';
import 'package:bvst/screens/game_screen_lvl2.dart';
import 'package:bvst/screens/game_screen_lvl3.dart'; // <- NUEVO NIVEL 3
import 'package:bvst/screens/game_screen_lvl4.dart'; // <- NUEVO NIVEL 4
import 'package:bvst/screens/game_screen_lvl5.dart'; // <- NUEVO NIVEL 5
import 'package:bvst/screens/game_screen_infinite.dart'; // <- NUEVO MODO INFINITO
import 'package:bvst/screens/shop_screen.dart'; // <- NUEVO
import 'package:bvst/screens/credits_screen.dart'; // <- NUEVO CRÉDITOS
import 'package:bvst/screens/cinematic_screen.dart'; // <- NUEVO CINEMÁTICAS
import 'package:supabase_flutter/supabase_flutter.dart'; // <- NUEVO
import 'package:bvst/services/ad_service.dart'; // <- NUEVO

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // --- INICIALIZACIÓN DE SUPABASE ---
  await Supabase.initialize(
    // Reemplaza con tus claves de Supabase
    url: 'https://hcuwpzbhyvieotntwdtc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhjdXdwemJoeXZpZW90bnR3ZHRjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM0ODUyMjUsImV4cCI6MjA3OTA2MTIyNX0.5jQQHXpiw74_QhhCPOC3UDWufXBzF9Ao4NoWIgLN56Q',
  );
  // ------------------------

  await AudioManager().preloadAllAudio();
  await AdService().initialize(); // <- NUEVO

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Echoes of Viridis',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthGate(), // Check session on startup
      routes: {
        '/login': (context) => const LoginScreen(),
        '/menu': (context) => const MenuScreen(),
        '/shop': (context) => const ShopScreen(),
        '/credits': (context) => const CreditsScreen(),
        '/cinematic': (context) => const CinematicScreen(),
        '/game': (context) => const GameScreen(),
        '/result': (context) => const ResultScreen(),
        '/options': (context) => const OptionsScreen(),
        '/level_selection': (context) => const LevelSelectionScreen(),
        '/game_lvl2': (context) => const GameScreenLevel2(),
        '/game_lvl3': (context) => const GameScreenLevel3(),
        '/game_lvl4': (context) => const GameScreenLevel4(),
        '/game_lvl5': (context) => const GameScreenLevel5(),
        '/game_infinite': (context) => const GameScreenInfinite(),
      },
    );
  }
}

/// Widget that checks for existing session and routes accordingly
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Small delay to ensure Supabase is fully initialized
    await Future.delayed(const Duration(milliseconds: 100));

    final session = Supabase.instance.client.auth.currentSession;

    if (mounted) {
      if (session != null) {
        print('✓ Existing session found for user: ${session.user.email}');
      } else {
        print('✗ No session found, allowing guest access');
      }

      // Always show opening cinematic first, then go to menu
      Navigator.of(context).pushReplacementNamed(
        '/cinematic',
        arguments: {
          'videoPath':
              'assets/cinematicas/Pixel_Art_Hero_s_Melancholic_Journey.mp4',
          'nextRoute': '/menu',
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while checking session
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

final supabase = Supabase.instance.client;
