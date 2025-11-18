import 'dart:math';
import 'package:bvst/game/battle_game.dart';
import 'package:bvst/game/enemy_lvl2.dart';
import 'package:bvst/game/floor_fire.dart';
import 'package:flame/components.dart';

class BattleGameLevel2 extends BattleGame {
  late Timer _fireSpawnTimer;
  final Random _random = Random();

  BattleGameLevel2({required super.onGameOver});

  @override
  Future<void> onLoad() async {
    // We need to load the base game first, but we want to replace the enemy.
    // BattleGame.onLoad adds a normal Enemy. We should probably override onLoad completely
    // or remove the old enemy and add the new one.
    // Given BattleGame's structure, it's cleaner to override onLoad and copy the necessary parts,
    // OR modify BattleGame to accept an Enemy instance.
    // Let's modify BattleGame to be more flexible in a future refactor, but for now,
    // we can just remove the default enemy and add our own after super.onLoad().

    await super.onLoad();

    // Remove the default enemy
    remove(enemy);

    // Add Level 2 Enemy
    enemy = EnemyLevel2();
    add(enemy);

    // Setup Fire Spawner
    _fireSpawnTimer = Timer(4.0, onTick: _spawnFire, repeat: true);
    _fireSpawnTimer.start();
  }

  void _spawnFire() {
    if (enemy.health <= 0 || player.health <= 0) return;

    // Randomly choose left or right side
    bool leftSide = _random.nextBool();
    double xPos = leftSide ? size.x * 0.2 : size.x * 0.8;

    // Position at bottom
    Vector2 position = Vector2(xPos, size.y - 50); // Adjust Y as needed

    add(FloorFire(position: position));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _fireSpawnTimer.update(dt);
  }
}
