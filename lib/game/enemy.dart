import 'dart:ui';
import 'package:bvst/game/battle_game.dart';
import 'package:bvst/game/bullet.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:bvst/game/audio_manager.dart';

class Enemy extends SpriteComponent with HasGameReference<BattleGame>, CollisionCallbacks {
  int health = 15;
  late int maxHealth;
  double speed = 0.0;
  int direction = 1;
  late Timer _shootTimer;
  bool canShoot = false;

  Enemy() : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await Sprite.load('enemigo.png');
    maxHealth = health;

    double newHeight = game.size.y * 0.18;
    double newWidth = (sprite!.originalSize.x / sprite!.originalSize.y) * newHeight;
    size = Vector2(newWidth, newHeight);

    position = Vector2(game.size.x / 2, size.y / 2 + 50);
    add(RectangleHitbox());

    _shootTimer = Timer(1.5, onTick: _shoot, repeat: true);
  }

  void _shoot() {
    if (!canShoot) return;
    AudioManager().playGameSfx('drop.mp3');
    final bullet = Bullet(
      isPlayerBullet: false,
      position: position + Vector2(0, size.y / 2),
    );
    game.add(bullet);
  }

  void startBehavior() {
    canShoot = true;
    speed = 200.0;
    _shootTimer.start();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint();
    final healthPercentage = health / maxHealth;

    // The canvas origin (0,0) is the top-left of the component's bounding box.
    // The sprite is drawn centered within this box because of `anchor: Anchor.center`.
    // We draw the health bar relative to the top-left origin.
    const barHeight = 10.0;
    const barTop = -barHeight - 5; // 5 pixels above the component's bounding box

    // Health bar background
    final backgroundRect = Rect.fromLTWH(0, barTop, size.x, barHeight);
    paint.color = const Color(0xFF000000);
    canvas.drawRect(backgroundRect, paint);

    // Health bar foreground
    final healthRect = Rect.fromLTWH(0, barTop, size.x * healthPercentage, barHeight);
    final healthColor = Color.lerp(const Color(0xFFFF0000), const Color(0xFF00FF00), healthPercentage);
    paint.color = healthColor!;
    canvas.drawRect(healthRect, paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _shootTimer.update(dt);

    position.x += speed * direction * dt;

    if (position.x <= size.x / 2 || position.x >= game.size.x - size.x / 2) {
      direction *= -1;
    }
    
    position.x = position.x.clamp(size.x / 2, game.size.x - size.x / 2);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Bullet && other.isPlayerBullet) {
      AudioManager().playGameSfx('damage_ene.mp3');
      health--;
      other.removeFromParent();
      game.checkWinCondition();
    }
  }
}
