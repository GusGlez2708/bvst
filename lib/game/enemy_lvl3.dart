import 'package:bvst/game/bullet.dart';
import 'package:bvst/game/enemy.dart';
import 'package:bvst/game/battle_game.dart';
import 'package:flame/components.dart';
import 'package:bvst/game/audio_manager.dart';
import 'package:flame/collisions.dart';
import 'package:bvst/game/collision_particle.dart';
import 'package:bvst/game/game_state.dart';
import 'package:flutter/material.dart';

// Shared health manager for split enemies
class SharedHealth {
  int health;
  int maxHealth;

  SharedHealth(this.health, this.maxHealth);
}

class EnemyLevel3 extends Enemy {
  bool _hasShotThisCycle = false;
  bool _hasSplit = false;

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

    double newHeight = game.size.y * 0.40;
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

    // Check if should split
    if (!isEnraged && health <= maxHealth / 2 && health > 0 && !_hasSplit) {
      _performSplit();
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

  void _performSplit() {
    _hasSplit = true;
    isEnraged = true;

    print('💥 BOSS LEVEL 3 SPLITTING! Shared health: $health');

    // Create shared health object
    final sharedHealth = SharedHealth(health, maxHealth);

    // Create two split enemies with shared health
    final splitEnemy1 = SplitEnemyLevel3(
      startPosition: position.clone(),
      movingRight: true,
      sharedHealth: sharedHealth,
    );

    final splitEnemy2 = SplitEnemyLevel3(
      startPosition: position.clone(),
      movingRight: false,
      sharedHealth: sharedHealth,
    );

    // Link enemies together
    splitEnemy1.sibling = splitEnemy2;
    splitEnemy2.sibling = splitEnemy1;

    // Add split enemies to game
    game.add(splitEnemy1);
    game.add(splitEnemy2);

    // Start their behavior
    Future.delayed(const Duration(milliseconds: 100), () {
      splitEnemy1.startBehavior();
      splitEnemy2.startBehavior();
    });

    // Remove original enemy
    removeFromParent();
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
    // Replaced by split mechanism
  }
}

// Split enemy class with shared health
class SplitEnemyLevel3 extends SpriteAnimationComponent
    with HasGameReference<BattleGame>, CollisionCallbacks {
  final Vector2 startPosition;
  final bool movingRight;
  final SharedHealth sharedHealth;

  SplitEnemyLevel3? sibling;

  double speed = 250.0; // Faster speed
  int direction = 1;
  Timer shootTimer = Timer(1.0);
  bool canShoot = false;
  bool _hasShotThisCycle = false;

  SplitEnemyLevel3({
    required this.startPosition,
    required this.movingRight,
    required this.sharedHealth,
  }) : super(anchor: Anchor.center);

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
        stepTime: 0.2, // Faster animation
        textureSize: spriteSize,
      ),
    );

    double newHeight = game.size.y * 0.28;
    double newWidth = (spriteSize.x / spriteSize.y) * newHeight;
    size = Vector2(newWidth, newHeight);

    position = startPosition.clone();
    direction = movingRight ? 1 : -1;

    add(RectangleHitbox());
    shootTimer.stop();
  }

  void startBehavior() {
    canShoot = true;
    print('✅ Split enemy ready! Shared health: ${sharedHealth.health}');
  }

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
  void update(double dt) {
    super.update(dt);

    if (direction == 1) {
      scale.x = 1;
    } else {
      scale.x = -1;
    }

    position.x += speed * direction * dt;

    if (position.x <= size.x / 2 || position.x >= game.size.x - size.x / 2) {
      direction *= -1;
    }

    position.x = position.x.clamp(size.x / 2, game.size.x - size.x / 2);

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
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Bullet && other.isPlayerBullet) {
      AudioManager().playGameSfx('damage_ene.mp3');

      sharedHealth.health--;
      other.removeFromParent();

      final particle = CollisionParticle(
        position: position.clone(),
        color: const Color(0xFFFF6600),
      );
      game.add(particle);

      print(
        '💥 Hit! Shared health: ${sharedHealth.health}/${sharedHealth.maxHealth}',
      );

      if (sharedHealth.health <= 0) {
        final gameState = GameState();
        gameState.addCoins(GameState.coinsPerEnemyKill);
        print(
          '🎯 Both split enemies defeated! Awarded ${GameState.coinsPerEnemyKill} coins',
        );

        if (sibling != null && sibling!.isMounted) {
          sibling!.removeFromParent();
        }
        removeFromParent();

        Future.delayed(const Duration(milliseconds: 50), () {
          game.checkWinCondition();
        });
      } else {
        game.checkWinCondition();
      }
    }
  }
}
