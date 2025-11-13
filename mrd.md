
Esta es la solución definitiva.

---

### 1. Archivo: `lib/game/audio_manager.dart` (El importante)

Vamos a rediseñar este archivo para que use `AudioPool` para los sonidos del juego y `FlameAudio.play` solo para los sonidos de la UI (como "start" o "victory").

**Dart**

```
// lib/game/audio_manager.dart
import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  // --- GRUPOS DE AUDIO (POOLS) PARA EL JUEGO ---
  // Estos permiten que varios sonidos suenen a la vez.
  late AudioPool laserPool;
  late AudioPool dropPool;
  late AudioPool damageEnePool;
  late AudioPool damageProtaPool;

  bool _isMenuMusicPlaying = false;
  bool _isGameMusicPlaying = false;

  /// 1. Pre-carga TODO el audio.
  /// Llama esto una sola vez al inicio de la app (en main.dart).
  Future<void> preloadAllAudio() async {
    await FlameAudio.audioCache.clearAll();

    // --- Carga los POOLS para SFX concurrentes ---
    // (maxPlayers: 5) significa que pueden sonar hasta 5 disparos a la vez.
    laserPool = await FlameAudio.createPool(
      'laser.mp3',
      minPlayers: 3,
      maxPlayers: 5,
    );
    dropPool = await FlameAudio.createPool(
      'drop.mp3',
      minPlayers: 3,
      maxPlayers: 5,
    );
    damageEnePool = await FlameAudio.createPool(
      'damage_ene.mp3',
      minPlayers: 2,
      maxPlayers: 3,
    );
    damageProtaPool = await FlameAudio.createPool(
      'damage_prota.mp3',
      minPlayers: 2,
      maxPlayers: 3,
    );

    // --- Carga los sonidos de UI y BGM en el caché normal ---
    await FlameAudio.audioCache.loadAll([
      'start.mp3',
      'bg_music.mp3',
      // Recuerda añadir estos:
      // 'menu_music.mp3',
      // 'victory.mp3',
      // 'defeat.mp3',
    ]);
  }

  /// 2. Control de Música del Menú
  void playMenuBgm() {
    stopAllAudio(); // Detiene todo lo demás
    // FlameAudio.bgm.play('menu_music.mp3'); // Descomenta cuando tengas el archivo
    _isMenuMusicPlaying = true;
  }

  void stopMenuBgm() {
    if (_isMenuMusicPlaying) {
      FlameAudio.bgm.stop();
      _isMenuMusicPlaying = false;
    }
  }

  /// 3. Control de Música del Juego
  void playGameBgm() {
    stopAllAudio(); // Detiene todo lo demás
  
    if (!_isGameMusicPlaying) {
      // Usamos 'loop' para que la música de fondo se repita
      FlameAudio.bgm.play('bg_music.mp3', volume: 0.5); // Bájale un poco el volumen
      _isGameMusicPlaying = true;
    }
  }

  void stopGameBgm() {
    if (_isGameMusicPlaying) {
      FlameAudio.bgm.stop();
      _isGameMusicPlaying = false;
    }
  }

  /// 4. Reproductor de SFX del JUEGO (Usa POOLS)
  /// Esto permite sonidos concurrentes.
  void playGameSfx(String filename) {
    // No queremos que los SFX suenen si la música del juego no está activa
    if (!_isGameMusicPlaying) return; 

    switch (filename) {
      case 'laser.mp3':
        laserPool.start(volume: 0.8);
        break;
      case 'drop.mp3':
        dropPool.start(volume: 0.8);
        break;
      case 'damage_ene.mp3':
        damageEnePool.start(volume: 1.0);
        break;
      case 'damage_prota.mp3':
        damageProtaPool.start(volume: 1.0);
        break;
    }
  }

  /// 5. Reproductor de SFX de UI (Usa FlameAudio.play)
  /// Esto es para sonidos "únicos" que deben parar otros.
  void playUiSfx(String filename) {
    // Detiene BGM y otros SFX de UI
    stopAllAudio();
    FlameAudio.play(filename, volume: 1.0);
  }


  /// 6. ¡¡LA FUNCIÓN CLAVE!! Detiene BGM y SFX de UI.
  /// No necesitamos detener los pools, se detendrán solos.
  void stopAllAudio() {
    FlameAudio.bgm.stop();
    FlameAudio.audioPlayer.stop(); // Detiene los SFX de FlameAudio.play()

    _isMenuMusicPlaying = false;
    _isGameMusicPlaying = false;
  }
}
```

---

### 2. Archivos: `lib/game/player.dart` y `lib/game/enemy.dart`

Debes cambiar la función que llaman para los SFX.

**En `lib/game/player.dart`:**

**Dart**

```
// ...
  void shoot() {
    if (_canShoot) {
      // CAMBIA ESTO:
      // AudioManager().playSfx('laser.mp3');
      // POR ESTO:
      AudioManager().playGameSfx('laser.mp3');

      final bullet = Bullet(
      // ...
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Bullet && !other.isPlayerBullet) {
      // CAMBIA ESTO:
      // AudioManager().playSfx('damage_prota.mp3');
      // POR ESTO:
      AudioManager().playGameSfx('damage_prota.mp3');
    
      health--;
      // ...
    }
  }
// ...
```

**En `lib/game/enemy.dart`:**

**Dart**

```
// ...
  void _shoot() {
    if (!canShoot) return;
  
    // CAMBIA ESTO:
    // AudioManager().playSfx('drop.mp3');
    // POR ESTO:
    AudioManager().playGameSfx('drop.mp3');

    final bullet = Bullet(
    // ...
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Bullet && other.isPlayerBullet) {
      // CAMBIA ESTO:
      // AudioManager().playSfx('damage_ene.mp3');
      // POR ESTO:
      AudioManager().playGameSfx('damage_ene.mp3');
    
      health--;
      // ...
    }
  }
// ...
```

---

### 3. Archivos: Pantallas (`menu`, `game`, `result`)

Ahora ajustamos las pantallas para que usen las funciones de audio correctas.

**En `lib/screens/menu_screen.dart`:**

**Dart**

```
// ...
  @override
  void initState() {
    super.initState();
    // Inicia la música del menú
    AudioManager().playMenuBgm();
  }
// ...
// Dentro de tu GestureDetector:
                onTap: () {
                  // NO uses stopMenuBgm(), usa la nueva función de UI
                  AudioManager().playUiSfx('start.mp3'); 
                
                  // Ya NO llamamos a reset() ni a preloadSfx()
                
                  Navigator.pushNamed(context, '/game');
                },
// ...
```

**En `lib/screens/game_screen.dart`:**

**Dart**

```
// ...
class _GameScreenState extends State<GameScreen> {
  // ...
  @override
  void initState() {
    super.initState();
    _game = BattleGame(
      onGameOver: (hasWon) {
        if (mounted) {
          _game.pauseEngine(); 
        
          // Detiene la música del JUEGO (no todo)
          AudioManager().stopGameBgm();

          // Reproduce el sonido de UI de victoria/derrota
          if (hasWon) {
            AudioManager().playUiSfx('victory.mp3'); // (Añade este archivo)
          } else {
            AudioManager().playUiSfx('defeat.mp3'); // (Añade este archivo)
          }

          Navigator.pushReplacementNamed(
            context,
            '/result',
            arguments: {'hasWon': hasWon},
          );
        }
      },
    );
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        // ...
      } else {
        _timer?.cancel();
      
        // Inicia la música del JUEGO
        AudioManager().playGameBgm(); 
      
        setState(() {
          // ...
        });
      }
    });
  }
// ...
```

**En `lib/screens/result_screen.dart`:**

**Dart**

```
// ...
              ElevatedButton(
                onPressed: () {
                  // Detiene el sonido de victoria/derrota
                  AudioManager().stopAllAudio(); 
                
                  // Vuelve al menú (donde se iniciará la música del menú)
                  Navigator.pushNamedAndRemoveUntil(context, '/menu', (route) => false);
                },
// ...
```

### Resumen de la Solución

1. **`AudioManager`** ahora usa **`AudioPool`** para `playGameSfx()` (disparos, daño). Esto permite que suenen muchos a la vez.
2. **`AudioManager`** usa **`FlameAudio.bgm`** para la música de fondo (`playGameBgm`, `playMenuBgm`).
3. **`AudioManager`** usa **`FlameAudio.play()`** (a través de `playUiSfx`) solo para sonidos únicos que deben detener todo lo demás (start, victory, defeat).
4. Las **clases del juego** (`Player`, `Enemy`) ahora llaman a `playGameSfx()`.
5. Las **pantallas** (`MenuScreen`, `GameScreen`, `ResultScreen`) manejan las transiciones llamando a `playGameBgm()`, `playMenuBgm()` o `playUiSfx()` según corresponda.

Con esto, la música de fondo sonará sin parar durante el juego, y los disparos y daños sonarán encima de ella y al mismo tiempo, como en un juego normal.
