import 'package:bvst/game/bullet.dart';
import 'package:bvst/game/enemy.dart';
import 'package:flame/components.dart';
import 'package:bvst/game/audio_manager.dart';
import 'package:flame/collisions.dart';

class EnemyLevel2 extends Enemy {
  @override
  Future<void> onLoad() async {
    // Call super to initialize basic Enemy properties (health, timer logic)
    // Note: This will load 'enemigo.png' briefly, but we immediately override it.
    await super.onLoad();

    // Override animation with Level 2 sprite sheet
    final spriteSheet = await game.images.load('Enemy_lvl2_sprite.png');
    final spriteSize = Vector2(
      spriteSheet.width / 5,
      spriteSheet.height.toDouble(),
    );

    animation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 5,
        stepTime: 0.2,
        textureSize: spriteSize,
      ),
    );

    // Override size
    double newHeight = game.size.y * 0.20;
    double newWidth = (spriteSize.x / spriteSize.y) * newHeight;
    size = Vector2(newWidth, newHeight);

    // Override position
    position = Vector2(game.size.x / 2, size.y / 2 + 50);

    // Ensure hitbox matches new size (Enemy adds one, but we resized)
    // Removing old hitboxes to be safe and adding a new one is cleaner,
    // but RectangleHitbox usually adapts to component size.
    // Let's assume it adapts.
  }

  @override
  void shoot() {
    if (!canShoot) return;
    AudioManager().playGameSfx('FireUnder.mp3');
    final bullet = Bullet(
      isPlayerBullet: false,
      position: position + Vector2(0, size.y / 2),
      customSpritePath: 'Fuego_Sprite.png',
    );
    game.add(bullet);
  }
}
