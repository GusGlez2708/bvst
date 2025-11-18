import 'package:bvst/game/battle_game.dart';
import 'package:bvst/game/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:bvst/game/audio_manager.dart';

class FloorFire extends SpriteAnimationComponent
    with HasGameReference<BattleGame>, CollisionCallbacks {
  final double duration;
  late Timer _timer;

  FloorFire({required Vector2 position, this.duration = 3.0})
    : super(position: position, anchor: Anchor.bottomCenter);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final spriteSheet = await game.images.load('Fuego_Sprite.png');
    final spriteSize = Vector2(
      spriteSheet.width / 3,
      spriteSheet.height.toDouble(),
    );

    animation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.1,
        textureSize: spriteSize,
      ),
    );

    // Play sound
    AudioManager().playGameSfx('Fuego.mp3');

    // Size it appropriately
    double newHeight = game.size.y * 0.15;
    double newWidth = (spriteSize.x / spriteSize.y) * newHeight;
    size = Vector2(newWidth, newHeight);

    add(RectangleHitbox());

    _timer = Timer(duration, onTick: removeFromParent);
    _timer.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer.update(dt);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player) {
      game.player.health--;
      game.checkWinCondition();
    }
  }
}
