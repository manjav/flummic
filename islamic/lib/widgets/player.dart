import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models.dart';

class Player {
  static Player instance;
  AudioPlayer player;
  AudioPlayerState playerState;
  int index, sura, aya;
  List<Person> sounds;

  Function(int sura, int aya, int index) listener;

  Player() {
    // AudioPlayer.logEnabled = true;
    player = AudioPlayer();
    player.onPlayerStateChanged.listen(onPlayerStateChanged);

    sounds = <Person>[];
    for (var s in Prefs.persons[PType.sound])
      sounds.add(Configs.instance.sounds[s]);
  }

  static Widget create(int sura, int aya, Function(int, int, int) listener) {
    if (instance == null) {
      instance = Player();
      instance.init(sura, aya, 0, false);
    }
    instance.listener = listener;
    return Stack(children: [
      IconButton(
          icon: Icon(instance.playerState == AudioPlayerState.PLAYING
              ? Icons.pause
              : Icons.play_arrow),
          onPressed: instance.toggle)
    ]);
  }

  Future<void> init(int sura, int aya, int index, bool autoPlay) async {
    this.sura = sura;
    this.aya = aya;
    this.index = index;

    if (!autoPlay) {
      playerState = AudioPlayerState.STOPPED;
      return;
    }
    int result = await player.play(sounds[index].getURL(sura, aya));
    if (result == 1 && listener != null) listener(sura, aya, index);
  }

  Future<void> toggle() async {
    if (playerState == AudioPlayerState.STOPPED)
      await player.play(sounds[index].getURL(sura, aya));
    if (playerState == AudioPlayerState.PLAYING)
      player.pause();
    else
      player.resume();
  }

  void onPlayerStateChanged(AudioPlayerState state) {
    playerState = state;
    if (state == AudioPlayerState.COMPLETED) {
      if (index >= sounds.length - 1) {
        if (aya >= Configs.instance.metadata.suras[sura].ayas - 1) {
          if (sura >= Configs.instance.metadata.suras.length - 1) return;
          init(sura + 1, 0, 0, true);
        } else {
          init(sura, aya + 1, 0, true);
        }
      } else {
        init(sura, aya, index + 1, true);
      }
    }
  }
}
