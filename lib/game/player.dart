import 'package:bvst/game/battle_game.dart';
import 'package:bvst/game/bullet.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Player extends SpriteComponent with HasGameRef<BattleGame>, CollisionCallbacks {
  int health = 3;
  bool isMovingLeft = false;
  bool isMovingRight = false;
  double _speed = 0.0;
  late Timer _shootCooldown;
  bool _canShoot = true;

  Player() : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    sprite = await Sprite.load('personaje.png');
    
    double newHeight = gameRef.size.y * 0.18;
    double newWidth = (sprite!.originalSize.x / sprite!.originalSize.y) * newHeight;
    size = Vector2(newWidth, newHeight);
    
    position = Vector2(gameRef.size.x / 2, gameRef.size.y - (size.y / 2) - 20);
    add(RectangleHitbox());
    _shootCooldown = Timer(0.5, onTick: () => _canShoot = true);
  }

  void startBehavior() {
    _speed = 300.0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _shootCooldown.update(dt);

    if (isMovingLeft) {
      position.x -= _speed * dt;
    }
    if (isMovingRight) {
      position.x += _speed * dt;
    }

    // Clamp position to stay within screen bounds
    position.x = position.x.clamp(size.x / 2, gameRef.size.x - size.x / 2);
  }

  void shoot() {
    if (_canShoot) {
      final bullet = Bullet(
        isPlayerBullet: true,
        position: position + Vector2(0, -size.y / 2),
      );
      gameRef.add(bullet);
      _canShoot = false;
      _shootCooldown.start();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Bullet && !other.isPlayerBullet) {
      health--;
      other.removeFromParent();
      gameRef.checkWinCondition();
    }
  }
}
