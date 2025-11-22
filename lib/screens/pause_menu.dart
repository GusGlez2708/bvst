import 'package:bvst/game/audio_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PauseMenu extends StatefulWidget {
  final VoidCallback onResume;
  final VoidCallback onQuit;

  const PauseMenu({
    super.key,
    required this.onResume,
    required this.onQuit,
  });

  @override
  State<PauseMenu> createState() => _PauseMenuState();
}

class _PauseMenuState extends State<PauseMenu> {
  final AudioManager _audioManager = AudioManager();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.85),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'PAUSA',
                style: GoogleFonts.orbitron(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF61E2FF),
                  shadows: [
                    const Shadow(
                      blurRadius: 10.0,
                      color: Colors.blue,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // --- Opciones de Audio ---
              Container(
                width: 300,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    const Text('Volumen BGM', style: TextStyle(color: Colors.white)),
                    Slider(
                      value: _audioManager.bgmVolume,
                      activeColor: const Color(0xFF61E2FF),
                      inactiveColor: Colors.grey,
                      onChanged: (value) {
                        setState(() {
                          _audioManager.bgmVolume = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text('Volumen SFX', style: TextStyle(color: Colors.white)),
                    Slider(
                      value: _audioManager.sfxVolume,
                      activeColor: const Color(0xFFFF9500),
                      inactiveColor: Colors.grey,
                      onChanged: (value) {
                        setState(() {
                          _audioManager.sfxVolume = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),

              // --- Botones ---
              _buildMenuButton(
                text: 'REANUDAR',
                color: Colors.green,
                icon: Icons.play_arrow,
                onTap: widget.onResume,
                playSound: false, // <-- No sound for resume
              ),
              const SizedBox(height: 20),
              _buildMenuButton(
                text: 'TIENDA',
                color: Colors.amber,
                icon: Icons.shopping_cart,
                onTap: () {
                  Navigator.pushNamed(context, '/shop');
                },
              ),
              const SizedBox(height: 20),
              _buildMenuButton(
                text: 'SALIR AL MENÚ',
                color: Colors.red,
                icon: Icons.exit_to_app,
                onTap: widget.onQuit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required String text,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
    bool playSound = true, // <-- New parameter
  }) {
    return GestureDetector(
      onTap: () {
        if (playSound) {
          AudioManager().playUiSfx('start.mp3');
        }
        onTap();
      },
      child: Container(
        width: 250,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Text(
              text,
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
