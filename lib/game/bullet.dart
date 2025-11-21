import 'package:bvst/game/battle_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Bullet extends SpriteAnimationComponent
    with HasGameReference<BattleGame>, CollisionCallbacks {
  final bool isPlayerBullet;
  final double _speed = 400.0;

  final String? customSpritePath;

  Bullet({
    required this.isPlayerBullet,
    required Vector2 position,
    this.customSpritePath,
  }) : super(position: position, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    String spritePath =
        customSpritePath ??
        (isPlayerBullet ? 'bala_personaje.png' : 'bala_enemigo.png');

    if (spritePath == 'Fuego_Sprite.png') {
      final spriteSheet = await game.images.load(spritePath);
      final spriteSize = Vector2(
        spriteSheet.width / 3,
        spriteSheet.height.toDouble(),
      );

      animation = SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: 0.1,
          textureSize: spriteSize,
        ),
      );

      // Adjust size for animation - larger for enemies
      double newHeight = game.size.y * 0.09; // Increased from 0.06 for bigger projectiles
      double newWidth = (spriteSize.x / spriteSize.y) * newHeight;
      size = Vector2(newWidth, newHeight);
    } else {
      // Static sprite (1 frame animation)
      final sprite = await Sprite.load(spritePath);
      animation = SpriteAnimation.spriteList([sprite], stepTime: 1.0);

      // Make enemy projectiles bigger for levels 2 and 3
      double newHeight;
      if (spritePath == 'ataque_lvl3.png' && !isPlayerBullet) {
        newHeight = game.size.y * 0.08; // Larger for level 3 enemy projectiles
      } else {
        newHeight = game.size.y * 0.04; // Default size
      }
      double newWidth =
          (sprite.originalSize.x / sprite.originalSize.y) * newHeight;
      size = Vector2(newWidth, newHeight);
    }

    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isPlayerBullet) {
      position.y -= _speed * dt;
    } else {
      position.y += _speed * dt;
    }

    if (position.y < 0 || position.y > game.size.y) {
      removeFromParent();
    }
  }
}
