import 'dart:async';
import 'package:bvst/game/audio_manager.dart';
import 'package:bvst/game/battle_game_lvl3.dart';
import 'package:bvst/screens/pause_menu.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bvst/services/ad_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GameScreenLevel3 extends StatefulWidget {
  const GameScreenLevel3({super.key});

  @override
  State<GameScreenLevel3> createState() => _GameScreenLevel3State();
}

class _GameScreenLevel3State extends State<GameScreenLevel3> with WidgetsBindingObserver {
  int _countdown = 1;
  Timer? _timer;
  bool _isCountingDown = true;
  late final BattleGameLevel3 _game;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _game = BattleGameLevel3(
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
            arguments: {'hasWon': hasWon, 'currentLevel': 3},
          );
        }
      },
    );
    _startCountdown();
    Future.delayed(const Duration(milliseconds: 100), () {
      AudioManager().playUiSfx('contador.mp3');
    });
    // AudioManager().playGameBgm('musica_lvl3.mp3'); // <-- Moved to after countdown
    AdService().loadBanner();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

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
      if (_countdown < 3) {
        setState(() {
          _countdown++;
        });
      } else if (_countdown == 3) {
        setState(() {
          _countdown++;
        });
      } else {
        _timer?.cancel();
        AudioManager().playGameBgm('musica_lvl3.mp3'); // <-- Start Level 3 BGM here
        setState(() {
          _isCountingDown = false;
          _game.player.startBehavior();
          _game.enemy.startBehavior();
        });
      }
    });
  }

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
          child: Icon(
            Icons.arrow_upward,
            color: Colors.white,
            size: 40,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
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
                        image: AssetImage('assets/images/fondo_lvl3.png'),
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
                      _countdown > 3 ? 'GO' : _countdown.toString(),
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
