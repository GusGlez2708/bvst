import 'package:bvst/game/bullet.dart';
import 'package:bvst/game/enemy.dart';
import 'package:flame/components.dart';
import 'package:bvst/game/audio_manager.dart';
import 'package:flame/collisions.dart';

class EnemyLevel4 extends Enemy {
  @override
  Future<void> onLoad() async {
    // Call super to initialize basic Enemy properties (health, timer logic)
    await super.onLoad();

    // Override animation with Level 4 sprite
    final sprite = await Sprite.load('enemigo_lvl4.png');
    final spriteSize = sprite.srcSize;

    // Use single sprite as animation
    animation = SpriteAnimation.spriteList([sprite], stepTime: 1.0);

    // Override size
    double newHeight = game.size.y * 0.25;
    double newWidth = (spriteSize.x / spriteSize.y) * newHeight;
    size = Vector2(newWidth, newHeight);

    // Override position
    position = Vector2(game.size.x / 2, size.y / 2 + 50);
  }

  @override
  void shoot() {
    if (!canShoot) return;
    AudioManager().playGameSfx('FireUnder.mp3');
    final bullet = Bullet(
      isPlayerBullet: false,
      position: position + Vector2(0, size.y / 2),
      customSpritePath: 'ataque_lvl4.png', // Level 4 projectile
    );
    game.add(bullet);
  }
}
