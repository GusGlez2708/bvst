import 'dart:async';
import 'package:bvst/game/audio_manager.dart';
import 'package:bvst/game/battle_game.dart';
import 'package:bvst/game/bullet.dart';
import 'package:bvst/game/enemy.dart';
import 'package:bvst/game/enemy_lvl1.dart';
import 'package:bvst/game/enemy_lvl2.dart';
import 'package:bvst/game/enemy_lvl3.dart';
import 'package:bvst/game/enemy_lvl4.dart';
import 'package:bvst/game/enemy_lvl5.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BattleGameInfinite extends BattleGame {
  late SpriteComponent _background;

  int score = 0;
  int currentRound = 1;
  int hitsThisWave = 0; // Track hits instead of deaths
  static const int hitsPerWave = 15; // 15 hits to advance wave
  List<Enemy> activeEnemies = [];
  double speedMultiplier = 1.0;
  double fireRateMultiplier = 1.0;
  bool _isTransitioning = false;
  bool _localGameOver =
      false; // Local flag since parent's _isGameOver is private

  BattleGameInfinite({required super.onGameOver});

  @override
  Future<void> onLoad() async {
    // Call parent onLoad but we'll manage enemies differently
    await super.onLoad();

    // Disable enemy health bar for infinite mode
    showEnemyHealthBar = false;

    // Setup static Background - always use level 5 background
    _background = SpriteComponent()
      ..sprite = await loadSprite('fondo_lvl5.png')
      ..size = size
      ..position = Vector2.zero()
      ..priority = -10;
    add(_background);

    // Remove default enemy from parent
    remove(enemy);

    // We'll spawn first enemy after startSequence is called
  }

  void startSequence() {
    // Start background music
    AudioManager().playGameBgm('musica_lvl5.mp3');

    // Spawn first wave (Boss 1)
    _spawnWave();
  }

  void _spawnWave() {
    _isTransitioning = false;

    // Clear any existing enemies
    for (var enemy in activeEnemies) {
      if (enemy.isMounted) {
        remove(enemy);
      }
    }
    activeEnemies.clear();

    // Determine which bosses to spawn based on currentRound
    List<int> bossesToSpawn = _getBossesForRound(currentRound);

    print(
      '🎮 Infinite Mode - Round $currentRound: Spawning bosses $bossesToSpawn',
    );

    // Spawn enemies
    for (int i = 0; i < bossesToSpawn.length; i++) {
      int bossLevel = bossesToSpawn[i];
      Enemy newEnemy = _createEnemy(bossLevel);

      // Position enemies horizontally
      double xPosition = _getEnemyPosition(i, bossesToSpawn.length);
      newEnemy.position.x = xPosition;

      // Set health to 15
      newEnemy.health = 15;
      newEnemy.maxHealth = 15;

      // Apply current multipliers
      newEnemy.speedMultiplier = speedMultiplier;
      newEnemy.fireRateMultiplier = fireRateMultiplier;

      activeEnemies.add(newEnemy);
      add(newEnemy);

      // Start enemy behavior
      Future.delayed(const Duration(milliseconds: 100), () {
        if (newEnemy.isMounted) {
          newEnemy.startBehavior();
        }
      });
    }

    // Update the main enemy reference to first active enemy
    if (activeEnemies.isNotEmpty) {
      enemy = activeEnemies.first;
    }
  }

  List<int> _getBossesForRound(int round) {
    if (round <= 5) {
      // Rounds 1-5: Single bosses
      return [round];
    } else if (round == 6) {
      // Round 6: Boss 1 + 2
      return [1, 2];
    } else if (round == 7) {
      // Round 7: Boss 1 + 2 + 3
      return [1, 2, 3];
    } else if (round == 8) {
      // Round 8: Boss 1 + 2 + 3 + 4
      return [1, 2, 3, 4];
    } else {
      // Round 9+: All 5 bosses
      return [1, 2, 3, 4, 5];
    }
  }

  Enemy _createEnemy(int level) {
    switch (level) {
      case 1:
        return EnemyLevel1();
      case 2:
        return EnemyLevel2();
      case 3:
        return InfiniteEnemyLevel3(); // Special version for infinite mode
      case 4:
        return EnemyLevel4();
      case 5:
        return EnemyLevel5();
      default:
        return EnemyLevel1();
    }
  }

  double _getEnemyPosition(int index, int total) {
    if (total == 1) {
      return size.x / 2;
    } else if (total == 2) {
      return size.x * (index == 0 ? 0.33 : 0.67);
    } else if (total == 3) {
      return size.x * (0.25 + (index * 0.25));
    } else if (total == 4) {
      return size.x * (0.2 + (index * 0.2));
    } else {
      // 5 enemies
      return size.x * (1.0 / 6.0 + (index * 1.0 / 6.0));
    }
  }

  void onEnemyHit() {
    score += 10;
    hitsThisWave++; // Increment hit counter
    speedMultiplier += 0.1; // 10% speed increase per hit (more noticeable)
    fireRateMultiplier += 0.05; // 5% fire rate increase per hit

    // Apply multipliers to all active enemies
    for (var enemy in activeEnemies) {
      if (enemy.isMounted) {
        enemy.speedMultiplier = speedMultiplier;
        enemy.fireRateMultiplier = fireRateMultiplier;
        enemy.updateMultipliers(); // Update speed and fire rate
      }
    }

    print(
      '💥 Hit! Score: $score, Hits: $hitsThisWave/$hitsPerWave, Speed: ${(speedMultiplier * 100).toStringAsFixed(0)}%, Fire Rate: ${(fireRateMultiplier * 100).toStringAsFixed(0)}%',
    );

    // Check if we've reached 15 hits
    if (hitsThisWave >= hitsPerWave) {
      _advanceWave();
    }
  }

  void _advanceWave() {
    if (_isTransitioning) return;

    _isTransitioning = true;
    hitsThisWave = 0; // Reset hit counter
    currentRound++;

    print('🏆 Wave complete! Moving to round $currentRound');

    // Clear current enemies
    for (var enemy in activeEnemies) {
      if (enemy.isMounted) {
        remove(enemy);
      }
    }
    activeEnemies.clear();

    // Spawn next wave after a brief delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!_localGameOver) {
        _spawnWave();
      }
    });
  }

  void onEnemyDefeated(Enemy defeatedEnemy) {
    // In the new system, enemies don't trigger wave changes when defeated
    // They respawn or continue until 15 hits are reached
    // Just remove from active list
    activeEnemies.remove(defeatedEnemy);
    print('🎯 Enemy defeated but wave continues until $hitsPerWave hits');
  }

  @override
  void checkWinCondition() {
    if (_localGameOver) return;

    // Check player death
    if (player.health <= 0) {
      _localGameOver = true;
      onGameOver(false);
      return;
    }

    // Check if any enemy is defeated (for coin rewards)
    List<Enemy> defeatedEnemies = [];
    for (var enemy in activeEnemies) {
      if (enemy.health <= 0) {
        defeatedEnemies.add(enemy);
      }
    }

    // Process defeated enemies
    for (var enemy in defeatedEnemies) {
      onEnemyDefeated(enemy);
    }

    // Infinite mode never "wins" - it continues based on hit count
  }

  @override
  void render(Canvas canvas) {
    // Call parent render to draw all components (background, enemies, player, etc.)
    super.render(canvas);

    // Health bar is already disabled via showEnemyHealthBar = false
    // Player hearts are rendered by parent
  }
}

// Special version of EnemyLevel3 for infinite mode that doesn't split
class InfiniteEnemyLevel3 extends Enemy {
  bool _hasShotThisCycle = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final spriteSheet = await game.images.load('Enemy_lvl3_sprite.png');
    final spriteSize = Vector2(
      spriteSheet.width / 5,
      spriteSheet.height.toDouble(),
    );

    animation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 5,
        stepTime: 0.3,
        textureSize: spriteSize,
      ),
    );

    double newHeight = game.size.y * 0.25; // Smaller for multiple enemies
    double newWidth = (spriteSize.x / spriteSize.y) * newHeight;
    size = Vector2(newWidth, newHeight);

    position = Vector2(game.size.x / 2, size.y / 2 + 50);

    shootTimer.stop();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (direction == 1) {
      scale.x = 1;
    } else {
      scale.x = -1;
    }

    // Sync shooting with animation
    if (canShoot && animationTicker != null) {
      if (animationTicker!.currentIndex == 4 && !_hasShotThisCycle) {
        shoot();
        _hasShotThisCycle = true;
      }

      if (animationTicker!.currentIndex == 0) {
        _hasShotThisCycle = false;
      }
    }
  }

  @override
  void shoot() {
    if (!canShoot) return;
    AudioManager().playGameSfx('FireUnder.mp3');
    final bullet = Bullet(
      isPlayerBullet: false,
      position: position + Vector2(0, size.y / 2),
      customSpritePath: 'ataque_lvl3.png',
    );
    game.add(bullet);
  }

  @override
  void triggerEnrage() {
    // No enrage/split in infinite mode
    isEnraged = true;
    speed = speed * 1.5; // Just increase speed instead
  }
}
