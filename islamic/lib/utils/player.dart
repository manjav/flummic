import 'dart:async';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:islamic/models.dart';
import 'package:just_audio/just_audio.dart';

class PlayerAya {
  int? sura, aya;
  PlayerAya(Aya a) {
    sura = a.sura;
    aya = a.aya;
  }
}

class Sound {
  String? url, path, name, ename, mode;
  Sound(p) {
    name = p["name"];
    ename = p["ename"] ?? p["name"];
    url = p["url"];
    path = p["path"];
    mode = p["mode"];
  }
  String getURL(int sura, int aya) {
    return "$url/${fill(sura + 1)}${fill(aya + 1)}.mp3";
  }

  String fill(int number) {
    if (number < 10) return "00$number";
    if (number < 100) return "0$number";
    return "$number";
  }
}

/// An [AudioHandler] for playing a single item.
class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();
  int index = 0;
  int soundIndex = 0;
  List<PlayerAya>? ayas;
  List<Sound>? sounds;
  List<String>? suras;

  /// Initialise our audio handler.
  AudioPlayerHandler() {
    // So that our clients (the Flutter UI and the system notification) know
    // what state to display, here we set up our audio handler to broadcast all
    // playback state changes as they happen via playbackState...
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    // ... and also the current media item via mediaItem.
    // mediaItem.add(_item);

    // Load the player.
    // _player.setAudioSource(AudioSource.uri(Uri.parse(_item.id)));

    ayas = <PlayerAya>[];
    var list = Configs.instance.navigations["all"]![0];
    for (var a in list) ayas!.add(PlayerAya(a));
    customEvent.add('{"type":"start"}');
  }

  // In this simple example, we handle only 4 actions: play, pause, seek and
  // stop. Any button press from the Flutter UI, notification, lock screen or
  // headset will be routed through to these 4 methods so that you can handle
  // your audio playback logic in one place.

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() {
    customEvent.add('{"type":"stop"}');
    return _player.stop();
  }

  /// Transform a just_audio event into an audio_service state.
  /// This method is used from the constructor. Every event received from the
  /// just_audio player will be transformed into an audio_service state so that
  /// it can be broadcast to audio_service clients.
  PlaybackState _transformEvent(PlaybackEvent event) {
    if (_player.processingState == ProcessingState.completed) {
      _onComplete(); // select(index, soundIndex)
    }
    return PlaybackState(
      controls: [
        // MediaControl.rewind,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        // MediaControl.fastForward,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }

  @override
  Future<dynamic> customAction(String name,
      [Map<String, dynamic>? extras]) async {
    switch (name) {
      case 'update':
        sounds = <Sound>[];
        var list = json.decode(extras!["sounds"]);
        for (var s in list) sounds!.add(Sound(s));

        var _suras = extras["suras"];
        suras = <String>[];
        for (var s in _suras) suras!.add(s);
        break;

      case 'select':
        index = extras!["index"];
        select(index, 0);
        break;
    }
    super.customAction(name, extras);
  }

  select(int index, int soundIndex) async {
    this.soundIndex = soundIndex;
    var aya = ayas![index];
    var sound = sounds![soundIndex];
    var url = sound.getURL(aya.sura!, aya.aya!);
    var duration = await _player.setUrl(url);
    var mediaItem = MediaItem(
        artUri: Uri.parse("https://hidaya.sarand.net/images/${sound.path}.png"),
        title: "${suras![aya.sura!]} (${aya.aya! + 1})",
        artist: sound.name,
        album: sound.ename!,
        id: url,
        duration: duration);
    addQueueItem(mediaItem);
    customEvent.add('{"type":"select", "data":[$index, $soundIndex]}');
    play();
  }

  _onComplete() async {
    if (index >= ayas!.length - 1) {
      stop();
    }
    if (soundIndex >= sounds!.length - 1) {
      soundIndex = 0;
      index++;
    } else {
      soundIndex++;
    }
    await Future.delayed(Duration(milliseconds: 100));
    select(index, soundIndex);
  }
}
