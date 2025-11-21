import 'dart:async';
import 'package:bvst/game/audio_manager.dart';
import 'package:bvst/game/battle_game_lvl2.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameScreenLevel2 extends StatefulWidget {
  const GameScreenLevel2({super.key});

  @override
  State<GameScreenLevel2> createState() => _GameScreenLevel2State();
}

class _GameScreenLevel2State extends State<GameScreenLevel2> {
  int _countdown = 3;
  Timer? _timer;
  bool _isCountingDown = true;
  late final BattleGameLevel2 _game;

  @override
  void initState() {
    super.initState();
    _game = BattleGameLevel2(
      onGameOver: (hasWon) {
        if (mounted) {
          _game.pauseEngine();
          AudioManager().stopAllPooledSfx(); // Detiene los SFX de los pools
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
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else if (_countdown == 1) {
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
      onPanUpdate: (details) {
        if (details.delta.dx > 1.0) {
          _game.player.moveRight();
        } else if (details.delta.dx < -1.0) {
          _game.player.moveLeft();
        }
      },
      onPanEnd: (details) {
        _game.player.stopMoving();
      },
      onPanCancel: () {
        _game.player.stopMoving();
      },
      child: Container(
        width: 140,
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3).withOpacity(0.3),
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
        ),
        child: const Center(
          child: Icon(Icons.swap_horiz, color: Colors.white, size: 40),
        ),
      ),
    );
  }

  // --- WIDGET: BOTÓN DE DISPARO ATRACTIVO ---
  Widget _buildAttractiveShootButton() {
    return GestureDetector(
      onTap: _game.player.shoot,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFFFF9500).withOpacity(0.8),
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
          child: Icon(Icons.arrow_upward, color: Colors.white, size: 40),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            GameWidget(
              game: _game,
              backgroundBuilder: (context) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/fondo_Ira.png',
                      ), // Level 2 Background
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                );
              },
            ),

            if (_isCountingDown)
              Container(
                color: Colors.black.withAlpha(150),
                child: Center(
                  child: Text(
                    _countdown > 0 ? _countdown.toString() : '¡YA!',
                    style: GoogleFonts.orbitron(
                      fontSize: 100,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            if (!_isCountingDown)
              Positioned(
                bottom: 30,
                left: 30,
                right: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildMovementJoystick(),
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
