import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    super.initState();
    // Stop any previously playing music and start from scratch.
    FlameAudio.bgm.stop().then((_) {
      FlameAudio.loop('bg_music.mp3', volume: 0.5);
    });
  }

  @override
  void dispose() {
    FlameAudio.bgm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF0D1B2A), Color(0xFF000000)],
            center: Alignment.center,
            radius: 0.8,
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: GridPaper(
                color: Color(0x1AFFFFFF),
                divisions: 1,
                subdivisions: 1,
                interval: 100,
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Battle Chase',
                    style: GoogleFonts.orbitron(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF61E2FF),
                      shadows: [
                        const Shadow(
                          blurRadius: 20.0,
                          color: Color(0xFF61E2FF),
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 70),
                  GestureDetector(
                    onTap: () {
                      FlameAudio.bgm.audioPlayer.setVolume(0.2);
                      FlameAudio.play('start.mp3').then((_) {
                        if (mounted) {
                          Navigator.pushNamed(context, '/game');
                        }
                      });

                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) {
                          FlameAudio.bgm.audioPlayer.setVolume(0.5);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00A2B8), Color(0xFF00F0FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: const Color(0xFF61E2FF), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00F0FF).withAlpha((255 * 0.4).round()),
                            blurRadius: 15,
                            spreadRadius: 2,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Text(
                        'JUGAR',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 24,
                          color: Colors.white,
                          shadows: [
                            const Shadow(
                              blurRadius: 10.0,
                              color: Colors.black,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
