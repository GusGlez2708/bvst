import 'package:bvst/game/bullet.dart';
import 'package:bvst/game/enemy.dart';
import 'package:flame/components.dart';
import 'package:bvst/game/audio_manager.dart';
import 'package:flame/collisions.dart';

class EnemyLevel3 extends Enemy {
  bool _hasShotThisCycle = false;

  @override
  Future<void> onLoad() async {
    // Call super to initialize basic Enemy properties (health, timer logic)
    await super.onLoad();

    // Override animation with Level 3 sprite sheet (5 frames)
    // Note: User confirmed image is 'Enemy_lvl3_sprite.png'
    final spriteSheet = await game.images.load('Enemy_lvl3_sprite.png');
    final spriteSize = Vector2(
      spriteSheet.width / 5,
      spriteSheet.height.toDouble(),
    );

    animation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 5,
        stepTime: 0.3, // Adjust speed as needed
        textureSize: spriteSize,
      ),
    );

    // Override size
    double newHeight = game.size.y * 0.25;
    double newWidth = (spriteSize.x / spriteSize.y) * newHeight;
    size = Vector2(newWidth, newHeight);

    // Override position
    position = Vector2(game.size.x / 2, size.y / 2 + 50);

    // Disable default timer-based shooting, we will sync with animation
    shootTimer.stop();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Flip sprite based on direction
    if (direction == 1) {
      scale.x = 1; // Face right
    } else {
      scale.x = -1; // Face left
    }

    // Sync shooting with animation
    // We want to shoot when the animation reaches the last frame (index 4)
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
      customSpritePath: 'ataque_lvl3.png', // Level 3 projectile
    );
    game.add(bullet);
  }

  @override
  void triggerEnrage() {
    isEnraged = true;
    speed = speed * 2;

    // Speed up animation to match increased fire rate
    if (animation != null) {
      animation!.stepTime = 0.15; // Double speed (0.3 -> 0.15)
    }
    
    print('🔥 BOSS LEVEL 3 ENRAGED! Animation speed DOUBLED! 🔥');
  }
}
