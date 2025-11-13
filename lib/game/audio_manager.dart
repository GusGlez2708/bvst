import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  void startBgm() {
    FlameAudio.bgm.play('bg_music.mp3');
  }

  void stopBgm() {
    FlameAudio.bgm.stop();
  }

  void playSfx(String filename) {
    FlameAudio.play(filename);
  }

  void preloadSfx() {
    FlameAudio.audioCache.loadAll([
      'laser.mp3',
      'drop.mp3',
      'damage_ene.mp3',
      'damage_prota.mp3',
      'start.mp3',
    ]);
  }

  void reset() {
    stopBgm();
    FlameAudio.audioCache.clearAll();
  }
}
