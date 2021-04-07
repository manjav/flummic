import 'package:audioplayers/audioplayers.dart';

import '../models.dart';

class Player {
  AudioPlayer player;
  Person get sound =>
      Configs.instance.sounds[Prefs.persons[PType.sound][index]];
  int sura, aya, index = 0;
  AudioPlayerState playerState;

  Function(AudioPlayerState state) onStateChange;

  Player() {
    AudioPlayer.logEnabled = false;
    player = AudioPlayer();
    player.onPlayerStateChanged.listen(onPlayerStateChanged);
  }

  Future<void> select(int sura, int aya, int index, bool autoPlay) async {
    print("select sura $sura aya $aya index $index");
    this.sura = sura;
    this.aya = aya;
    this.index = index;

    if (!autoPlay) {
      playerState = AudioPlayerState.STOPPED;
      return;
    }
    await player.play(sound.getURL(sura, aya));
  }

  Future<void> toggle() async {
    if (playerState == AudioPlayerState.STOPPED)
      await player.play(sound.getURL(sura, aya));
    if (playerState == AudioPlayerState.PLAYING)
      player.pause();
    else
      player.resume();
  }

  void pause() {
    player.pause();
  }

  void onPlayerStateChanged(AudioPlayerState state) {
    playerState = state;
    if (onStateChange != null) onStateChange(state);
    if (state != AudioPlayerState.COMPLETED) return;
    print("change sura $sura aya $aya index $index");
    if (index >= Prefs.persons[PType.sound].length - 1) {
      if (aya >= Configs.instance.metadata.suras[sura].ayas - 1) {
        if (sura >= Configs.instance.metadata.suras.length - 1) return;
        select(sura + 1, 0, 0, true);
      } else {
        select(sura, aya + 1, 0, true);
      }
    } else {
      select(sura, aya, index + 1, true);
    }
  }
}
