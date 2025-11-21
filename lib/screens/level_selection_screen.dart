import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bvst/game/audio_manager.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get level from arguments, default to 2 if not provided
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final int level = args?['level'] ?? 2;

    // Level configuration
    final levelConfig = {
      2: {
        'mapImage': 'Map_Lvl2.png',
        'title': 'NIVEL 2',
        'route': '/game_lvl2',
      },
      3: {
        'mapImage': 'Map_Lvl3.png',
        'title': 'NIVEL 3',
        'route': '/game_lvl3',
      },
      4: {
        'mapImage': 'Map_Lvl4.png',
        'title': 'NIVEL 4',
        'route': '/game_lvl4',
      },
    };

    final config = levelConfig[level] ?? levelConfig[2]!;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image (Dynamic based on level)
          Positioned.fill(
            child: Image.asset(
              'assets/images/${config['mapImage']}',
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
            ),
          ),

          // Overlay for better text visibility
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),

          // Content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    config['title'] as String,
                    style: GoogleFonts.orbitron(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        const Shadow(
                          blurRadius: 10.0,
                          color: Colors.black,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Start Level Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: GestureDetector(
                      onTap: () {
                        AudioManager().stopAllAudio();
                        Navigator.pushReplacementNamed(
                          context,
                          config['route'] as String,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Text(
                          'SIGUIENTE',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
