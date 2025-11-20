import 'dart:ui';
import 'package:bvst/game/audio_manager.dart';
import 'package:bvst/game/battle_game.dart';
import 'package:bvst/game/bullet.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:bvst/game/collision_particle.dart';
import 'package:bvst/game/game_state.dart';

// 1. AÑADE ESTE ENUM (antes de la clase Player)
// Nos ayudará a saber la dirección del movimiento
enum PlayerDirection { none, left, right }

class Player extends SpriteComponent
    with HasGameReference<BattleGame>, CollisionCallbacks {
  int health = 3;
  late int maxHealth;

  // 2. REEMPLAZA los booleanos por este enum
  // bool isMovingLeft = false;  <-- ELIMINA ESTO
  // bool isMovingRight = false; <-- ELIMINA ESTO
  PlayerDirection _direction = PlayerDirection.none; // NUEVA VARIABLE

  double _speed = 0.0;
  late Timer _shootCooldown;
  bool _canShoot = true;

  // Damage flash effect
  bool _isFlashing = false;
  double _flashElapsed = 0.0;
  final double _flashDuration = 1.0; // 1 second flash
  bool _isInvincible = false;

  Player() : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    sprite = await Sprite.load('personaje.png');

    // Check GameState for extra heart upgrade
    final gameState = GameState();
    await gameState.loadGameState();

    // Base health is 3, +1 if extra heart purchased
    int baseHealth = 3;
    int purchasedExtraHearts = gameState.extraHeartsPurchased;
    health = baseHealth + purchasedExtraHearts;
    maxHealth = health;

    // Ajusta el tamaño basado en la altura de la pantalla (base2.md)
    double newHeight = game.size.y * 0.25;
    double newWidth =
        (sprite!.originalSize.x / sprite!.originalSize.y) * newHeight;
    size = Vector2(newWidth, newHeight);

    // Ajusta la posición inicial (base2.md)
    position = Vector2(
      game.size.x / 2,
      game.size.y - (size.y / 2) - 35,
    ); // Sube un poco

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

    // Update flash effect
    if (_isFlashing) {
      _flashElapsed += dt;
      if (_flashElapsed >= _flashDuration) {
        _isFlashing = false;
        _isInvincible = false;
        _flashElapsed = 0.0;
        paint.color = const Color(
          0xFFFFFFFF,
        ).withOpacity(1.0); // Reset to fully visible
      }
    }

    // 3. MODIFICA la lógica de update
    // Ahora revisa el enum _direction
    switch (_direction) {
      case PlayerDirection.left:
        position.x -= _speed * dt;
        break;
      case PlayerDirection.right:
        position.x += _speed * dt;
        break;
      case PlayerDirection.none:
        // No te muevas si la dirección es 'none'
        break;
    }

    // Clamp position to stay within screen bounds
    position.x = position.x.clamp(size.x / 2, game.size.x - size.x / 2);
  }

  @override
  void render(Canvas canvas) {
    if (_isFlashing) {
      // Flash effect: rapidly toggle opacity
      final flashCycle = (_flashElapsed * 10) % 1.0; // 10 flashes per second
      paint.color = const Color(
        0xFFFFFFFF,
      ).withOpacity(flashCycle < 0.5 ? 0.3 : 1.0);
    }
    super.render(canvas);
  }

  // 4. AÑADE estos 3 métodos
  // El joystick en game_screen.dart llamará a estos métodos

  /// Establece la dirección de movimiento a la izquierda.
  void moveLeft() {
    _direction = PlayerDirection.left;
  }

  /// Establece la dirección de movimiento a la derecha.
  void moveRight() {
    _direction = PlayerDirection.right;
  }

  /// Detiene el movimiento del jugador.
  void stopMoving() {
    _direction = PlayerDirection.none;
  }

  // Tu método shoot() está perfecto como lo tienes
  void shoot() async {
    if (_canShoot) {
      AudioManager().playGameSfx('laser.mp3');

      // Check if double shot is enabled
      final gameState = GameState();
      bool hasDoubleShot = gameState.hasDoubleShot;

      if (hasDoubleShot) {
        // Fire two bullets side by side
        final leftBullet = Bullet(
          isPlayerBullet: true,
          position: position + Vector2(-size.x * 0.2, -size.y / 2),
        );
        final rightBullet = Bullet(
          isPlayerBullet: true,
          position: position + Vector2(size.x * 0.2, -size.y / 2),
        );
        game.add(leftBullet);
        game.add(rightBullet);
      } else {
        // Single bullet
        final bullet = Bullet(
          isPlayerBullet: true,
          position: position + Vector2(0, -size.y / 2),
        );
        game.add(bullet);
      }

      _canShoot = false;
      _shootCooldown.start();
    }
  }

  // Tu método onCollisionStart() está perfecto
  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Bullet && !other.isPlayerBullet) {
      // Ignore collision if player is invincible
      if (_isInvincible) return;

      AudioManager().playGameSfx('damage_prota.mp3');
      health--;
      other.removeFromParent();

      // Start flash effect and invincibility
      _isFlashing = true;
      _isInvincible = true;
      _flashElapsed = 0.0;

      // Spawn collision particles for player damage
      final particle = CollisionParticle(
        position: position.clone(),
        color: const Color(0xFF00FF00), // Green particles for player damage
      );
      game.add(particle);

      game.checkWinCondition();
    }
  }
}
