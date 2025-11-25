import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:bvst/game/attack_lvl5.dart';
import 'package:bvst/game/audio_manager.dart';
import 'package:bvst/game/battle_game.dart';
import 'package:bvst/game/enemy_lvl5.dart';
import 'package:flame/components.dart';

class BattleGameLevel5 extends BattleGame {
  late EnemyLevel5 _boss;
  late SpriteComponent _background;
  
  Timer? _powerTimer;
  Timer? _attackTimer;
  bool _powerActive = false;
  bool _firstPowerActivated = false;
  double _normalPlayerSpeed = 0.0;
  AudioPlayer? _powerAudioPlayer;
  
  // Control inversion flag - exposed to the screen for input handling
  bool controlsInverted = false;

  BattleGameLevel5({required super.onGameOver});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Setup Background
    _background = SpriteComponent()
      ..sprite = await loadSprite('fondo_lvl5.png')
      ..size = size
      ..position = Vector2.zero()
      ..priority = -10; // Ensure it's behind everything
    add(_background);

    // Remove default enemy and add Level 5 Boss
    remove(enemy);
    _boss = EnemyLevel5();
    enemy = _boss;
    add(_boss);
  }

  void startSequence() {
    // Start background music
    AudioManager().playGameBgm('musica_lvl5.mp3');
    
    // Setup Power Timer - first activation at 6 seconds
    _powerTimer = Timer(6.0, onTick: _activatePower, repeat: false);
    _powerTimer!.start();
  }

  void _activatePower() async {
    if (enemy.health <= 0 || player.health <= 0) return;

    _powerActive = true;
    _firstPowerActivated = true;
    controlsInverted = true;

    // Stop boss movement and center it
    _boss.stopMovement();
    _boss.centerPosition();

    // Store player's normal speed
    if (_normalPlayerSpeed == 0.0) {
      _normalPlayerSpeed = player.speed;
    }

    // Slow down player (reduce speed to 40% like Level 3)
    player.speed = _normalPlayerSpeed * 0.4;

    // Pause background music
    AudioManager().pauseGameBgm();

    // Play power audio
    _powerAudioPlayer = AudioPlayer();
    await _powerAudioPlayer!.play(AssetSource('audio/poder_lvl5.mp3'));

    // Start attack spawning during power
    _attackTimer = Timer(0.8, onTick: _spawnAttacks, repeat: true);
    _attackTimer!.start();

    // Listen for when audio completes
    _powerAudioPlayer!.onPlayerComplete.listen((_) {
      _deactivatePower();
    });
  }

  void _spawnAttacks() {
    if (!_powerActive || enemy.health <= 0) return;
    
    // Spawn 0 to 1 attacks (reduced from 1-2 to half)
    int count = Random().nextInt(2); // 0 or 1
    if (count == 0) return; // Skip if 0
    
    for (int i = 0; i < count; i++) {
      // Random position at top
      double startX = Random().nextDouble() * size.x;
      
      // Target player position
      Vector2 target = player.position;
      Vector2 start = Vector2(startX, -50);
      Vector2 direction = (target - start).normalized();
      
      add(AttackLevel5(
        position: start,
        velocity: direction * 250, // Speed
      ));
    }
  }

  void _deactivatePower() {
    if (!_powerActive) return;

    _powerActive = false;
    controlsInverted = false;

    // Resume boss movement
    _boss.resumeMovement();

    // Restore player's normal speed
    player.speed = _normalPlayerSpeed;

    // Stop attack spawning
    _attackTimer?.stop();

    // Resume background music
    AudioManager().resumeGameBgm();

    // Dispose audio player
    _powerAudioPlayer?.dispose();
    _powerAudioPlayer = null;

    // Set cooldown timer of 8 seconds before next power (reduced from 12s)
    _powerTimer = Timer(8.0, onTick: _activatePower, repeat: false);
    _powerTimer!.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _powerTimer?.update(dt);
    _attackTimer?.update(dt);
  }

  @override
  void onRemove() {
    _powerTimer?.stop();
    _attackTimer?.stop();
    _powerAudioPlayer?.dispose();
    super.onRemove();
  }
}
