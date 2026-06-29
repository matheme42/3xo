import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  AnimationController? animationController;
  void Function()? animationListener;

  Future<void> preloadAudio(String url) async {
    try {
      if (url.startsWith('http') || url.startsWith('https')) {
        // Si l'URL est un lien HTTP, utilisez setUrl
        await _audioPlayer.setUrl(url);
      } else {
        // Sinon, utilisez setFilePath pour les fichiers locaux
        await _audioPlayer.setFilePath(url);
      }
    } catch (e) {
      print('Erreur lors du chargement audio: $e');
    }
  }

  void fadeInVolume(Duration duration, TickerProvider vsync) {
    if (animationController != null && animationListener != null) {
      animationController!.removeListener(animationListener!);
    }
    animationController = AnimationController(vsync: vsync, duration: duration);
    Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0).animate(
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
  }) async {
    print(
      'Tentative de lecture audio avec URL: $url etat de lecture actuel: ${_audioPlayer.playing}',
    );

    if (_audioPlayer.playerState.playing && !restartIfAlreadyPlaying) {
      // Si la musique est déjà en cours de lecture, ne rien faire
      print('La musique est déjà en cours de lecture.');
      return;
    }

    try {
      if (url != null) {
        await preloadAudio(url);
      }
      // Commencez la lecture avec un fondu en entrée
      if (fadeIn) {
        await _audioPlayer.setVolume(fadeIn ? 0.0 : 1.0);
      }
      await _audioPlayer.stop(); // Arrêtez la lecture précédente si nécessaire
      await _audioPlayer.play();
      await _audioPlayer.setLoopMode(
        loop ? LoopMode.all : LoopMode.off,
      ); // Boucle la musique

      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          print('Lecture audio terminée.');
          if (!loop) {
            _audioPlayer.seek(Duration.zero);
            _audioPlayer.stop();
          }
        }
      });

      // Augmentez progressivement le volume jusqu'à 1.0 sur la durée du fondu
      if (fadeIn) {
        fadeInVolume(Duration(seconds: 2), vsync);
      }
      print('Lecture audio commencée avec fondu en entrée.');
    } catch (e) {
      print('Erreur lors de la lecture audio: $e');
    }
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
