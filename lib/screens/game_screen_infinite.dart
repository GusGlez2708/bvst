import 'dart:async';
import 'package:bvst/game/audio_manager.dart';
import 'package:bvst/game/battle_game_infinite.dart';
import 'package:bvst/screens/pause_menu.dart';
import 'package:bvst/widgets/ability_widget.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bvst/services/ad_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GameScreenInfinite extends StatefulWidget {
  const GameScreenInfinite({super.key});

  @override
  State<GameScreenInfinite> createState() => _GameScreenInfiniteState();
}

class _GameScreenInfiniteState extends State<GameScreenInfinite>
    with WidgetsBindingObserver {
  int _countdown = 1;
  Timer? _timer;
  bool _isCountingDown = false;
  late final BattleGameInfinite _game;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _game = BattleGameInfinite(
      onGameOver: (hasWon) {
        if (mounted) {
          _game.pauseEngine();
          AudioManager().stopAllPooledSfx();
          AudioManager().stopGameBgm();

          // In infinite mode, hasWon is always false (player died)
          AudioManager().playUiSfx('defeat.mp3');
          Navigator.pushReplacementNamed(
            context,
            '/result',
            arguments: {
              'hasWon': false,
              'currentLevel': 0, // Special level for infinite mode
              'score': _game.score, // Pass score
            },
          );
        }
      },
    );

    // Start countdown immediately (no dialogue in infinite mode)
    _isCountingDown = true;
    _startCountdown();
    Future.delayed(const Duration(milliseconds: 100), () {
      AudioManager().playUiSfx('contador.mp3');
    });

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
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
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
        AudioManager().playGameBgm('musica_lvl5.mp3');
        setState(() {
          _isCountingDown = false;
          _game.player.startBehavior();
          _game.startSequence();
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
          child: Icon(Icons.arrow_upward, color: Colors.white, size: 40),
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
                  return Container(color: Colors.black);
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
                // Score display
                Positioned(
                  top: 20,
                  left: 20,
                  child: StreamBuilder<void>(
                    stream: Stream.periodic(const Duration(milliseconds: 100)),
                    builder: (context, snapshot) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFFFD700),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          'SCORE: ${_game.score}',
                          style: GoogleFonts.orbitron(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFD700),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Round counter
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: StreamBuilder<void>(
                      stream: Stream.periodic(
                        const Duration(milliseconds: 100),
                      ),
                      builder: (context, snapshot) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B00FF).withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Text(
                            'RONDA ${_game.currentRound}',
                            style: GoogleFonts.orbitron(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Hit counter (progress to next wave)
                Positioned(
                  top: 70,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: StreamBuilder<void>(
                      stream: Stream.periodic(
                        const Duration(milliseconds: 100),
                      ),
                      builder: (context, snapshot) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00FF41).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Text(
                            'GOLPES: ${_game.hitsThisWave}/15',
                            style: GoogleFonts.orbitron(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
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
                // Ability Widget - shows unlocked abilities
                AbilityWidget(game: _game),
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
