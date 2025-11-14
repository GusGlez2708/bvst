import 'package:bvst/game/audio_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isButtonEnabled = false; // Controla si el botón es clickeable

  @override
  void initState() {
    super.initState();
    // 1. Configuración de la animación de fundido
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Duración del fundido (1 segundo)
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController)
      ..addListener(() {
        setState(() {}); // Redibuja el widget a medida que la opacidad cambia
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _isButtonEnabled = true; // Habilita el botón una vez que la animación termina
          });
        }
      });

    // Inicia la animación después de un pequeño retraso
    // para que primero se vea la pantalla de victoria/derrota
    Future.delayed(const Duration(seconds: 1), () {
      _animationController.forward(); // Inicia la animación de fundido
    });
  }

  @override
  void dispose() {
    _animationController.dispose(); // Libera recursos del controlador de animación
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final bool hasWon = args['hasWon'];

    // 2. Determina el fondo y el texto del botón según si ganó o perdió
    final String backgroundImage =
        hasWon ? 'assets/images/you_win_bg.png' : 'assets/images/game_over_bg.png';
    
    final String buttonText = 'VOLVER AL MENÚ';

    return Scaffold(
      body: Stack(
        children: [
          // --- Fondo de pantalla de victoria o derrota ---
          Positioned.fill(
            child: Image.asset(
              backgroundImage,
              fit: BoxFit.cover,
            ),
          ),

          // --- Botón "VOLVER AL MENÚ" (con animación de fundido) ---
          Align(
            alignment: const Alignment(0.0, 0.8), // Posiciona el botón en la parte inferior
            child: Opacity(
              opacity: _fadeAnimation.value, // Controla la opacidad con la animación
              child: _buildStyledButton(
                text: buttonText,
                onTap: _isButtonEnabled // Solo es clickeable si la animación terminó
                    ? () {
                        // Detiene el sonido de victoria/derrota
                        AudioManager().stopAllAudio();
                        // Vuelve al menú (donde se iniciará la música del menú)
                        Navigator.pushNamedAndRemoveUntil(context, '/menu', (route) => false);
                      }
                    : null, // Deshabilita el botón si no es clickeable
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget auxiliar para los botones con el estilo del menú
  Widget _buildStyledButton({required String text, required VoidCallback? onTap}) {
    // Si onTap es null (botón deshabilitado), usa un color más oscuro para indicarlo
    final Color buttonColor = onTap != null ? Colors.white : Colors.grey.shade600;
    final Color textColor = onTap != null ? const Color(0xFF2C3454) : Colors.grey.shade400;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280, // Ancho adecuado para "VOLVER AL MENÚ"
        height: 55, // Alto del botón
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade400, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              text,
              style: GoogleFonts.pressStart2p(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Remaches
            Positioned(top: 5, left: 5, child: _buildRivets()),
            Positioned(top: 5, right: 5, child: _buildRivets()),
            Positioned(bottom: 5, left: 5, child: _buildRivets()),
            Positioned(bottom: 5, right: 5, child: _buildRivets()),
          ],
        ),
      ),
    );
  }

  /// Widget para crear un "remache" individual
  Widget _buildRivets() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey.shade600,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            offset: const Offset(0, 1),
            blurRadius: 1,
          ),
        ],
      ),
    );
  }
}