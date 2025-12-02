import 'dart:ui';
import 'package:bvst/game/battle_game.dart';
import 'package:bvst/game/battle_game_infinite.dart';
import 'package:bvst/game/bullet.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:bvst/game/audio_manager.dart';
import 'package:bvst/game/collision_particle.dart';
import 'package:bvst/game/game_state.dart';

class Enemy extends SpriteAnimationComponent
    with HasGameReference<BattleGame>, CollisionCallbacks {
  int health = 15;
  int maxHealth = 15;
  double speed = 0.0;
  double baseSpeed = 200.0;
  double speedMultiplier = 1.0;
  double baseFireInterval = 1.5;
  double fireRateMultiplier = 1.0;
  int direction = 1;
  Timer shootTimer; // Changed from _shootTimer
  bool canShoot = false;
  bool isEnraged = false; // Changed from _isEnraged

  Enemy()
    : shootTimer = Timer(1.5),
      super(anchor: Anchor.center); // Initialize with dummy timer

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Load static sprite as a 1-frame animation
    final sprite = await Sprite.load('enemigo_lvl1.png');
    final spriteSize = sprite.srcSize;

    animation = SpriteAnimation.spriteList([sprite], stepTime: 1.0);

    maxHealth = health;

    double newHeight = game.size.y * 0.18;
    double newWidth = (spriteSize.x / spriteSize.y) * newHeight;
    size = Vector2(newWidth, newHeight);

    position = Vector2(game.size.x / 2, size.y / 2 + 50);
    add(RectangleHitbox());

    shootTimer = Timer(
      1.5,
      onTick: shoot,
      repeat: true,
    ); // Changed from _shootTimer
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
    speed = baseSpeed * speedMultiplier;

    // Update shoot timer with fire rate multiplier
    shootTimer.stop();
    shootTimer = Timer(
      baseFireInterval / fireRateMultiplier,
      onTick: shoot,
      repeat: true,
    );
    shootTimer.start();
  }

  // Method to update multipliers dynamically (for infinite mode)
  void updateMultipliers() {
    speed = baseSpeed * speedMultiplier;

    // Restart timer with new fire rate
    if (canShoot) {
      shootTimer.stop();
      shootTimer = Timer(
        baseFireInterval / fireRateMultiplier,
        onTick: shoot,
        repeat: true,
      );
      shootTimer.start();
    }
  }

  // Health bar rendering moved to BattleGame class to display full-width at top of screen

  @override
  void update(double dt) {
    super.update(dt);
    shootTimer.update(dt); // Changed from _shootTimer

    // Check for enrage at 50% health
    if (!isEnraged && health <= maxHealth / 2 && health > 0) {
      // Changed from _isEnraged
      triggerEnrage(); // Changed from _triggerEnrage
    }

    position.x += speed * direction * dt;

    if (position.x <= size.x / 2 || position.x >= game.size.x - size.x / 2) {
      direction *= -1;
    }

    position.x = position.x.clamp(size.x / 2, game.size.x - size.x / 2);
  }

  void triggerEnrage() {
    // Changed from _triggerEnrage
    isEnraged = true; // Changed from _isEnraged

    // Double speed
    speed = speed * 2;

    // Double fire rate by halving timer interval
    shootTimer.stop(); // Changed from _shootTimer
    shootTimer = Timer(0.75, onTick: shoot, repeat: true); // 1.5s -> 0.75s
    shootTimer.start(); // Changed from _shootTimer

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

      // Call infinite mode hit callback if applicable
      if (game is BattleGameInfinite) {
        (game as BattleGameInfinite).onEnemyHit();
      }

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
