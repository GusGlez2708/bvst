import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:bvst/game/audio_manager.dart';
import 'package:bvst/game/battle_game.dart';
import 'package:bvst/game/enemy_lvl3.dart';
import 'package:flame/components.dart';

class BattleGameLevel3 extends BattleGame {
  late Timer _powerTimer;
  bool _powerActive = false;
  double _normalPlayerSpeed = 0.0;
  bool _firstPowerActivated = false;
  AudioPlayer? _powerAudioPlayer;

  BattleGameLevel3({required super.onGameOver});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Remove the default enemy
    remove(enemy);

    // Add Level 3 Enemy
    enemy = EnemyLevel3();
    add(enemy);

    // Setup Power Timer - first activation at 5 seconds
    _powerTimer = Timer(5.0, onTick: _activatePower, repeat: false);
    _powerTimer.start();
  }

  void _activatePower() async {
    if (enemy.health <= 0 || player.health <= 0) return;

    _powerActive = true;
    _firstPowerActivated = true;

    // Store player's normal speed
    if (_normalPlayerSpeed == 0.0) {
      _normalPlayerSpeed = player.speed;
    }

    // Slow down player (reduce speed to 40% of normal)
    player.speed = _normalPlayerSpeed * 0.4;

    // Pause background music
    AudioManager().pauseGameBgm();

    // Play power audio
    _powerAudioPlayer = AudioPlayer();
    await _powerAudioPlayer!.play(AssetSource('audio/poder_lvl3.mp3'));

    // Listen for when audio completes
    _powerAudioPlayer!.onPlayerComplete.listen((_) {
      _deactivatePower();
    });
  }

  void _deactivatePower() {
    if (!_powerActive) return;

    _powerActive = false;

    // Restore player's normal speed
    player.speed = _normalPlayerSpeed;

    // Resume background music
    AudioManager().resumeGameBgm();

    // Dispose audio player
    _powerAudioPlayer?.dispose();
    _powerAudioPlayer = null;

    // Set cooldown timer of 12 seconds before next power
    _powerTimer = Timer(12.0, onTick: _activatePower, repeat: false);
    _powerTimer.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _powerTimer.update(dt);
  }

  @override
  void onRemove() {
    _powerAudioPlayer?.dispose();
    super.onRemove();
  }
}
