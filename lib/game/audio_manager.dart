// lib/game/audio_manager.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  // Player for UI SFX
  final AudioPlayer _uiSfxPlayer = AudioPlayer();

  // --- Settings ---
  bool _bgmMuted = false;
  bool _sfxMuted = false;
  double _bgmVolume = 0.5;
  double _sfxVolume = 1.0;

  // --- State ---
  bool _isMenuMusicPlaying = false;
  bool _isGameMusicPlaying = false;
  final List<void Function()> _activeSfxStopFunctions = [];

  // --- Public accessors for settings ---
  bool get bgmEnabled => !_bgmMuted;
  set bgmEnabled(bool value) {
    _bgmMuted = !value;
    if (_bgmMuted) {
      FlameAudio.bgm.stop();
    } else {
      if (_isMenuMusicPlaying) {
        playMenuBgm();
      } else if (_isGameMusicPlaying) {
        playGameBgm();
      }
    }
  }

  bool get sfxEnabled => !_sfxMuted;
  set sfxEnabled(bool value) {
    _sfxMuted = !value;
    if (_sfxMuted) {
      stopAllPooledSfx();
    }
  }

  double get bgmVolume => _bgmVolume;
  set bgmVolume(double value) {
    _bgmVolume = value;
    FlameAudio.bgm.audioPlayer.setVolume(value);
  }

  double get sfxVolume => _sfxVolume;
  set sfxVolume(double value) {
    _sfxVolume = value;
  }

  // --- GRUPOS DE AUDIO (POOLS) PARA EL JUEGO ---
  late AudioPool laserPool;
  late AudioPool dropPool;
  late AudioPool damageEnePool;
  late AudioPool damageProtaPool;
  late AudioPool fuegoPool;

  /// 1. Pre-carga TODO el audio.
  Future<void> preloadAllAudio() async {
    await FlameAudio.audioCache.clearAll();

    laserPool = await FlameAudio.createPool('laser.mp3', maxPlayers: 5);
    dropPool = await FlameAudio.createPool('drop.mp3', maxPlayers: 5);
    damageEnePool = await FlameAudio.createPool('damage_ene.mp3', maxPlayers: 3);
    damageProtaPool = await FlameAudio.createPool('damage_prota.mp3', maxPlayers: 3);
    fuegoPool = await FlameAudio.createPool('Fuego.mp3', maxPlayers: 5);

    await FlameAudio.audioCache.loadAll([
      'start.mp3',
      'bg_music.mp3',
      'menu_music.mp3',
      'victory.mp3',
      'defeat.mp3',
      'FireUnder.mp3',
      'musica_lvl3.mp3', // Level 3 background music
      'poder_lvl3.mp3', // Level 3 slow power
      'musica_lvl4.mp3', // Level 4 background music
      'poder_lvl4.mp3', // Level 4 weakening power
      'debilidad_lvl4.mp3', // Level 4 weakness loop
    ]);
  }

  /// 2. Control de Música del Menú
  void playMenuBgm() {
    stopAllAudio();
    _isMenuMusicPlaying = true;
    _isGameMusicPlaying = false;
    if (!_bgmMuted) {
      FlameAudio.bgm.play('menu_music.mp3', volume: _bgmVolume);
    }
  }

  void stopMenuBgm() {
    if (_isMenuMusicPlaying) {
      FlameAudio.bgm.stop();
      _isMenuMusicPlaying = false;
    }
  }

  /// Pause menu background music
  void pauseMenuBgm() {
    if (_isMenuMusicPlaying && !_bgmMuted) {
      FlameAudio.bgm.pause();
    }
  }

  /// Resume menu background music
  void resumeMenuBgm() {
    if (_isMenuMusicPlaying && !_bgmMuted) {
      FlameAudio.bgm.resume();
    }
  }

  /// 3. Control de Música del Juego
  void playGameBgm([String musicFile = 'bg_music.mp3']) {
    stopAllAudio();
    _isGameMusicPlaying = true;
    _isMenuMusicPlaying = false;
    if (!_bgmMuted) {
      FlameAudio.bgm.play(musicFile, volume: _bgmVolume);
    }
  }

  void stopGameBgm() {
    if (_isGameMusicPlaying) {
      FlameAudio.bgm.stop();
      _isGameMusicPlaying = false;
    }
  }

  /// Pause game background music
  void pauseGameBgm() {
    if (_isGameMusicPlaying && !_bgmMuted) {
      FlameAudio.bgm.pause();
    }
  }

  /// Resume game background music
  void resumeGameBgm() {
    if (_isGameMusicPlaying && !_bgmMuted) {
      FlameAudio.bgm.resume();
    }
  }

  /// 4. Reproductor de SFX del JUEGO
  void playGameSfx(String filename) {
    if (_sfxMuted || !_isGameMusicPlaying) return;

    switch (filename) {
      case 'laser.mp3':
        laserPool.start(volume: _sfxVolume * 0.8);
        break;
      case 'drop.mp3':
        dropPool.start(volume: _sfxVolume * 0.8);
        break;
      case 'damage_ene.mp3':
        damageEnePool.start(volume: _sfxVolume * 1.0);
        break;
      case 'damage_prota.mp3':
        damageProtaPool.start(volume: _sfxVolume * 1.0);
        break;
      case 'Fuego.mp3':
        fuegoPool.start(volume: _sfxVolume * 0.7).then((stopper) {
          _activeSfxStopFunctions.add(stopper);
        });
        break;
    }
  }

  /// 5. Reproductor de SFX de UI
  void playUiSfx(String filename) {
    // stopAllAudio(); // <-- REMOVED: Don't stop BGM/SFX when playing UI sounds
    if (_sfxMuted) return;
    _uiSfxPlayer.play(AssetSource('audio/$filename'), volume: _sfxVolume);
  }

  /// 6. Detiene todos los SFX de los pools que estamos rastreando.
  void stopAllPooledSfx() {
    for (final stopFunction in _activeSfxStopFunctions) {
      stopFunction();
    }
    _activeSfxStopFunctions.clear();
  }

  /// 7. Detiene TODA la reproducción de audio.
  void stopAllAudio() {
    FlameAudio.bgm.stop();
    _uiSfxPlayer.stop();
    stopAllPooledSfx(); // Llama a nuestro nuevo método

    _isMenuMusicPlaying = false;
    _isGameMusicPlaying = false;
  }
}
