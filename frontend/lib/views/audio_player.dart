import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlayerWidget extends StatefulWidget {
  final AudioPlayer player;

  const AudioPlayerWidget({required this.player, super.key});

  @override
  State<StatefulWidget> createState() {
    return _AudioPlayerWidgetState();
  }
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  PlayerState? _playerState;
  Duration? _duration;
  Duration? _position;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  bool get _isPlaying => _playerState == PlayerState.playing;

  String get _durationText => _duration?.toString().split('.').first ?? '';

  String get _positionText => _position?.toString().split('.').first ?? '';

  AudioPlayer get player => widget.player;

  @override
  void initState() {
    super.initState();
    // Use initial values from player
    _playerState = player.state;
    player.getDuration().then(
      (value) => setState(() {
        _duration = value;
      }),
    );
    player.getCurrentPosition().then(
      (value) => setState(() {
        _position = value;
      }),
    );
    _initStreams();
  }

  @override
  void setState(VoidCallback fn) {
    // Subscriptions only can be closed asynchronously,
    // therefore events can occur after widget has been disposed.
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColorLight;
    final iconSize = 20.0;
    return FractionallySizedBox(
      widthFactor: 1.0,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // button play/pause next preview loop shuffle
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 150) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          key: _isPlaying
                              ? const Key('pause_button')
                              : const Key('play_button'),
                          onPressed: _isPlaying ? _pause : _play,
                          iconSize: iconSize,
                          icon: _isPlaying
                              ? const Icon(Icons.pause)
                              : const Icon(Icons.play_arrow),
                          color: color,
                        ),
                      ],
                    );
                  }
                  if (constraints.maxWidth < 200) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          key: _isPlaying
                              ? const Key('pause_button')
                              : const Key('play_button'),
                          onPressed: _isPlaying ? _pause : _play,
                          iconSize: iconSize,
                          icon: _isPlaying
                              ? const Icon(Icons.pause)
                              : const Icon(Icons.play_arrow),
                          color: color,
                        ),
                        IconButton(
                          key: const Key('previous_button'),
                          onPressed: () {
                            player.seek(Duration.zero);
                          },
                          iconSize: iconSize,
                          icon: const Icon(Icons.skip_previous),
                          color: color,
                        ),
                        IconButton(
                          key: const Key('next_button'),
                          onPressed: () {
                            // player.seek(player.duration ?? Duration.zero);
                          },
                          iconSize: iconSize,
                          icon: const Icon(Icons.skip_next),
                          color: color,
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      IconButton(
                        key: _isPlaying
                            ? const Key('pause_button')
                            : const Key('play_button'),
                        onPressed: _isPlaying ? _pause : _play,
                        iconSize: iconSize,
                        icon: _isPlaying
                            ? const Icon(Icons.pause)
                            : const Icon(Icons.play_arrow),
                        color: color,
                      ),
                      IconButton(
                        key: const Key('previous_button'),
                        onPressed: () {
                          player.seek(Duration.zero);
                        },
                        iconSize: iconSize,
                        icon: const Icon(Icons.skip_previous),
                        color: color,
                      ),
                      IconButton(
                        key: const Key('next_button'),
                        onPressed: () {
                          // player.seek(player.duration ?? Duration.zero);
                        },
                        iconSize: iconSize,
                        icon: const Icon(Icons.skip_next),
                        color: color,
                      ),
                      IconButton(
                        key: const Key('loop_button'),
                        onPressed: () {
                          player.setReleaseMode(ReleaseMode.loop);
                        },
                        iconSize: iconSize,
                        icon: const Icon(Icons.repeat),
                        color: color,
                      ),
                      IconButton(
                        key: const Key('shuffle_button'),
                        onPressed: () {
                          // player.seek(player.duration ?? Duration.zero);
                        },
                        iconSize: iconSize,
                        icon: const Icon(Icons.shuffle),
                        color: color,
                      ),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              child: Text(
                _position != null
                    ? '$_positionText / $_durationText'
                    : _duration != null
                    ? _durationText
                    : '',
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // create an vertical slider as an overlay on the right of the player, with a volume icon on the left and right of the slider
                  if (constraints.maxWidth < 150) {
                    return Container();
                  }
                  return Row(
                    children: [
                      IconButton(
                        key: const Key('volume_down_button'),
                        onPressed: () => player.setVolume(
                          (player.volume - 0.1).clamp(0.0, 1.0),
                        ),
                        iconSize: iconSize,
                        icon: const Icon(Icons.volume_down),
                        color: color,
                      ),
                      // volume slider
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: color,
                            inactiveTrackColor: color.withValues(alpha: 0.5),
                            thumbColor: color,
                            overlayColor: color.withValues(alpha: 0.2),
                            thumbShape: RoundSliderThumbShape(
                              enabledThumbRadius: 6.0,
                            ),
                            trackHeight: 2.0,
                          ),
                          child: Slider(
                            value: player.volume,
                            onChanged: (value) => player.setVolume(value),
                          ),
                        ),
                      ),
                      IconButton(
                        key: const Key('volume_up_button'),
                        onPressed: () => player.setVolume(
                          (player.volume + 0.1).clamp(0.0, 1.0),
                        ),
                        iconSize: iconSize,
                        icon: const Icon(Icons.volume_up),
                        color: color,
                      ),
                    ],
                  );
                },
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  void _initStreams() {
    _durationSubscription = player.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    _positionSubscription = player.onPositionChanged.listen(
      (p) => setState(() => _position = p),
    );

    _playerCompleteSubscription = player.onPlayerComplete.listen((event) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration.zero;
      });
    });

    _playerStateChangeSubscription = player.onPlayerStateChanged.listen((
      state,
    ) {
      setState(() {
        _playerState = state;
      });
    });
  }

  Future<void> _play() async {
    await player.resume();
    setState(() => _playerState = PlayerState.playing);
  }

  Future<void> _pause() async {
    await player.pause();
    setState(() => _playerState = PlayerState.paused);
  }
}

//#endregion
