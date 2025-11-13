import 'package:bvst/game/battle_game.dart';
import 'package:bvst/game/bullet.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';

class Player extends SpriteComponent with HasGameReference<BattleGame>, CollisionCallbacks {
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
    
    double newHeight = game.size.y * 0.25;
    double newWidth = (sprite!.originalSize.x / sprite!.originalSize.y) * newHeight;
    size = Vector2(newWidth, newHeight);
    
    position = Vector2(game.size.x / 2, game.size.y - (size.y / 2) - 60);
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
    position.x = position.x.clamp(size.x / 2, game.size.x - size.x / 2);
  }

  void shoot() {
    if (_canShoot) {
      FlameAudio.play('laser.mp3');
      final bullet = Bullet(
        isPlayerBullet: true,
        position: position + Vector2(0, -size.y / 2),
      );
      game.add(bullet);
      _canShoot = false;
      _shootCooldown.start();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Bullet && !other.isPlayerBullet) {
      FlameAudio.play('damage_prota.mp3');
      health--;
      other.removeFromParent();
      game.checkWinCondition();
    }
  }
}
