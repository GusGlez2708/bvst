import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:bvst/game/attack_lvl5.dart';
import 'package:bvst/game/audio_manager.dart';
import 'package:bvst/game/battle_game.dart';
import 'package:bvst/game/enemy_lvl5.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BattleGameLevel5 extends BattleGame {
  late EnemyLevel5 _boss;
  late SpriteComponent _background;
  final List<RainDrop> _rainDrops = [];
  final Random _random = Random();
  
  // Thunder effect
  late RectangleComponent _thunderFlash;
  double _thunderTimer = 0;
  double _thunderCooldown = 3.0; // Thunder every 3 seconds
  bool _thunderActive = false;
  double _flashDuration = 0;
  
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

    // Setup static Background
    _background = SpriteComponent()
      ..sprite = await loadSprite('fondo_lvl5.png')
      ..size = size
      ..position = Vector2.zero()
      ..priority = -10;
    add(_background);

    // Create thunder flash overlay (initially invisible)
    _thunderFlash = RectangleComponent(
      size: size,
      position: Vector2.zero(),
      paint: Paint()..color = Colors.white.withOpacity(0),
      priority: 100, // On top of everything
    );
    add(_thunderFlash);

    // Create rain drops
    for (int i = 0; i < 50; i++) {
      final rainDrop = RainDrop(
        position: Vector2(
          _random.nextDouble() * size.x,
          _random.nextDouble() * size.y,
        ),
        screenSize: size,
      );
      _rainDrops.add(rainDrop);
      add(rainDrop);
    }

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
    _boss.makeInvulnerable(); // Make boss invulnerable during power

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
    _boss.makeVulnerable(); // Make boss vulnerable again

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
    
    // Update thunder effect
    _thunderTimer += dt;
    if (_thunderTimer >= _thunderCooldown && !_thunderActive) {
      // Trigger thunder flash
      _thunderActive = true;
      _flashDuration = 0;
      _thunderTimer = 0;
      _thunderCooldown = 2.5 + _random.nextDouble() * 2.5; // Random 2.5-5s
    }
    
    if (_thunderActive) {
      _flashDuration += dt;
      if (_flashDuration < 0.1) {
        // Quick bright flash
        _thunderFlash.paint.color = Colors.white.withOpacity(0.4);
      } else if (_flashDuration < 0.15) {
        // Fade out
        _thunderFlash.paint.color = Colors.white.withOpacity(0.2);
      } else {
        // End flash
        _thunderFlash.paint.color = Colors.white.withOpacity(0);
        _thunderActive = false;
      }
    }
  }
  
  @override
  void onRemove() {
    _powerTimer?.stop();
    _attackTimer?.stop();
    _powerAudioPlayer?.dispose();
    super.onRemove();
  }
}

// Rain drop component
class RainDrop extends PositionComponent {
  final Vector2 screenSize;
  final Random _random = Random();
  late double speed;
  late Paint _paint;

  RainDrop({required Vector2 position, required this.screenSize})
      : super(position: position, size: Vector2(2, 15)) {
    speed = 300 + _random.nextDouble() * 200; // Random speed 300-500
    _paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1.5;
    priority = -5; // Between background and game objects
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * dt;
    
    // Reset to top when off screen
    if (position.y > screenSize.y) {
      position.y = -size.y;
      position.x = _random.nextDouble() * screenSize.x;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Draw rain as a line
    canvas.drawLine(
      Offset(0, 0),
      Offset(0, size.y),
      _paint,
    );
  }
}
