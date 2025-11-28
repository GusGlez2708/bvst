import 'dart:async';
import 'package:bvst/game/audio_manager.dart';
import 'package:bvst/game/battle_game_lvl4.dart';
import 'package:bvst/game/dialogue_system.dart';
import 'package:bvst/screens/pause_menu.dart';
import 'package:bvst/widgets/ability_widget.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bvst/services/ad_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GameScreenLevel4 extends StatefulWidget {
  const GameScreenLevel4({super.key});

  @override
  State<GameScreenLevel4> createState() => _GameScreenLevel4State();
}

class _GameScreenLevel4State extends State<GameScreenLevel4> with WidgetsBindingObserver {
  int _countdown = 1;
  Timer? _timer;
  bool _isCountingDown = false; 
  late final BattleGameLevel4 _game;
  bool _isPaused = false;
  bool _isInDialogue = false;
  List<DialogueLine>? _currentDialogueLines;
  VoidCallback? _currentDialogueOnFinished;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _game = BattleGameLevel4(
      onGameOver: (hasWon) {
        if (mounted) {
          _game.pauseEngine();
          AudioManager().stopAllPooledSfx();
          AudioManager().stopGameBgm();

          if (hasWon) {
            _showOutroDialogue();
          } else {
            AudioManager().playUiSfx('defeat.mp3');
            Navigator.pushReplacementNamed(
              context,
              '/result',
              arguments: {'hasWon': hasWon, 'currentLevel': 4},
            );
          }
        }
      },
    );
    
    // Initialize dialogue state directly
    _isInDialogue = true;
    _currentDialogueLines = DialogueData.getIntroForLevel(4);
    _currentDialogueOnFinished = _onIntroDialogueFinished;
    
    AdService().loadBanner();
  }

  void _showOutroDialogue() {
    setState(() {
      _isInDialogue = true;
      _currentDialogueLines = DialogueData.getOutroForLevel(4);
      _currentDialogueOnFinished = _onOutroDialogueFinished;
    });
  }

  void _onIntroDialogueFinished() {
    setState(() {
      _isInDialogue = false;
      _currentDialogueLines = null;
      _currentDialogueOnFinished = null;
      _isCountingDown = true; 
    });
    _startCountdown();
    Future.delayed(const Duration(milliseconds: 100), () {
      AudioManager().playUiSfx('contador.mp3');
    });
  }

  void _onOutroDialogueFinished() {
    setState(() {
      _isInDialogue = false;
      _currentDialogueLines = null;
      _currentDialogueOnFinished = null;
    });
    
    AudioManager().playUiSfx('victory.mp3');
    Navigator.pushReplacementNamed(
      context,
      '/result',
      arguments: {'hasWon': true, 'currentLevel': 4},
    );
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
      if (!_isPaused && !_isCountingDown && !_isInDialogue) {
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
        AudioManager().playGameBgm('musica_lvl4.mp3'); 
        setState(() {
          _isCountingDown = false;
          _game.player.startBehavior();
          _game.enemy.startBehavior();
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
          child: Icon(
            Icons.swap_horiz,
            color: Colors.white,
            size: 40,
          ),
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
        if (!_isPaused && !_isCountingDown && !_isInDialogue) {
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
                    color: Colors.black,
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
              if (!_isCountingDown && !_isPaused && !_isInDialogue) ...[
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
              if (_isInDialogue && _currentDialogueLines != null && _currentDialogueOnFinished != null)
                DialogueOverlay(
                  lines: _currentDialogueLines!,
                  onFinished: _currentDialogueOnFinished!,
                ),
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
