import 'package:bvst/game/enemy.dart';
import 'package:bvst/game/player.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class BattleGame extends FlameGame with HasCollisionDetection {
  final Function(bool) onGameOver;
  late Player player;
  late Enemy enemy;
  late Sprite heartSprite;
  bool _isGameOver = false;

  BattleGame({required this.onGameOver});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    player = Player();
    enemy = Enemy();

    add(player);
    add(enemy);

    heartSprite = await Sprite.load('heart.png');
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Render player health (hearts) at bottom
    for (int i = 0; i < player.health; i++) {
      heartSprite.render(
        canvas,
        position: Vector2(20.0 + (i * 40.0), size.y - 40.0),
        size: Vector2(32, 32),
      );
    }

    // Render enemy health bar at top of screen (full width)
    final paint = Paint();
    final healthPercentage = enemy.health / enemy.maxHealth;

    const barHeight = 30.0;
    const barTop = 20.0;
    const sidePadding = 20.0;
    final barWidth = size.x - (sidePadding * 2);

    // Health bar background (dark gray)
    final backgroundRect = Rect.fromLTWH(
      sidePadding,
      barTop,
      barWidth,
      barHeight,
    );
    paint.color = const Color(0xFF333333);
    canvas.drawRect(backgroundRect, paint);

    // Health bar foreground (gradient from red to green)
    final healthRect = Rect.fromLTWH(
      sidePadding,
      barTop,
      barWidth * healthPercentage,
      barHeight,
    );
    final healthColor = Color.lerp(
      const Color(0xFFFF0000), // Red
      const Color(0xFF00FF00), // Green
      healthPercentage,
    );
    paint.color = healthColor!;
    canvas.drawRect(healthRect, paint);

    // Border around health bar
    paint.color = const Color(0xFFFFFFFF);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;
    canvas.drawRect(backgroundRect, paint);

    // Health text display
    final textStyle = TextStyle(
      color: const Color(0xFFFFFFFF),
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );
    final textSpan = TextSpan(
      text: '${enemy.health} / ${enemy.maxHealth}',
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        sidePadding + (barWidth / 2) - (textPainter.width / 2),
        barTop + (barHeight / 2) - (textPainter.height / 2),
      ),
    );
  }

  void checkWinCondition() {
    if (_isGameOver) return;

    if (enemy.health <= 0) {
      _isGameOver = true;
      onGameOver(true);
    } else if (player.health <= 0) {
      _isGameOver = true;
      onGameOver(false);
    }
  }
}
