import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bvst/game/audio_manager.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image (Map 2)
          Positioned.fill(
            child: Image.asset('assets/images/Map_Lvl2.png', fit: BoxFit.cover),
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
                    'NIVEL 2',
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
                  // Start Level 2 Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: GestureDetector(
                      onTap: () {
                        AudioManager().stopAllAudio();
                        Navigator.pushReplacementNamed(context, '/game_lvl2');
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
                          'JUGAR NIVEL 2',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),

                  // Back to Menu Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50.0),
                    child: GestureDetector(
                      onTap: () {
                        AudioManager().stopAllAudio();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/menu',
                          (route) => false,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Text(
                          'VOLVER AL MENÚ',
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
