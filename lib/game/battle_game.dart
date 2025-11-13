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

  BattleGame({required this.onGameOver});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    final background = SpriteComponent()
      ..sprite = await Sprite.load('fondo.png')
      ..size = size;
    add(background);

    player = Player();
    enemy = Enemy();

    add(player);
    add(enemy);

    heartSprite = await Sprite.load('heart.png');
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    for (int i = 0; i < player.health; i++) {
      heartSprite.render(
        canvas,
        position: Vector2(20.0 + (i * 40.0), size.y - 40.0),
        size: Vector2(32, 32),
      );
    }
  }

  void checkWinCondition() {
    if (enemy.health <= 0) {
      onGameOver(true);
    } else if (player.health <= 0) {
      onGameOver(false);
    }
  }
}
