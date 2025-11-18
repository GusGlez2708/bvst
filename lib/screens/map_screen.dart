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
              fit: BoxFit.cover,
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

          // --- 4. BOTÓN NIVEL 2 (EL NUEVO DESBLOQUEADO) ---
          // Ajusta 'top' y 'left' según donde esté la segunda isla
          Positioned(
            top: size.height * 0.5, // 50% desde arriba
            right: size.width * 0.25, // 25% desde la derecha
            child: _buildLevelMarker(
              context,
              level: 2,
              isLocked:
                  false, // Asumimos que ya ganaste el 1, así que este está abierto
              label: "NIVEL 2",
              isPulse: true, // Efecto visual para indicar que es el siguiente
            ),
          ),

          // --- 5. BOTÓN VOLVER AL MENÚ ---
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
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: isLocked
              ? null
              : () {
                  AudioManager().playUiSfx('start.mp3');
                  // Navegar al juego pasando el argumento del nivel
                  Navigator.pushNamed(
                    context,
                    '/game',
                    arguments: {
                      'level': level,
                    }, // Pasamos el nivel seleccionado
                  );
                },
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isLocked
                  ? Colors.grey
                  : (isPulse ? const Color(0xFF4FA0E4) : Colors.green),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: isLocked
                      ? Colors.black
                      : (isPulse
                            ? const Color(0xFF4FA0E4).withOpacity(0.6)
                            : Colors.green.withOpacity(0.6)),
                  blurRadius: 15,
                  spreadRadius: isPulse ? 5 : 2,
                ),
              ],
            ),
            child: Center(
              child: isLocked
                  ? const Icon(Icons.lock, color: Colors.white)
                  : Text(
                      '$level',
                      style: GoogleFonts.pressStart2p(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
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
              style: GoogleFonts.orbitron(color: Colors.white, fontSize: 10),
            ),
          ),
      ],
    );
  }
}
