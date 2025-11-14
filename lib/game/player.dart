import 'package:bvst/game/audio_manager.dart';
import 'package:bvst/game/battle_game.dart';
import 'package:bvst/game/bullet.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

// 1. AÑADE ESTE ENUM (antes de la clase Player)
// Nos ayudará a saber la dirección del movimiento
enum PlayerDirection { none, left, right }

class Player extends SpriteComponent with HasGameReference<BattleGame>, CollisionCallbacks {
  int health = 3;
  
  // 2. REEMPLAZA los booleanos por este enum
  // bool isMovingLeft = false;  <-- ELIMINA ESTO
  // bool isMovingRight = false; <-- ELIMINA ESTO
  PlayerDirection _direction = PlayerDirection.none; // NUEVA VARIABLE
  
  double _speed = 0.0;
  late Timer _shootCooldown;
  bool _canShoot = true;

  Player() : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    sprite = await Sprite.load('personaje.png');
    
    // Ajusta el tamaño basado en la altura de la pantalla (base2.md)
    double newHeight = game.size.y * 0.25;
    double newWidth = (sprite!.originalSize.x / sprite!.originalSize.y) * newHeight;
    size = Vector2(newWidth, newHeight);
    
    // Ajusta la posición inicial (base2.md)
    position = Vector2(game.size.x / 2, game.size.y - (size.y / 2) - 35); // Sube un poco
    
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
  void shoot() {
    if (_canShoot) {
      AudioManager().playGameSfx('laser.mp3');
      final bullet = Bullet(
        isPlayerBullet: true,
        position: position + Vector2(0, -size.y / 2),
      );
      game.add(bullet);
      _canShoot = false;
      _shootCooldown.start();
    }
  }

  // Tu método onCollisionStart() está perfecto
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Bullet && !other.isPlayerBullet) {
      AudioManager().playGameSfx('damage_prota.mp3');
      health--;
      other.removeFromParent();
      game.checkWinCondition();
    }
  }
}
