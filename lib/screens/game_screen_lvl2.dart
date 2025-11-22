import 'dart:async';
import 'package:bvst/game/audio_manager.dart';
import 'package:bvst/game/battle_game_lvl2.dart';
import 'package:bvst/screens/pause_menu.dart'; // <-- Importar PauseMenu
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bvst/services/ad_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GameScreenLevel2 extends StatefulWidget {
  const GameScreenLevel2({super.key});

  @override
  State<GameScreenLevel2> createState() => _GameScreenLevel2State();
}

class _GameScreenLevel2State extends State<GameScreenLevel2> with WidgetsBindingObserver { // <-- Agregar Observer
  int _countdown = 3;
  Timer? _timer;
  bool _isCountingDown = true;
  late final BattleGameLevel2 _game;
  bool _isPaused = false; // <-- Estado de pausa

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // <-- Registrar observer
    _game = BattleGameLevel2(
      onGameOver: (hasWon) {
        if (mounted) {
          _game.pauseEngine();
          AudioManager().stopAllPooledSfx();
          AudioManager().stopGameBgm();

          if (hasWon) {
            AudioManager().playUiSfx('victory.mp3');
          } else {
            AudioManager().playUiSfx('defeat.mp3');
          }

          Navigator.pushReplacementNamed(
            context,
            '/result',
            arguments: {'hasWon': hasWon, 'currentLevel': 2},
          );
        }
      },
    );
    _startCountdown();
    AdService().loadBanner();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // <-- Eliminar observer
    _timer?.cancel();
    super.dispose();
  }

  // --- AUTO-PAUSE ---
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (!_isPaused && !_isCountingDown) {
        _pauseGame();
      }
    }
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

  // --- MÉTODOS DE PAUSA ---
  void _pauseGame() {
    setState(() {
      _isPaused = true;
    });
    _game.pauseEngine();
    AudioManager().pauseGameBgm();
  }

  void _resumeGame() {
    setState(() {
      _isPaused = false;
    });
    _game.resumeEngine();
    AudioManager().resumeGameBgm();
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
    return PopScope( // <-- Wrap Scaffold in PopScope
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (!_isPaused && !_isCountingDown) {
          _pauseGame();
        }
      },
      child: Scaffold(
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

              if (!_isCountingDown && !_isPaused) ...[
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
                // --- BOTÓN DE PAUSA ---
                Positioned(
                  top: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: _pauseGame,
                    child: Image.asset(
                      'assets/images/pause.png',
                      width: 50,
                      height: 50,
                    ),
                  ),
                ),
              ],

              // --- MENÚ DE PAUSA ---
              if (_isPaused)
                PauseMenu(
                  onResume: _resumeGame,
                  onQuit: () {
                    AudioManager().stopGameBgm();
                    AudioManager().playMenuBgm();
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
