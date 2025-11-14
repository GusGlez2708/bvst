import 'package:bvst/game/audio_manager.dart';
import 'package:bvst/screens/game_screen.dart';
import 'package:bvst/screens/menu_screen.dart';
import 'package:bvst/screens/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bvst/screens/options_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/menu',
      routes: {
        '/menu': (context) => const MenuScreen(),
        '/game': (context) => const GameScreen(),
        '/result': (context) => const ResultScreen(),
        '/options': (context) => const OptionsScreen(),
      },
    );
  }
}