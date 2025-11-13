// lib/game/audio_manager.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  // Player for UI SFX
  final AudioPlayer _uiSfxPlayer = AudioPlayer();

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
    // The file path needs to be relative to assets folder for AssetSource.
    // flame_audio's default prefix is assets/audio/.
    _uiSfxPlayer.play(AssetSource('audio/$filename'), volume: 1.0);
  }


  /// 6. ¡¡LA FUNCIÓN CLAVE!! Detiene BGM y SFX de UI.
  /// No necesitamos detener los pools, se detendrán solos.
  void stopAllAudio() {
    FlameAudio.bgm.stop();
    _uiSfxPlayer.stop(); // Detiene los SFX de UI

    _isMenuMusicPlaying = false;
    _isGameMusicPlaying = false;
  }
}