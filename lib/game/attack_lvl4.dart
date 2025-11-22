import 'package:bvst/game/battle_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class AttackLevel4 extends SpriteComponent with HasGameRef<BattleGame>, CollisionCallbacks {
  final Vector2 velocity;

  AttackLevel4({required Vector2 position, required this.velocity})
      : super(
          position: position,
          size: Vector2(40, 40), // Adjust size as needed
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('ataque_lvl4.png');
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;

    // Remove if off screen
    if (position.y > gameRef.size.y ||
        position.y < -100 || // Allow spawning above screen
        position.x > gameRef.size.x ||
        position.x < 0) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other == gameRef.player) {
      gameRef.player.takeDamage(1); // Reduced damage to 1
      removeFromParent();
    }
  }
}
