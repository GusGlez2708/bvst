import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:bvst/game/attack_lvl4.dart';
import 'package:bvst/game/audio_manager.dart';
import 'package:bvst/game/battle_game.dart';
import 'package:bvst/game/enemy_lvl4.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';

enum Level4Phase {
  intro,      // Fondo 1 -> 2 -> 3
  evasion,    // Fondo 3, attacks spawning
  transition, // Fondo 4, player immobile
  vulnerable, // Fondo 5, boss hit
  loopReset   // Back to Fondo 4 -> Evasion
}

class BattleGameLevel4 extends BattleGame {
  late EnemyLevel4 _boss;
  late SpriteComponent _background;
  
  Level4Phase _phase = Level4Phase.intro;
  Timer? _phaseTimer;
  Timer? _attackTimer;
  
  // Audio players for specific SFX
  AudioPlayer? _sfxPlayer;

  BattleGameLevel4({required super.onGameOver});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1. Setup Background
    _background = SpriteComponent()
      ..sprite = await loadSprite('nvl4_fondo1.png')
      ..size = size
      ..position = Vector2.zero()
      ..priority = -10; // Ensure it's behind everything
    add(_background);

    // 2. Remove default enemy and add Boss
    remove(enemy);
    _boss = EnemyLevel4();
    enemy = _boss; // Assign to parent's enemy reference
    add(_boss);
  }

  void startSequence() {
    // 3. Start Sequence
    // "primero saldrá el fondo nvl4_fondo1.png con una musica de suspenso"
    AudioManager().playGameBgm('musica_lvl4.mp3'); 
    
    // "luego a los 2 segundos ... se cambiara al fondo nvl4_fondo2.png"
    _phaseTimer = Timer(2.0, onTick: _startPhase2, repeat: false);
    _phaseTimer!.start();
  }

  void _startPhase2() async {
    _background.sprite = await loadSprite('nvl4_fondo2.png');
    
    // "y después de .5 segundos cambiara al fondo nvl4_fondo3.png y sonara el grito.mp3"
    _phaseTimer = Timer(0.5, onTick: _startEvasionPhase, repeat: false);
    _phaseTimer!.start();
  }

  void _startEvasionPhase() async {
    _phase = Level4Phase.evasion;
    _background.sprite = await loadSprite('nvl4_fondo3.png');
    // Use FlameAudio directly to avoid stopping BGM if AudioManager has issues
    // Or use AudioManager().playUiSfx if we are sure it doesn't stop BGM (which we fixed)
    // But to be safe and separate from UI, let's use a simple play.
    // Actually, let's use AudioManager().playGameSfx if we add it to pool, or just playUiSfx.
    // The user said "el sonido del grito.mp3, hace que la musica de fondo se detenga".
    // This implies playUiSfx might still be stopping it or something else is.
    // Let's try using a separate AudioPlayer for this specific sound or just FlameAudio.play
    FlameAudio.play('grito.mp3');
    
    // "comenzara a tirar el enemigo el ataque_lvl4.png"
    // "pueden salir hasta 3 al mismo tiempo de forma continua"
    // "luego de 4segundos de esquivar los varios ataques" -> User changed to 13s
    
    _boss.isVulnerable = false;
    
    // Start attack spawner
    _attackTimer = Timer(0.7, onTick: _spawnAttacks, repeat: true);
    _attackTimer!.start();
    
    // Schedule end of evasion phase (13 seconds)
    _phaseTimer = Timer(13.0, onTick: _startTransitionPhase, repeat: false);
    _phaseTimer!.start();
  }
  
  void _spawnAttacks() {
    if (_phase != Level4Phase.evasion) return;
    
    // Spawn 1 to 3 attacks
    int count = Random().nextInt(1) + 1; 
    
    for (int i = 0; i < count; i++) {
      // Random position at top
      double startX = Random().nextDouble() * size.x;
      
      // Target player position or random down
      Vector2 target = player.position;
      Vector2 start = Vector2(startX, -50);
      Vector2 direction = (target - start).normalized();
      
      add(AttackLevel4(
        position: start,
        velocity: direction * 300, // Speed
      ));
    }
  }

  void _startTransitionPhase() async {
    _phase = Level4Phase.transition;
    _attackTimer?.stop(); // Stop attacks
    
    // "saldrá el nvl4_fondo4.png y se escuchara otra vez el grito.mp3"
    _background.sprite = await loadSprite('nvl4_fondo4.png');
    FlameAudio.play('grito.mp3');
    
    // "luego a los .5 se cambiara al nvl4_fondo5.png"
    _phaseTimer = Timer(0.5, onTick: _startVulnerablePhase, repeat: false);
    _phaseTimer!.start();
  }

  void _startVulnerablePhase() async {
    _phase = Level4Phase.vulnerable;
    
    // "donde el enemigo quedara atrapado y lo podremos atacar"
    _background.sprite = await loadSprite('nvl4_fondo5.png');
    _boss.isVulnerable = true;
    
    // "luego de 4 segundos, la hitbox del enemigo desaparecerá"
    _phaseTimer = Timer(4.0, onTick: _startLoopReset, repeat: false);
    _phaseTimer!.start();
  }

  void _startLoopReset() async {
    _phase = Level4Phase.loopReset;
    _boss.isVulnerable = false;
    
    // "saldrá otra vez el fondo de nvl4_fondo4.png"
    _background.sprite = await loadSprite('nvl4_fondo4.png');
    
    // "y luego de .5segundos comenzara el ciclo"
    _phaseTimer = Timer(0.5, onTick: _startEvasionPhaseLoop, repeat: false);
    _phaseTimer!.start();
  }
  
  void _startEvasionPhaseLoop() async {
     // Same as _startEvasionPhase but skipping the initial intro logic if any
     _startEvasionPhase();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _phaseTimer?.update(dt);
    _attackTimer?.update(dt);
  }
  
  @override
  void onRemove() {
    _phaseTimer?.stop();
    _attackTimer?.stop();
    super.onRemove();
  }
}
