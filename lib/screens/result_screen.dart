import 'package:bvst/game/audio_manager.dart';
import 'package:bvst/services/ad_service.dart'; // <-- NUEVO
import 'package:bvst/services/progress_service.dart'; // Import ProgressService
import 'package:bvst/services/score_service.dart'; // <- NUEVO for infinite scores
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isButtonEnabled = false;
  bool _scoreSaved = false; // Track if score was saved

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              setState(() {
                _isButtonEnabled = true;
              });
            }
          });

    Future.delayed(const Duration(seconds: 1), () async {
      _animationController.forward();
      // Check if we should show ad (not on level 1 win)
      final Map<String, dynamic> args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final int currentLevel = args['currentLevel'] ?? 1;
      final bool hasWon = args['hasWon'];

      // Save Progress Logic (only for story mode)
      if (hasWon && currentLevel > 0) {
        final progressService = ProgressService();
        int nextLevelToSave = currentLevel + 1;

        // If completed level 5 (final), reset to level 1
        if (currentLevel >= 5) {
          nextLevelToSave = 1;
        }

        await progressService.saveLevel(nextLevelToSave);
      }

      // Don't auto-save infinite mode score - show dialog instead
      // The dialog will be shown in the UI when buttons are enabled

      // Show ad only if NOT level 1 (or if you want to show it on game over regardless of level, adjust logic)
      // User request: "solo quiero que cambies el del nivel 1, quiero que lo quites"
      // Assuming this means remove it from Level 1 completion/gameover?
      // "el que aparece cuando se muere el jugador esta bien, ahora, solo quiero que cambies el del nivel 1"
      // So if Game Over -> Show Ad. If Level 1 Win -> No Ad.

      if (!hasWon) {
        AdService().showInterstitial();
      } else if (currentLevel != 1) {
        AdService().showInterstitial();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final bool hasWon = args['hasWon'];
    final int currentLevel =
        args['currentLevel'] ?? 1; // Default to level 1 if not specified

    // Determine next level for preview screen
    int? nextLevel;
    if (currentLevel == 1) {
      nextLevel = 2;
    } else if (currentLevel == 2) {
      nextLevel = 3;
    } else if (currentLevel == 3) {
      nextLevel = 4;
    } else if (currentLevel == 4) {
      nextLevel = 5; // Added Level 5
    } else {
      nextLevel = null; // No more levels after level 5
    }

    // --- LÓGICA DE COLOR CONDICIONAL ---
    final Color primaryButtonColor;
    final Color primaryTextColor;
    final Color primaryBorderColor;

    if (hasWon) {
      // Estilo AZUL para "YOU WIN"
      primaryButtonColor = const Color(0xFF4FA0E4); // Azul claro
      primaryTextColor = Colors.white;
      primaryBorderColor = const Color(0xFF88D4F7); // Borde azul más claro
    } else {
      // Estilo ROJO para "GAME OVER"
      primaryButtonColor = const Color(0xFFD9534F); // Rojo
      primaryTextColor = Colors.white;
      primaryBorderColor = const Color(0xFFB94A48); // Borde rojo oscuro
    }

    final String backgroundImage = hasWon
        ? 'assets/images/you_win_bg.png'
        : 'assets/images/game_over_bg.png';

    final String buttonText = 'VOLVER AL MENÚ';

    return PopScope(
      canPop: false, // Disable back button
      child: Scaffold(
        body: Stack(
          children: [
            // --- Fondo de pantalla ---
            Positioned.fill(
              child: Image.asset(
                backgroundImage,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
              ),
            ),

            // --- Botón posicionado ---
            Align(
              alignment: const Alignment(0.0, 0.65), // Posición (más arriba)
              // ¡Ya no usamos el widget Opacity aquí!
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasWon &&
                      nextLevel !=
                          null) // Show SIGUIENTE only if there's a next level
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: _buildStyledButton(
                        text: 'SIGUIENTE',
                        colors: (
                          button: const Color(0xFF4CAF50), // Verde
                          text: Colors.white,
                          border: const Color(0xFF81C784),
                        ),
                        opacity: _fadeAnimation.value,
                        onTap: _isButtonEnabled
                            ? () {
                                AudioManager().stopAllAudio();
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/level_selection',
                                  arguments: {'level': nextLevel},
                                );
                              }
                            : null,
                      ),
                    ),
                  if (hasWon)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: _buildStyledButton(
                        text: 'TIENDA',
                        colors: (
                          button: const Color(0xFFFFA500), // Orange
                          text: Colors.white,
                          border: const Color(0xFFFFB84D),
                        ),
                        opacity: _fadeAnimation.value,
                        onTap: _isButtonEnabled
                            ? () {
                                Navigator.pushNamed(context, '/shop');
                              }
                            : null,
                      ),
                    ),
                  // GUARDAR SCORE button - only for infinite mode
                  if (currentLevel == 0 && !hasWon && !_scoreSaved)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: _buildStyledButton(
                        text: 'GUARDAR SCORE',
                        colors: (
                          button: const Color(0xFFFFD700), // Gold
                          text: Colors.black,
                          border: const Color(0xFFFFA500),
                        ),
                        opacity: _fadeAnimation.value,
                        onTap: _isButtonEnabled
                            ? () => _showSaveScoreDialog(context, args)
                            : null,
                      ),
                    ),
                  _buildStyledButton(
                    text: buttonText,
                    colors: (
                      button: primaryButtonColor,
                      text: primaryTextColor,
                      border: primaryBorderColor,
                    ),
                    // Pasamos el valor de la animación directamente al botón
                    opacity: _fadeAnimation.value,
                    onTap: _isButtonEnabled
                        ? () {
                            AudioManager().stopAllAudio();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/menu',
                              (route) => false,
                            );
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// --- WIDGET DE BOTÓN ACTUALIZADO ---
  /// Ahora acepta 'opacity' para animar sus propios colores
  Widget _buildStyledButton({
    required String text,
    required VoidCallback? onTap,
    required ({Color button, Color text, Color border}) colors,
    required double opacity, // Parámetro de opacidad de la animación
  }) {
    // --- NUEVA LÓGICA DE COLOR ---
    // Aplicamos la opacidad de la animación directamente a los colores base.
    // Ya no usamos un color "gris" de deshabilitado.
    final Color buttonColor = colors.button.withOpacity(opacity);
    final Color textColor = colors.text.withOpacity(opacity);
    final Color borderColor = colors.border.withOpacity(opacity);
    final Color shadowColor = Colors.black.withOpacity(
      0.3 * opacity,
    ); // La sombra también se difumina

    return GestureDetector(
      onTap:
          onTap, // Sigue siendo nulo hasta que _isButtonEnabled es true, previniendo clics
      child: Container(
        width: 280,
        height: 55,
        decoration: BoxDecoration(
          color: buttonColor, // Color de fondo (rojo/azul) con opacidad animada
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor,
            width: 2,
          ), // Borde con opacidad animada
          boxShadow: [
            BoxShadow(
              color: shadowColor, // Sombra con opacidad animada
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
                color: textColor, // Texto con opacidad animada
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Remaches (también reciben la opacidad)
            Positioned(top: 5, left: 5, child: _buildRivets(opacity: opacity)),
            Positioned(top: 5, right: 5, child: _buildRivets(opacity: opacity)),
            Positioned(
              bottom: 5,
              left: 5,
              child: _buildRivets(opacity: opacity),
            ),
            Positioned(
              bottom: 5,
              right: 5,
              child: _buildRivets(opacity: opacity),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget para crear un "remache" individual (ahora acepta opacidad)
  Widget _buildRivets({required double opacity}) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey.shade600.withOpacity(
          opacity,
        ), // Color con opacidad animada
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.4 * opacity,
            ), // Sombra con opacidad animada
            offset: const Offset(0, 1),
            blurRadius: 1,
          ),
        ],
      ),
    );
  }

  /// Show save score confirmation dialog
  Future<void> _showSaveScoreDialog(
    BuildContext context,
    Map<String, dynamic> args,
  ) async {
    final int score = args['score'] ?? 0;
    final int round = args['round'] ?? 1; // Use actual round from game

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0D1B2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF61E2FF), width: 2),
          ),
          title: Text(
            '¿GUARDAR PUNTAJE?',
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF61E2FF),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Score: $score',
                style: GoogleFonts.orbitron(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFD700),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ronda: $round',
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '¿Deseas guardar este puntaje en el leaderboard?',
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'NO',
                style: GoogleFonts.pressStart2p(
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FA0E4),
              ),
              child: Text(
                'SÍ, GUARDAR',
                style: GoogleFonts.pressStart2p(
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result == true && mounted) {
      // Save the score
      final scoreService = ScoreService();
      final success = await scoreService.saveInfiniteScore(score, round);

      if (success) {
        setState(() {
          _scoreSaved = true;
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '¡Score guardado exitosamente!',
                style: GoogleFonts.orbitron(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF4CAF50),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error al guardar el score',
                style: GoogleFonts.orbitron(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }
}
