import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:bloc/bloc.dart';
import 'package:just_audio/just_audio.dart';

import 'player_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlayerCubit extends Cubit<PlayerViewState> {
  final AudioPlayer _player;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlayerState>? _playerStateSub;

  PlayerCubit() : _player = AudioPlayer(), super(const PlayerViewState()) {
    _init();
  }

  Future<void> _init() async {
    try {
      // Configure audio session (mobile platforms)
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (_) {
      // It's safe to ignore on unsupported platforms like web.
    }

    _positionSub = _player.positionStream.listen((pos) {
      emit(state.copyWith(position: pos));
    });
    _durationSub = _player.durationStream.listen((dur) {
      emit(state.copyWith(duration: dur ?? Duration.zero));
    });
    _playerStateSub = _player.playerStateStream.listen((ps) {
      final playing = ps.playing;
      final buffering =
          ps.processingState == ProcessingState.loading ||
          ps.processingState == ProcessingState.buffering;
      emit(state.copyWith(playing: playing, buffering: buffering));
    });
  }

  Future<void> playTrack(PlayerTrack track) async {
    emit(state.copyWith(track: track, buffering: true));
    try {
      // Ensure Authorization header is sent when available and not already provided
      final token = Supabase.instance.client.auth.currentSession?.accessToken;
      final headers = <String, String>{
        if (track.headers != null) ...track.headers!,
        if (token != null &&
            token.isNotEmpty &&
            (track.headers == null ||
                !track.headers!.containsKey('Authorization')))
          'Authorization': 'Bearer $token',
        'Accept':
            'application/vnd.apple.mpegurl,application/x-mpegURL,application/json',
      };
      // Prefer AudioSource.uri for explicit header control
      final uri = Uri.parse(track.url);
      await _player.setAudioSource(
        AudioSource.uri(uri, headers: headers.isEmpty ? null : headers),
      );
      await _player.play();
    } catch (e) {
      // On failure, stop buffering and ensure not playing
      emit(state.copyWith(buffering: false, playing: false));
    }
  }

  Future<void> togglePlayPause() async {
    if (state.buffering) return;
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
    emit(state.copyWith(volume: volume));
  }

  @override
  Future<void> close() async {
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _playerStateSub?.cancel();
    await _player.dispose();
    return super.close();
  }
}
