import 'package:bvst/game/bullet.dart';
import 'package:bvst/game/enemy.dart';
import 'package:flame/components.dart';
import 'package:bvst/game/audio_manager.dart';

class EnemyLevel1 extends Enemy {
  @override
  Future<void> onLoad() async {
    // Call super to initialize basic properties
    await super.onLoad();

    // Override animation with Level 1 sprite sheet (3 frames)
    final spriteSheet = await game.images.load('Enemy_lvl1_sprite.png');
    final spriteSize = Vector2(
      spriteSheet.width / 3,
      spriteSheet.height.toDouble(),
    );

    animation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.5, // Slower animation initially (1.5s total cycle)
        textureSize: spriteSize,
      ),
    );

    // Override size (keep it similar to original or adjust as needed)
    double newHeight = game.size.y * 0.20; // Slightly larger than static
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
    // We want to shoot when the animation reaches the last frame (index 2)
    if (canShoot && animationTicker != null) {
      // Check if we just entered the last frame
      if (animationTicker!.currentIndex == 2 && !animationTicker!.isLastFrame) {
         // This logic is tricky because update runs every frame. 
         // We need to ensure we shoot only ONCE per cycle.
         // A better way is to listen to frame changes or check if clock reset.
      }
      
      // Alternative: Use the timer to reset the animation cycle?
      // Or better: Just use the timer to trigger the shoot, and reset animation to frame 0?
      
      // Let's stick to the plan: Sync shooting with animation.
      // If we use the timer to drive the shoot, we can restart the animation on shoot.
      
      // Actually, the user wants: "cuando este en el ultimo se coordine en el disparo"
      // So the animation DRIVES the shooting.
      
      if (animationTicker!.currentIndex == 2 && !_hasShotThisCycle) {
        shoot();
        _hasShotThisCycle = true;
      }
      
      if (animationTicker!.currentIndex == 0) {
        _hasShotThisCycle = false;
      }
    }
  }
  
  bool _hasShotThisCycle = false;

  @override
  void triggerEnrage() {
    isEnraged = true;
    speed = speed * 2;

    // Speed up animation to match increased fire rate
    // Normal: 1.5s cycle (0.5s per frame)
    // Enraged: 0.75s cycle (0.25s per frame)
    if (animation != null) {
      animation!.stepTime = 0.25;
    }
    
    print('🔥 BOSS LEVEL 1 ENRAGED! Animation speed DOUBLED! 🔥');
  }
}
