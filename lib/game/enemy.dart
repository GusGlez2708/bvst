import 'dart:ui';
import 'package:bvst/game/battle_game.dart';
import 'package:bvst/game/bullet.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:bvst/game/audio_manager.dart';
import 'package:bvst/game/collision_particle.dart';
import 'package:bvst/game/game_state.dart';

class Enemy extends SpriteAnimationComponent
    with HasGameReference<BattleGame>, CollisionCallbacks {
  int health = 1;
  late int maxHealth;
  double speed = 0.0;
  int direction = 1;
  late Timer _shootTimer;
  bool canShoot = false;
  bool _isEnraged = false; // Enrage flag

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

  // Health bar rendering moved to BattleGame class to display full-width at top of screen

  @override
  void update(double dt) {
    super.update(dt);
    _shootTimer.update(dt);

    // Check for enrage at 50% health
    if (!_isEnraged && health <= maxHealth / 2 && health > 0) {
      _triggerEnrage();
    }

    position.x += speed * direction * dt;

    if (position.x <= size.x / 2 || position.x >= game.size.x - size.x / 2) {
      direction *= -1;
    }

    position.x = position.x.clamp(size.x / 2, game.size.x - size.x / 2);
  }

  void _triggerEnrage() {
    _isEnraged = true;

    // Double speed
    speed = speed * 2;

    // Double fire rate by halving timer interval
    _shootTimer.stop();
    _shootTimer = Timer(0.75, onTick: shoot, repeat: true); // 1.5s -> 0.75s
    _shootTimer.start();

    print('🔥 BOSS ENRAGED! Speed and fire rate DOUBLED! 🔥');
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

      // Spawn collision particles
      final particle = CollisionParticle(
        position: position.clone(),
        color: const Color(0xFFFF6600), // Orange particles for enemy damage
      );
      game.add(particle);

      // Award coins if enemy is defeated
      if (health <= 0) {
        final gameState = GameState();
        gameState.addCoins(GameState.coinsPerEnemyKill);
        print('Enemy defeated! Awarded ${GameState.coinsPerEnemyKill} coins');
      }

      game.checkWinCondition();
    }
  }
}
