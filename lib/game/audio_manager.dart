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

  // --- Public accessors for settings ---
  bool get bgmEnabled => !_bgmMuted;
  set bgmEnabled(bool value) {
    _bgmMuted = !value;
    if (_bgmMuted) {
      FlameAudio.bgm.stop();
    } else {
      // If BGM was just re-enabled, check which track should be playing
      // based on our flags, and restart it.
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

  late AudioPool fireUnderPool;
  late AudioPool fuegoPool;

  bool _isMenuMusicPlaying = false;
  bool _isGameMusicPlaying = false;

  /// 1. Pre-carga TODO el audio.
  Future<void> preloadAllAudio() async {
    await FlameAudio.audioCache.clearAll();

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
    fireUnderPool = await FlameAudio.createPool(
      'FireUnder.mp3',
      minPlayers: 3,
      maxPlayers: 5,
    );
    fuegoPool = await FlameAudio.createPool(
      'Fuego.mp3',
      minPlayers: 3,
      maxPlayers: 5,
    );

    await FlameAudio.audioCache.loadAll([
      'start.mp3',
      'bg_music.mp3',
      'menu_music.mp3',
      'victory.mp3',
      'defeat.mp3',
    ]);
  }

  /// 2. Control de Música del Menú
  void playMenuBgm() {
    stopAllAudio();

    // Set the state for the menu screen
    _isMenuMusicPlaying = true;
    _isGameMusicPlaying = false;

    // Now, handle the audio
    if (_bgmMuted) return;

    FlameAudio.bgm.play('menu_music.mp3', volume: _bgmVolume);
  }

  void stopMenuBgm() {
    if (_isMenuMusicPlaying) {
      FlameAudio.bgm.stop();
      _isMenuMusicPlaying = false;
    }
  }

  /// 3. Control de Música del Juego
  void playGameBgm() {
    stopAllAudio();

    // Set the state for the game screen
    _isGameMusicPlaying = true;
    _isMenuMusicPlaying = false;

    // Now, handle the audio
    if (_bgmMuted) return;

    FlameAudio.bgm.play('bg_music.mp3', volume: _bgmVolume);
  }

  void stopGameBgm() {
    if (_isGameMusicPlaying) {
      FlameAudio.bgm.stop();
      _isGameMusicPlaying = false;
    }
  }

  /// 4. Reproductor de SFX del JUEGO (Usa POOLS)
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
      case 'FireUnder.mp3':
        fireUnderPool.start(volume: _sfxVolume * 1.0);
        break;
      case 'Fuego.mp3':
        fuegoPool.start(volume: _sfxVolume * 1.0);
        break;
    }
  }

  /// 5. Reproductor de SFX de UI
  void playUiSfx(String filename) {
    stopAllAudio();
    if (_sfxMuted) return;
    _uiSfxPlayer.play(AssetSource('audio/$filename'), volume: _sfxVolume);
  }

  /// 6. Detiene BGM y SFX de UI.
  void stopAllAudio() {
    FlameAudio.bgm.stop();
    _uiSfxPlayer.stop();

    _isMenuMusicPlaying = false;
    _isGameMusicPlaying = false;
  }
}
