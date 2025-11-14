import 'package:bvst/game/audio_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OptionsScreen extends StatefulWidget {
  const OptionsScreen({super.key});

  @override
  State<OptionsScreen> createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  final AudioManager _audioManager = AudioManager();

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
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Opciones',
                    style: GoogleFonts.orbitron(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF61E2FF),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SwitchListTile(
                    title: const Text('Música de Fondo (BGM)', style: TextStyle(color: Colors.white)),
                    value: _audioManager.bgmEnabled,
                    onChanged: (value) {
                      setState(() {
                        _audioManager.bgmEnabled = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Efectos de Sonido (SFX)', style: TextStyle(color: Colors.white)),
                    value: _audioManager.sfxEnabled,
                    onChanged: (value) {
                      setState(() {
                        _audioManager.sfxEnabled = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text('Volumen BGM', style: TextStyle(color: Colors.white)),
                  Slider(
                    value: _audioManager.bgmVolume,
                    onChanged: (value) {
                      setState(() {
                        _audioManager.bgmVolume = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text('Volumen SFX', style: TextStyle(color: Colors.white)),
                  Slider(
                    value: _audioManager.sfxVolume,
                    onChanged: (value) {
                      setState(() {
                        _audioManager.sfxVolume = value;
                      });
                    },
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Volver'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
