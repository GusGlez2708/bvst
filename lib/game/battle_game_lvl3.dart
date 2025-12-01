import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:bvst/game/audio_manager.dart';
import 'package:bvst/game/battle_game.dart';
import 'package:bvst/game/enemy.dart';
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

    // Setup Power Timer
    _powerTimer = Timer(5.0, onTick: _activatePower, repeat: false);
    _powerTimer.start();
  }

  void _activatePower() async {
    if (enemy.health <= 0 || player.health <= 0) return;

    _powerActive = true;
    _firstPowerActivated = true;

    if (_normalPlayerSpeed == 0.0) {
      _normalPlayerSpeed = player.speed;
    }

    player.speed = _normalPlayerSpeed * 0.4;

    AudioManager().pauseGameBgm();

    _powerAudioPlayer = AudioPlayer();
    await _powerAudioPlayer!.play(AssetSource('audio/poder_lvl3.mp3'));

    _powerAudioPlayer!.onPlayerComplete.listen((_) {
      _deactivatePower();
    });
  }

  void _deactivatePower() {
    if (!_powerActive) return;

    _powerActive = false;

    player.speed = _normalPlayerSpeed;

    AudioManager().resumeGameBgm();

    _powerAudioPlayer?.dispose();
    _powerAudioPlayer = null;

    _powerTimer = Timer(12.0, onTick: _activatePower, repeat: false);
    _powerTimer.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _powerTimer.update(dt);

    // Update enemy health reference for split enemies
    // This ensures the health bar shows the shared health
    _updateEnemyHealthReference();
  }

  void _updateEnemyHealthReference() {
    // Check if we have split enemies
    final splitEnemies = children.whereType<SplitEnemyLevel3>().toList();

    if (splitEnemies.isNotEmpty) {
      // Use the first split enemy's shared health as the enemy health reference
      final firstSplit = splitEnemies.first;
      enemy.health = firstSplit.sharedHealth.health;
      enemy.maxHealth = firstSplit.sharedHealth.maxHealth;
    }
  }

  @override
  void checkWinCondition() {
    // Count all enemies
    final allEnemies = children.whereType<Enemy>().toList();
    final splitEnemies = children.whereType<SplitEnemyLevel3>().toList();

    final totalEnemies = allEnemies.length + splitEnemies.length;

    if (totalEnemies == 0) {
      if (player.health > 0) {
        onGameOver(true);
      }
    } else if (player.health <= 0) {
      onGameOver(false);
    }
  }

  @override
  void onRemove() {
    _powerAudioPlayer?.dispose();
    super.onRemove();
  }
}
