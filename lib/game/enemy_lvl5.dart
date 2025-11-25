import 'package:bvst/game/bullet.dart';
import 'package:bvst/game/enemy.dart';
import 'package:flame/components.dart';
import 'package:bvst/game/audio_manager.dart';
import 'package:flame/collisions.dart';

class EnemyLevel5 extends Enemy {
  bool _canMove = false; // Start as false, only move after startBehavior()
  bool _hasShotThisCycle = false;

  EnemyLevel5() : super();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Override health for final boss
    health = 25;
    maxHealth = health;

    // Load animated sprite sheet
    final spriteSheet = await game.images.load('move_enemigo_lvl5.png');
    final spriteSize = Vector2(
      spriteSheet.width / 5, // Assuming 5 frames
      spriteSheet.height.toDouble(),
    );

    animation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 5,
        stepTime: 0.15, // Faster animation (reduced from 0.3 to 0.15)
        textureSize: spriteSize,
      ),
    );

    // Override size - make boss smaller (reduced from 45% to 25%)
    double newHeight = game.size.y * 0.25;
    double newWidth = (spriteSize.x / spriteSize.y) * newHeight;
    size = Vector2(newWidth, newHeight);

    // Override position - centered at top
    position = Vector2(game.size.x / 2, size.y / 2 + 50);

    // Override movement settings
    speed = 220.0; // Movement speed (increased from 150 to 220)
    direction = 1; // Start moving right

    // Disable default timer-based shooting
    shootTimer.stop();
  }

  @override
  void update(double dt) {
    // Don't call super.update() to avoid any default enemy behavior
    // Only update animation ticker manually
    if (animationTicker != null) {
      if (_canMove) {
        // Only advance animation if we can move
        animationTicker!.update(dt);
      }
      // If can't move, don't update animation ticker (freeze animation)
    }

    // Only move if allowed (not during power, not during dialogue)
    if (_canMove) {
      // Horizontal movement
      position.x += direction * speed * dt;

      // Bounce at edges
      if (position.x <= size.x / 2) {
        position.x = size.x / 2;
        direction = 1;
      } else if (position.x >= game.size.x - size.x / 2) {
        position.x = game.size.x - size.x / 2;
        direction = -1;
      }

      // Flip sprite based on direction
      if (direction == 1) {
        scale.x = 1; // Face right
      } else {
        scale.x = -1; // Face left
      }

      // Sync shooting with animation (like Level 3)
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
  }

  @override
  void startBehavior() {
    canShoot = true;
    _canMove = true;
  }

  @override
  void shoot() {
    if (!canShoot || !_canMove) return;
    AudioManager().playGameSfx('FireUnder.mp3');
    final bullet = Bullet(
      isPlayerBullet: false,
      position: position + Vector2(0, size.y / 2),
      customSpritePath: 'ataque_lvl5.png',
    );
    game.add(bullet);
  }

  // Methods to control movement during power
  void stopMovement() {
    _canMove = false;
  }

  void resumeMovement() {
    _canMove = true;
  }

  void centerPosition() {
    position.x = game.size.x / 2;
    scale.x = 1; // Face forward
  }
}
