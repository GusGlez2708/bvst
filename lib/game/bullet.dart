import 'package:bvst/game/battle_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Bullet extends SpriteComponent with HasGameRef<BattleGame>, CollisionCallbacks {
  final bool isPlayerBullet;
  final double _speed = 400.0;

  Bullet({required this.isPlayerBullet, required Vector2 position})
      : super(
          position: position,
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await Sprite.load(
      isPlayerBullet ? 'bala_personaje.png' : 'bala_enemigo.png',
    );

    double newHeight = gameRef.size.y * 0.04;
    double newWidth = (sprite!.originalSize.x / sprite!.originalSize.y) * newHeight;
    size = Vector2(newWidth, newHeight);
    
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

    if (position.y < 0 || position.y > gameRef.size.y) {
      removeFromParent();
    }
  }
}
