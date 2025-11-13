import 'dart:async';
import 'package:bvst/game/battle_game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      } else {
        _timer?.cancel();
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

  Widget _buildButton(IconData icon, VoidCallback onPressed, {Color color = const Color(0xFF2196F3)}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.8),
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
        elevation: 4,
      ),
      onPressed: onPressed,
      child: Icon(icon, color: Colors.white, size: 30),
    );
  }

  Widget _buildMoveButton(IconData icon, {required Function(bool) onStateChanged}) {
    return GestureDetector(
      onTapDown: (_) => onStateChanged(true),
      onTapUp: (_) => onStateChanged(false),
      onTapCancel: () => onStateChanged(false),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3).withOpacity(0.8),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            GameWidget(game: _game),
            if (_isCountingDown)
              Container(
                color: Colors.black.withOpacity(0.5),
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
                left: 20,
                child: Row(
                  children: [
                    _buildMoveButton(
                      Icons.arrow_left,
                      onStateChanged: (isPressed) => _game.player.isMovingLeft = isPressed,
                    ),
                    const SizedBox(width: 20),
                    _buildMoveButton(
                      Icons.arrow_right,
                      onStateChanged: (isPressed) => _game.player.isMovingRight = isPressed,
                    ),
                  ],
                ),
              ),
            if (!_isCountingDown)
              Positioned(
                bottom: 30,
                right: 30,
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: _buildButton(
                    Icons.arrow_upward,
                    () => _game.player.shoot(),
                    color: const Color(0xFFFF9500),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
