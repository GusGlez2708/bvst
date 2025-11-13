# La Solución: Corregir el Flujo de Audio

Vamos a modificar 4 archivos clave para implementar el flujo de audio que deseas (música en menú, sonido de "start", música en juego, sonidos de victoria/derrota, y parada total al volver al menú).

#### Archivo 1: `lib/game/audio_manager.dart` (El cerebro)

Vamos a rediseñar tu Singleton. Necesita gestionar la música de fondo (BGM) y los efectos (SFX) por separado, y debe tener una función para **detener todo** de forma fiable.

**Dart**

```
// lib/game/audio_manager.dart
import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  // Banderas para saber qué música está sonando
  bool _isMenuMusicPlaying = false;
  bool _isGameMusicPlaying = false;

  /// 1. Pre-carga TODO el audio.
  /// Llama esto una sola vez al inicio de la app (en main.dart).
  Future<void> preloadAllAudio() async {
    // Aseguramos que el caché esté limpio antes de cargar
    await FlameAudio.audioCache.clearAll();
  
    await FlameAudio.audioCache.loadAll([
      // SFX
      'laser.mp3',
      'drop.mp3',
      'damage_ene.mp3',
      'damage_prota.mp3',
      'start.mp3',
    
      // BGM (Música de fondo)
      'bg_music.mp3', // Música del juego

      // --- DEBERÁS AÑADIR ESTOS ARCHIVOS ---
      // 'menu_music.mp3', // Música para el menú (añade tu archivo)
      // 'victory.mp3',    // Sonido al ganar (añade tu archivo)
      // 'defeat.mp3',     // Sonido al perder (añade tu archivo)
    ]);
  }

  /// 2. Control de Música del Menú
  void playMenuBgm() {
    if (_isGameMusicPlaying) stopGameBgm(); // Detiene la música del juego si sonaba
  
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
    if (_isMenuMusicPlaying) stopMenuBgm(); // Detiene la música del menú
  
    if (!_isGameMusicPlaying) {
      FlameAudio.bgm.play('bg_music.mp3');
      _isGameMusicPlaying = true;
    }
  }

  void stopGameBgm() {
    if (_isGameMusicPlaying) {
      FlameAudio.bgm.stop();
      _isGameMusicPlaying = false;
    }
  }

  /// 4. Reproductor de SFX (Efectos de sonido)
  void playSfx(String filename) {
    // No usamos el caché aquí, asumimos que ya está pre-cargado
    FlameAudio.play(filename);
  }

  /// 5. ¡¡LA FUNCIÓN CLAVE!! Detiene TODO.
  /// Detiene la música de fondo (BGM) y CUALQUIER SFX que esté sonando.
  void stopAllSounds() {
    FlameAudio.bgm.stop();
    FlameAudio.audioPlayer.stop(); // Detiene los SFX de FlameAudio.play()

    // Reseteamos las banderas
    _isMenuMusicPlaying = false;
    _isGameMusicPlaying = false;
  }

  // Ya no necesitamos la función reset() que borraba el caché.
  // Es mejor cargar todo una vez y solo detener/reproducir.
}
```

#### Archivo 2: `lib/main.dart` (El inicio)

Aquí llamaremos a `preloadAllAudio()` **una sola vez** cuando la app se inicia.

**Dart**

```
// lib/main.dart
import 'package:bvst/game/audio_manager.dart'; // 1. Importar
import 'package:bvst/screens/game_screen.dart';
import 'package:bvst/screens/menu_screen.dart';
import 'package:bvst/screens/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async { // 2. Convertir a async
  WidgetsFlutterBinding.ensureInitialized();
  
  // 3. Llamar a la pre-carga de audio ANTES de runApp
  await AudioManager().preloadAllAudio();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
// ... (el resto de tu archivo main.dart queda igual) ...
```

#### Archivo 3: `lib/screens/menu_screen.dart` (La bienvenida)

Convertimos esta pantalla a `StatefulWidget` para que pueda iniciar la música del menú cuando se construye.

**Dart**

```
// lib/screens/menu_screen.dart
import 'package:bvst/game/audio_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 1. Convertir a StatefulWidget
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  
  @override
  void initState() {
    super.initState();
    // 2. Reproducir música del menú al entrar a la pantalla
    AudioManager().playMenuBgm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // ... (tu decoración de gradiente y GridPaper) ...
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ... (tu Text 'Battle Chase') ...
              const SizedBox(height: 70),
              GestureDetector(
                onTap: () {
                  // 3. Flujo de audio al presionar JUGAR
                  AudioManager().stopMenuBgm(); // Detiene música de menú
                  AudioManager().playSfx('start.mp3'); // Suena el botón
                
                  // Ya NO llamamos a reset() ni a preloadSfx()
                
                  Navigator.pushNamed(context, '/game');
                },
                child: Container(
                  // ... (tu botón de JUGAR) ...
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### Archivo 4: `lib/screens/game_screen.dart` (La batalla)

Esta es la parte más importante. Aquí debemos **pausar el motor del juego** (`_game.pauseEngine()`) en cuanto `onGameOver` se dispara. Esto congela el juego y evita que el enemigo siga disparando "sonidos fantasma".

**Dart**

```
// lib/screens/game_screen.dart
import 'dart:async';
import 'package:bvst/game/audio_manager.dart';
import 'package:bvst/game/battle_game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameScreen extends StatefulWidget {
  // ... (sin cambios aquí) ...
}

class _GameScreenState extends State<GameScreen> {
  // ... (sin cambios en _countdown, _timer, _isCountingDown) ...
  late final BattleGame _game;

  @override
  void initState() {
    super.initState();
    _game = BattleGame(
      onGameOver: (hasWon) {
        if (mounted) {
          // --- ¡¡ESTA ES LA CORRECCIÓN CRÍTICA!! ---

          // 1. Pausa el motor de Flame (detiene timers de enemigos, updates, etc.)
          _game.pauseEngine(); 
        
          // 2. Detiene TODOS los sonidos del juego (BGM y SFX)
          AudioManager().stopAllSounds();

          // 3. Reproduce el sonido de victoria o derrota
          if (hasWon) {
            AudioManager().playSfx('victory.mp3'); // (Asegúrate de tener este archivo)
          } else {
            AudioManager().playSfx('defeat.mp3'); // (Asegúrate de tener este archivo)
          }

          // 4. Navega a la pantalla de resultados
          Navigator.pushReplacementNamed(
            context,
            '/result',
            arguments: {'hasWon': hasWon}, // Pasamos el bool directamente
          );
        }
      },
    );
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else {
        _timer?.cancel();
      
        // 5. Inicia la música del JUEGO (no la del menú)
        AudioManager().playGameBgm(); 
      
        setState(() {
          _isCountingDown = false;
          _game.player.startBehavior();
          _game.enemy.startBehavior();
        });
      }
    });
  }

  // ... (el resto de tu archivo: dispose, _buildButton, build) ...
  // ¡No necesita más cambios!
}
```

#### Archivo 5: `lib/screens/result_screen.dart` (El final)

Finalmente, cuando el jugador sale de la pantalla de resultados, debemos detener cualquier sonido (el de victoria o derrota) antes de volver al menú.

**Dart**

```
// lib/screens/result_screen.dart
import 'package:bvst/game/audio_manager.dart'; // 1. Importar
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultScreen extends StatelessWidget {
  // ... (sin cambios en el constructor) ...

  @override
  Widget build(BuildContext context) {
    // ... (sin cambios en 'args', 'hasWon', 'message', 'messageColor') ...

    return Scaffold(
      body: Container(
        // ... (tu decoración de fondo) ...
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ... (tu Text de mensaje) ...
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  // 2. Detener TODOS los sonidos (el de victoria/derrota)
                  AudioManager().stopAllSounds(); 
                
                  // 3. Volver al menú (esto es correcto)
                  Navigator.pushNamedAndRemoveUntil(context, '/menu', (route) => false);
                },
                // ... (el resto de tu botón) ...
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Resumen de la Tarea

1. **Reemplaza** el contenido de tu `audio_manager.dart` con el  **Archivo 1** .
2. **Añade los archivos** `menu_music.mp3`, `victory.mp3` y `defeat.mp3` a tu carpeta `assets/audio/` (y recuerda añadirlos al `pubspec.yaml` si es necesario, aunque `assets/audio/` ya parece estar incluido).
3. **Modifica** tu `main.dart` como en el **Archivo 2** (haciéndolo `async` y añadiendo `preloadAllAudio()`).
4. **Reemplaza** tu `menu_screen.dart` (de `Stateless` a `Stateful`) como en el  **Archivo 3** .
5. **Modifica** el `initState` y `_startCountdown` de tu `game_screen.dart` como en el  **Archivo 4** .
6. **Modifica** el `onPressed` de tu `result_screen.dart` como en el  **Archivo 5** .

Con estos cambios, el audio debería funcionar perfectamente en todos los ciclos de juego, ya sea ganando o perdiendo.
