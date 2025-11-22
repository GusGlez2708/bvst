import 'dart:ui';
import 'package:bvst/game/audio_manager.dart';
import 'package:bvst/game/battle_game.dart';
import 'package:bvst/game/bullet.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:bvst/game/collision_particle.dart';
import 'package:bvst/game/game_state.dart';

enum PlayerDirection { none, left, right }

class Player extends SpriteComponent
    with HasGameReference<BattleGame>, CollisionCallbacks {
  int health = 3;
  late int maxHealth;

  // --- State Management ---
  PlayerDirection _direction = PlayerDirection.none;
  bool _isShooting = false;
  double speed = 0.0; // Made public for level mechanics
  double damageMultiplier = 1.0; // Made public for level mechanics (e.g., weakening)
  bool canMove = true; // New property for Level 4 mechanics

  // --- Timers ---
  late Timer _shootCooldown;
  late Timer _shootSpriteTimer;

  bool _canShoot = true;

  // --- Sprites ---
  late Sprite idleSprite;
  late Sprite shootingSprite;
  late Sprite walkLeftSprite;
  late Sprite walkRightSprite;

  // --- Effects ---
  bool _isFlashing = false;
  double _flashElapsed = 0.0;
  final double _flashDuration = 1.0;
  bool _isInvincible = false;

  Player() : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Carga todos los sprites
    idleSprite = await Sprite.load('personaje.png');
    shootingSprite = await Sprite.load('personaje_disparo.png');
    walkLeftSprite = await Sprite.load('personaje_izq1.png');
    walkRightSprite = await Sprite.load('personaje_der1.png');

    sprite = idleSprite; // Sprite inicial

    // Lógica de vida
    final gameState = GameState();
    await gameState.loadGameState();
    int baseHealth = 3;
    int purchasedExtraHearts = gameState.extraHeartsPurchased;
    health = baseHealth + purchasedExtraHearts;
    maxHealth = health;

    // Ajusta el tamaño (usa el sprite idle como referencia)
    double newHeight = game.size.y * 0.25;
    double newWidth =
        (idleSprite.originalSize.x / idleSprite.originalSize.y) * newHeight;
    size = Vector2(newWidth, newHeight);

    // Posición inicial
    position = Vector2(
      game.size.x / 2,
      game.size.y - (size.y / 2) - 35,
    );

    add(RectangleHitbox());

    // Configura los timers
    _shootCooldown = Timer(0.5, onTick: () => _canShoot = true);
    _shootSpriteTimer = Timer(0.3, onTick: () {
      _isShooting = false;
      _updateSprite();
    });
  }

  void _updateSprite() {
    // La acción de disparar tiene la máxima prioridad
    if (_isShooting) {
      sprite = shootingSprite;
      return;
    }

    // Si no está disparando, decide el sprite según la dirección
    switch (_direction) {
      case PlayerDirection.left:
        sprite = walkLeftSprite;
        break;
      case PlayerDirection.right:
        sprite = walkRightSprite;
        break;
      case PlayerDirection.none:
        sprite = idleSprite;
        break;
    }
  }

  void startBehavior() {
    speed = 300.0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _shootCooldown.update(dt);
    _shootSpriteTimer.update(dt);

    // Lógica de movimiento
    switch (_direction) {
      case PlayerDirection.left:
        position.x -= speed * dt;
        break;
      case PlayerDirection.right:
        position.x += speed * dt;
        break;
      case PlayerDirection.none:
        break;
    }
    position.x = position.x.clamp(size.x / 2, game.size.x - size.x / 2);

    // Lógica de parpadeo por daño
    if (_isFlashing) {
      _flashElapsed += dt;
      if (_flashElapsed >= _flashDuration) {
        _isFlashing = false;
        _isInvincible = false;
        _flashElapsed = 0.0;
        paint.color = const Color(0xFFFFFFFF).withOpacity(1.0);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (_isFlashing) {
      final flashCycle = (_flashElapsed * 10) % 1.0;
      paint.color = const Color(0xFFFFFFFF).withOpacity(flashCycle < 0.5 ? 0.3 : 1.0);
    }
    super.render(canvas);
  }

  // --- Métodos de control ---

  void moveLeft() {
    if (!canMove) return;
    _direction = PlayerDirection.left;
    _updateSprite();
  }

  void moveRight() {
    if (!canMove) return;
    _direction = PlayerDirection.right;
    _updateSprite();
  }

  void stopMoving() {
    _direction = PlayerDirection.none;
    _updateSprite();
  }

  void shoot() async {
    if (!canMove && _direction == PlayerDirection.none) {
       // Allow shooting if immobile? User said "personaje se quedara inmóvil" then "lo podremos atacar".
       // I'll assume shooting is allowed even if movement isn't, OR I'll re-enable movement for the attack phase.
       // In BattleGameLevel4 I re-enable canMove for the vulnerable phase, so this check is fine.
    }
    
    if (_canShoot) {
      _isShooting = true;
      _updateSprite(); // Cambia al sprite de disparo
      _shootSpriteTimer.start(); // Inicia el timer para revertirlo

      AudioManager().playGameSfx('laser.mp3');

      final gameState = GameState();
      bool hasDoubleShot = gameState.hasDoubleShot;

      if (hasDoubleShot) {
        final leftBullet = Bullet(isPlayerBullet: true, position: position + Vector2(-size.x * 0.2, -size.y / 2));
        final rightBullet = Bullet(isPlayerBullet: true, position: position + Vector2(size.x * 0.2, -size.y / 2));
        game.add(leftBullet);
        game.add(rightBullet);
      } else {
        final bullet = Bullet(isPlayerBullet: true, position: position + Vector2(0, -size.y / 2));
        game.add(bullet);
      }

      _canShoot = false;
      _shootCooldown.start();
    }
  }
  
  void takeDamage(int amount) {
      if (_isInvincible) return;

      AudioManager().playGameSfx('damage_prota.mp3');
      
      // Apply damage multiplier (e.g., 2.0 when weakened, 1.0 normally)
      final damageAmount = (amount * damageMultiplier).round();
      health -= damageAmount;
      
      _isFlashing = true;
      _isInvincible = true;
      _flashElapsed = 0.0;

      final particle = CollisionParticle(
        position: position.clone(),
        color: const Color(0xFF00FF00),
      );
      game.add(particle);

      game.checkWinCondition();
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Bullet && !other.isPlayerBullet) {
      if (_isInvincible) return;

      AudioManager().playGameSfx('damage_prota.mp3');
      
      // Apply damage multiplier (e.g., 2.0 when weakened, 1.0 normally)
      final damageAmount = (1 * damageMultiplier).round();
      health -= damageAmount;
      
      other.removeFromParent();

      _isFlashing = true;
      _isInvincible = true;
      _flashElapsed = 0.0;

      final particle = CollisionParticle(
        position: position.clone(),
        color: const Color(0xFF00FF00),
      );
      game.add(particle);

      game.checkWinCondition();
    }
  }
}