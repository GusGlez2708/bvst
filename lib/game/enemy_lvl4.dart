import 'package:bvst/game/battle_game.dart';
import 'package:bvst/game/bullet.dart';
import 'package:bvst/game/enemy.dart';
import 'package:bvst/game/game_state.dart';
import 'package:bvst/game/audio_manager.dart';
import 'package:bvst/game/collision_particle.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class EnemyLevel4 extends Enemy {
  bool isVulnerable = false;
  late RectangleHitbox _headHitbox;

  EnemyLevel4() : super();

  @override
  Future<void> onLoad() async {
    // We don't call super.onLoad() because we don't want the default sprite/behavior
    // But we need to set up the basics
    
    // Set health for Level 4 boss
    health = 20; // Example high health
    maxHealth = health;

    // Size matches screen to cover the background area logic
    size = game.size;
    position = Vector2.zero();
    anchor = Anchor.topLeft;
    
    // Make it transparent
    // We need to set a dummy animation or sprite to avoid errors if the base class expects it
    // But since we are overriding render/update, it might be fine.
    // However, SpriteAnimationComponent needs an animation.
    // Let's just load a 1x1 transparent pixel or similar, or just use the default and hide it.
    final sprite = await Sprite.load('enemigo_lvl4.png'); // Load anything
    animation = SpriteAnimation.spriteList([sprite], stepTime: 1.0);
    paint.color = const Color(0x00000000); // Transparent

    // Define the hitbox for the head area based on the user's red circle
    // Assuming the boss is centered in the background
    double hitboxWidth = 200;
    double hitboxHeight = 80;
    double hitboxX = (game.size.x - hitboxWidth) / 2; 
    double hitboxY = game.size.y * 0.35; // Approx vertical position

    _headHitbox = RectangleHitbox(
      position: Vector2(hitboxX, hitboxY),
      size: Vector2(hitboxWidth, hitboxHeight),
      isSolid: true,
    );
    
    add(_headHitbox);
    _headHitbox.collisionType = CollisionType.passive;
  }

  @override
  void update(double dt) {
    // Do NOT call super.update(dt) to avoid default movement logic
    
    // Update hitbox status based on vulnerability
    if (isVulnerable) {
       _headHitbox.collisionType = CollisionType.passive; 
    } else {
       _headHitbox.collisionType = CollisionType.inactive; 
    }
  }
  
  @override
  void startBehavior() {
    // Override to do nothing, logic is controlled by BattleGameLevel4
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    // Custom collision logic
    if (other is Bullet && other.isPlayerBullet) {
      if (isVulnerable) {
        AudioManager().playGameSfx('damage_ene.mp3');
        health--;
        other.removeFromParent();

        // Spawn collision particles
        final particle = CollisionParticle(
          position: other.position.clone(), // Particle at bullet impact
          color: const Color(0xFFFF6600),
        );
        game.add(particle);

        if (health <= 0) {
          final gameState = GameState();
          gameState.addCoins(GameState.coinsPerEnemyKill * 5); // Boss bonus
          print('Boss Level 4 defeated!');
        }

        game.checkWinCondition();
      } else {
        // Bullet hits invulnerable boss - maybe play a "clank" sound or just remove bullet
        other.removeFromParent();
      }
    }
  }
}
