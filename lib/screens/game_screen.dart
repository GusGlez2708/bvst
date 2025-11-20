// lib/screens/game_screen.dart
import 'dart:async';
import 'package:bvst/game/audio_manager.dart';
import 'package:bvst/game/battle_game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bvst/services/ad_service.dart'; // <-- NUEVO
import 'package:google_mobile_ads/google_mobile_ads.dart'; // <-- NUEVO

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _countdown = 3;
  Timer? _timer;
  bool _isCountingDown = true;
  late final BattleGame _game;

  @override
  void initState() {
    super.initState();
    _game = BattleGame(
      onGameOver: (hasWon) {
        if (mounted) {
          _game.pauseEngine();
          AudioManager().stopGameBgm();

          if (hasWon) {
            AudioManager().playUiSfx('victory.mp3');
          } else {
            AudioManager().playUiSfx('defeat.mp3');
          }

          Navigator.pushReplacementNamed(
            context,
            '/result',
            arguments: {'hasWon': hasWon},
          );
        }
      },
    );
    _startCountdown();
    AdService().loadBanner(); // <-- Cargar banner
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else if (_countdown == 1) {
        // Añadido para que muestre ¡YA!
        setState(() {
          _countdown--;
        });
      } else {
        _timer?.cancel();
        AudioManager().playGameBgm();
        setState(() {
          _isCountingDown = false;
          _game.player.startBehavior();
          _game.enemy.startBehavior();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- WIDGET: JOYSTICK DE MOVIMIENTO ---
  Widget _buildMovementJoystick() {
    return GestureDetector(
      // Se activa cuando el usuario arrastra el dedo
      onPanUpdate: (details) {
        // Si el movimiento es significativamente a la derecha
        if (details.delta.dx > 1.0) {
          _game.player.moveRight(); // <-- Llama al nuevo método
        } 
        // Si el movimiento es significativamente a la izquierda
        else if (details.delta.dx < -1.0) {
          _game.player.moveLeft(); // <-- Llama al nuevo método
        }
      },
      // Se activa cuando el usuario levanta el dedo
      onPanEnd: (details) {
        _game.player.stopMoving(); // <-- Llama al nuevo método
      },
      // También detiene el movimiento si el gesto se cancela
      onPanCancel: () {
        _game.player.stopMoving(); // <-- Llama al nuevo método
      },
      // La parte visual del "joystick"
      child: Container(
        width: 140, // Más pequeño para que quepa bien
        height: 70, 
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3).withOpacity(0.3), // Azul semitransparente
          borderRadius: BorderRadius.circular(35), // Forma de píldora
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
        ),
        child: const Center(
          child: Icon(
            Icons.swap_horiz, 
            color: Colors.white,
            size: 40,
          ),
        ),
      ),
    );
  }

  // --- WIDGET: BOTÓN DE DISPARO ATRACTIVO ---
  Widget _buildAttractiveShootButton() {
    return GestureDetector(
      onTap: _game.player.shoot, // Llama al método shoot
      child: Container(
        width: 70, // Tamaño del botón
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFFFF9500).withOpacity(0.8), // Naranja (como en base2.md)
          shape: BoxShape.circle, 
          border: Border.all(color: Colors.white.withOpacity(0.8), width: 3),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF9500).withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.arrow_upward, // Icono de flecha arriba (como en base2.md)
            color: Colors.white,
            size: 40,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: AdService().getBannerAd() != null 
          ? SizedBox(
              height: AdService().getBannerAd()!.size.height.toDouble(),
              width: AdService().getBannerAd()!.size.width.toDouble(),
              child: AdWidget(ad: AdService().getBannerAd()!),
            )
          : null,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            // El fondo se maneja en el GameWidget
            GameWidget(
              game: _game,
              backgroundBuilder: (context) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/fondo.png'),
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                );
              },
            ),
            
            // --- SUPERPOSICIÓN DE CONTROLES (HUD) ---
            if (_isCountingDown)
              Container(
                color: Colors.black.withAlpha(150),
                child: Center(
                  child: Text(
                    _countdown > 0 ? _countdown.toString() : '¡YA!', // Muestra ¡YA!
                    style: GoogleFonts.orbitron(
                      fontSize: 100,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            
            // --- CONTROLES DE JUEGO (ACTUALIZADOS) ---
            if (!_isCountingDown)
              Positioned(
                bottom: 30, // Posición desde abajo
                left: 30,  // Margen izquierdo
                right: 30, // Margen derecho
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Lado izquierdo: Joystick de movimiento
                    _buildMovementJoystick(),
                    
                    // Lado derecho: Botón de disparo
                    _buildAttractiveShootButton(),
                  ],
                ),
              ),
          ],
          
        ),
      ),
    );
  }
}
