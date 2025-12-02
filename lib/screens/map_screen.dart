import 'package:bvst/game/audio_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener dimensiones de la pantalla para ubicar los botones proporcionalmente
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // --- 1. IMAGEN DE FONDO (Mapa_Lvl2.png) ---
          Positioned.fill(
            child: Image.asset(
              'assets/images/Mapa_Lvl2.png',
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
            ),
          ),

          // --- 2. TÍTULO ---
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'SELECCIONAR MISIÓN',
                style: GoogleFonts.orbitron(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    const Shadow(
                      blurRadius: 10,
                      color: Colors.black,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- 3. BOTÓN NIVEL 1 (YA COMPLETADO O REJUGABLE) ---
          // Ajusta 'top' y 'left' según donde esté la primera isla en tu imagen
          Positioned(
            top: size.height * 0.4, // 40% desde arriba
            left: size.width * 0.2, // 20% desde la izquierda
            child: _buildLevelMarker(
              context,
              level: 1,
              isLocked: false, // Nivel 1 siempre abierto
              label: "NIVEL 1",
            ),
          ),

          // --- 4. BOTÓN NIVEL 2 ---
          Positioned(
            top: size.height * 0.5, // 50% desde arriba
            right: size.width * 0.25, // 25% desde la derecha
            child: _buildLevelMarker(
              context,
              level: 2,
              isLocked: false,
              label: "NIVEL 2",
            ),
          ),

          // --- 5. BOTÓN NIVEL 3 ---
          Positioned(
            top: size.height * 0.35, // 35% desde arriba
            left: size.width * 0.45, // 45% desde la izquierda (centro)
            child: _buildLevelMarker(
              context,
              level: 3,
              isLocked: false,
              label: "NIVEL 3",
            ),
          ),

          // --- 6. BOTÓN NIVEL 4 ---
          Positioned(
            top: size.height * 0.6, // 60% desde arriba
            left: size.width * 0.15, // 15% desde la izquierda
            child: _buildLevelMarker(
              context,
              level: 4,
              isLocked: false,
              label: "NIVEL 4",
            ),
          ),

          // --- 7. BOTÓN NIVEL 5 (FINAL) ---
          Positioned(
            top: size.height * 0.25, // 25% desde arriba (parte superior)
            right: size.width * 0.15, // 15% desde la derecha
            child: _buildLevelMarker(
              context,
              level: 5,
              isLocked: false,
              label: "NIVEL 5 - FINAL",
              isPulse: true, // Efecto visual para el nivel final
            ),
          ),

          // --- 8. BOTÓN MODO INFINITO ---
          Positioned(
            bottom: size.height * 0.12, // 12% desde abajo
            left: size.width * 0.5 - 40, // Centrado horizontalmente
            child: _buildLevelMarker(
              context,
              level: 0, // Nivel 0 para modo infinito
              isLocked: false,
              label: "MODO INFINITO",
              isPulse: true,
              isInfinite: true, // Flag para identificar modo infinito
            ),
          ),

          // --- 9. BOTÓN VOLVER AL MENÚ ---
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelMarker(
    BuildContext context, {
    required int level,
    required bool isLocked,
    required String label,
    bool isPulse = false,
    bool isInfinite = false,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: isLocked
              ? null
              : () {
                  AudioManager().playUiSfx('start.mp3');

                  // Handle infinite mode navigation
                  if (isInfinite) {
                    Navigator.pushNamed(context, '/game_infinite');
                    return;
                  }

                  // Navegar al juego según el nivel específico

                  // Level 1 has cinematic
                  if (level == 1) {
                    Navigator.pushNamed(
                      context,
                      '/cinematic',
                      arguments: {
                        'videoPath': 'assets/cinematicas/WakeUpLeve1.mp4',
                        'nextRoute': '/game',
                      },
                    );
                    return;
                  }

                  // Other levels go directly to game (no cinematics yet)
                  String route = '/game';
                  if (level == 2) route = '/game_lvl2';
                  if (level == 3) route = '/game_lvl3';
                  if (level == 4) route = '/game_lvl4';
                  if (level == 5) route = '/game_lvl5';

                  Navigator.pushNamed(context, route);
                },
          child: Container(
            width: isInfinite ? 80 : 60, // Bigger for infinite mode
            height: isInfinite ? 80 : 60,
            decoration: BoxDecoration(
              color: isLocked
                  ? Colors.grey
                  : (isInfinite
                        ? const Color(0xFF8B00FF) // Purple for infinite
                        : (isPulse ? const Color(0xFF4FA0E4) : Colors.green)),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: isLocked
                      ? Colors.black
                      : (isInfinite
                            ? const Color(0xFF8B00FF).withOpacity(0.8)
                            : (isPulse
                                  ? const Color(0xFF4FA0E4).withOpacity(0.6)
                                  : Colors.green.withOpacity(0.6))),
                  blurRadius: 15,
                  spreadRadius: isPulse || isInfinite ? 5 : 2,
                ),
              ],
            ),
            child: Center(
              child: isLocked
                  ? const Icon(Icons.lock, color: Colors.white)
                  : (isInfinite
                        ? const Icon(
                            Icons.all_inclusive,
                            color: Colors.white,
                            size: 40,
                          )
                        : Text(
                            '$level',
                            style: GoogleFonts.pressStart2p(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          )),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (!isLocked)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: GoogleFonts.orbitron(
                color: isInfinite ? const Color(0xFF8B00FF) : Colors.white,
                fontSize: 10,
                fontWeight: isInfinite ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
      ],
    );
  }
}
