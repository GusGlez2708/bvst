// lib/main.dart
import 'package:bvst/game/audio_manager.dart';
import 'package:bvst/screens/game_screen.dart';
import 'package:bvst/screens/menu_screen.dart';
import 'package:bvst/screens/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bvst/screens/options_screen.dart';
// Importamos la nueva pantalla
import 'package:bvst/screens/login_screen.dart'; // <-- NUEVO
import 'package:bvst/screens/level_selection_screen.dart';
import 'package:bvst/screens/game_screen_lvl2.dart';
import 'package:bvst/screens/shop_screen.dart'; // <-- NUEVO
import 'package:supabase_flutter/supabase_flutter.dart'; // <-- NUEVO

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
      title: 'Battle Chase',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login', // <-- CAMBIADO DE '/menu' a '/login'
      routes: {
        '/login': (context) => const LoginScreen(), // <-- NUEVA RUTA
        '/menu': (context) => const MenuScreen(),
        '/shop': (context) => const ShopScreen(), // <-- NUEVA RUTA TIENDA
        '/game': (context) => const GameScreen(),
        '/result': (context) => const ResultScreen(),
        '/options': (context) => const OptionsScreen(),
        '/level_selection': (context) => const LevelSelectionScreen(),
        '/game_lvl2': (context) => const GameScreenLevel2(),
      },
    );
  }
}

final supabase = Supabase.instance.client;
