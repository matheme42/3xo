import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  static bool _webAudioUnlocked = !kIsWeb;
  static const double _defaultPlaybackVolume = 1.0;

  final AudioPlayer _audioPlayer = AudioPlayer();
  AnimationController? animationController;
  void Function()? animationListener;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  String? _loadedUrl;
  _PlayRequest? _pendingPlayRequest;

  AudioPlayerService() {
    _audioPlayer.setVolume(_defaultPlaybackVolume);
  }

  bool get hasPendingPlayRequest => _pendingPlayRequest != null;

  static void unlockWebAudio() {
    _webAudioUnlocked = true;
  }

  Future<void> preloadAudio(String url) async {
    try {
      if (_loadedUrl == url) {
        return;
      }

      if (url.startsWith('http') || url.startsWith('https')) {
        // Si l'URL est un lien HTTP, utilisez setUrl.
        await _audioPlayer.setUrl(url);
      } else if (url.startsWith('assets/')) {
        // Les assets Flutter doivent etre charges via le bundle,
        // en particulier sur le web ou il n'existe pas de file path local.
        await _audioPlayer.setAsset(url);
      } else {
        // Sinon, utilisez setFilePath pour les fichiers locaux reels.
        await _audioPlayer.setFilePath(url);
      }

      _loadedUrl = url;
    } catch (e) {
      print('Erreur lors du chargement audio: $e');
    }
  }

  void fadeInVolume(Duration duration, TickerProvider vsync) {
    if (animationController != null && animationListener != null) {
      animationController!.removeListener(animationListener!);
    }
    animationController = AnimationController(vsync: vsync, duration: duration);
    Animation<double> animation =
        Tween<double>(begin: 0.0, end: _defaultPlaybackVolume).animate(
          CurvedAnimation(
            parent: animationController!,
            curve: Interval(0.0, 1.0, curve: Curves.easeIn),
          ),
        );
    animationListener = () {
      _audioPlayer.setVolume(animation.value);
    };
    animation.addListener(animationListener!);
    animationController!.forward();
  }

  void fadeOutVolume(Duration duration, TickerProvider vsync) {
    if (animationController != null && animationListener != null) {
      animationController!.removeListener(animationListener!);
    }
    animationController = AnimationController(vsync: vsync, duration: duration);
    Animation<double> animation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: animationController!,
        curve: Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );
    animationListener = () {
      _audioPlayer.setVolume(animation.value);
    };
    animation.addListener(animationListener!);
    animationController!.forward();
  }

  Future<void> play({
    String? url,
    required TickerProvider vsync,
    bool restartIfAlreadyPlaying = false,
    bool fadeIn = true,
    bool loop = true,
    bool waitForUserInteractionOnWeb = false,
  }) async {
    final request = _PlayRequest(
      url: url,
      vsync: vsync,
      restartIfAlreadyPlaying: restartIfAlreadyPlaying,
      fadeIn: fadeIn,
      loop: loop,
      waitForUserInteractionOnWeb: waitForUserInteractionOnWeb,
    );

    print(
      'Tentative de lecture audio avec URL: $url etat de lecture actuel: ${_audioPlayer.playing}',
    );

    if (_audioPlayer.playerState.playing && !restartIfAlreadyPlaying) {
      // Si la musique est déjà en cours de lecture, ne rien faire
      print('La musique est déjà en cours de lecture.');
      return;
    }

    print('Chargement de l\'audio depuis l\'URL: $url');
    if (request.url != null) {
      await preloadAudio(request.url!);
    }

    print('Lecture audio prête à démarrer avec URL: ${request.url}');
    if (kIsWeb && request.waitForUserInteractionOnWeb && !_webAudioUnlocked) {
      _pendingPlayRequest = request;
      print(
        'Lecture audio mise en attente jusqu\'a la premiere interaction utilisateur.',
      );
      return;
    }

    try {
      await _audioPlayer.setLoopMode(
        request.loop ? LoopMode.all : LoopMode.off,
      ); // Boucle la musique

      await _audioPlayer.setVolume(
        request.fadeIn ? 0.0 : _defaultPlaybackVolume,
      );

      if (_audioPlayer.playing && request.restartIfAlreadyPlaying) {
        await _audioPlayer.seek(Duration.zero);
      } else if (!_audioPlayer.playing) {
        await _audioPlayer.seek(Duration.zero);
      }

      print('Démarrage de la lecture audio avec URL: ${request.url}');
      final playFuture = _audioPlayer.play();
      _pendingPlayRequest = null;

      await _playerStateSubscription?.cancel();
      _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          print('Lecture audio terminée.');
          if (!request.loop) {
            _audioPlayer.seek(Duration.zero);
            _audioPlayer.stop();
          }
        }
      });

      // Augmentez progressivement le volume jusqu'à 1.0 sur la durée du fondu
      if (request.fadeIn) {
        fadeInVolume(Duration(seconds: 2), request.vsync);
      }

      unawaited(
        playFuture.catchError((Object error, StackTrace stackTrace) {
          if (kIsWeb) {
            _pendingPlayRequest = request;
          }
          print('Erreur lors de la lecture audio: $error');
        }),
      );

      print('Lecture audio commencée avec fondu en entrée.');
    } catch (e) {
      if (kIsWeb) {
        _pendingPlayRequest = request;
      }
      print('Erreur lors de la lecture audio: $e');
    }
  }

  Future<void> retryPendingPlayRequest() async {
    final request = _pendingPlayRequest;
    if (request == null) {
      return;
    }

    _pendingPlayRequest = null;
    await play(
      url: request.url,
      vsync: request.vsync,
      restartIfAlreadyPlaying: request.restartIfAlreadyPlaying,
      fadeIn: request.fadeIn,
      loop: request.loop,
    );
  }

  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      print('Erreur lors de la mise en pause audio: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('Erreur lors de l\'arrêt audio: $e');
    }
  }

  Future<void> dispose() async {
    await _playerStateSubscription?.cancel();
    animationController?.dispose();
    await _audioPlayer.dispose();
  }

  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume);
    } catch (e) {
      print('Erreur lors du réglage du volume: $e');
    }
  }
}

class _PlayRequest {
  final String? url;
  final TickerProvider vsync;
  final bool restartIfAlreadyPlaying;
  final bool fadeIn;
  final bool loop;
  final bool waitForUserInteractionOnWeb;

  const _PlayRequest({
    required this.url,
    required this.vsync,
    required this.restartIfAlreadyPlaying,
    required this.fadeIn,
    required this.loop,
    required this.waitForUserInteractionOnWeb,
  });
}
