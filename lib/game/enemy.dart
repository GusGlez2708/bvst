import 'dart:ui';
import 'package:bvst/game/battle_game.dart';
import 'package:bvst/game/bullet.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:bvst/game/audio_manager.dart';

class Enemy extends SpriteAnimationComponent
    with HasGameReference<BattleGame>, CollisionCallbacks {
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
    // Load static sprite as a 1-frame animation
    final sprite = await Sprite.load('enemigo.png');
    final spriteSize = sprite.srcSize;

    animation = SpriteAnimation.spriteList([sprite], stepTime: 1.0);

    maxHealth = health;

    double newHeight = game.size.y * 0.18;
    double newWidth = (spriteSize.x / spriteSize.y) * newHeight;
    size = Vector2(newWidth, newHeight);

    position = Vector2(game.size.x / 2, size.y / 2 + 50);
    add(RectangleHitbox());

    _shootTimer = Timer(1.5, onTick: shoot, repeat: true);
  }

  void shoot() {
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

    const barHeight = 10.0;
    const barTop = -barHeight - 5;

    // Health bar background
    final backgroundRect = Rect.fromLTWH(0, barTop, size.x, barHeight);
    paint.color = const Color(0xFF000000);
    canvas.drawRect(backgroundRect, paint);

    // Health bar foreground
    final healthRect = Rect.fromLTWH(
      0,
      barTop,
      size.x * healthPercentage,
      barHeight,
    );
    final healthColor = Color.lerp(
      const Color(0xFFFF0000),
      const Color(0xFF00FF00),
      healthPercentage,
    );
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
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Bullet && other.isPlayerBullet) {
      AudioManager().playGameSfx('damage_ene.mp3');
      health--;
      other.removeFromParent();
      game.checkWinCondition();
    }
  }
}
