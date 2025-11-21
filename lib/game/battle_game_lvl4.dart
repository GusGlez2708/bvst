import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:bvst/game/audio_manager.dart';
import 'package:bvst/game/battle_game.dart';
import 'package:bvst/game/enemy_lvl4.dart';
import 'package:flame/components.dart';

class BattleGameLevel4 extends BattleGame {
  late Timer _powerTimer;
  bool _powerActive = false;
  bool _firstPowerActivated = false;
  AudioPlayer? _powerAudioPlayer;
  StreamSubscription? _powerCompleteSubscription;

  BattleGameLevel4({required super.onGameOver});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Remove the default enemy
    remove(enemy);

    // Add Level 4 Enemy
    enemy = EnemyLevel4();
    add(enemy);

    // Setup Power Timer - first activation at 5 seconds
    _powerTimer = Timer(5.0, onTick: _activatePower, repeat: false);
    _powerTimer.start();
  }

  void _activatePower() async {
    if (enemy.health <= 0 || player.health <= 0) return;

    _powerActive = true;
    _firstPowerActivated = true;

    // Apply weakening effect - double damage
    player.damageMultiplier = 2.0;

    // Pause background music
    AudioManager().pauseGameBgm();

    // Play power audio (determines duration)
    _powerAudioPlayer = AudioPlayer();
    await _powerAudioPlayer!.play(AssetSource('audio/poder_lvl4.mp3'));

    // Listen for when power audio completes (only once)
    _powerCompleteSubscription = _powerAudioPlayer!.onPlayerComplete.listen((_) {
      _deactivatePower();
    });
  }

  void _deactivatePower() async {
    if (!_powerActive) return;

    _powerActive = false;

    // Cancel subscription first
    await _powerCompleteSubscription?.cancel();
    _powerCompleteSubscription = null;

    // Dispose power audio player
    if (_powerAudioPlayer != null) {
      await _powerAudioPlayer!.dispose();
      _powerAudioPlayer = null;
    }

    // Remove weakening effect - restore normal damage
    player.damageMultiplier = 1.0;

    // Resume background music
    AudioManager().resumeGameBgm();

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
    _powerCompleteSubscription?.cancel();
    _powerAudioPlayer?.dispose();
    super.onRemove();
  }
}
