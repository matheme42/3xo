import 'dart:async';

import 'package:frontend/types/wave_form_data.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class WaveformVisualizer extends StatefulWidget {
  final WaveformData waveformData;
  final Color activeColor;
  final Color inactiveColor;
  final AudioPlayer player;

  const WaveformVisualizer({
    super.key,
    required this.waveformData,
    required this.activeColor,
    required this.inactiveColor,
    required this.player,
  });

  @override
  WaveformVisualizerState createState() => WaveformVisualizerState();
}

class WaveformVisualizerState extends State<WaveformVisualizer> {
  Duration? _duration;
  Duration? _position;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;

  @override
  void initState() {
    super.initState();
    widget.player.getDuration().then(
      (value) => setState(() {
        _duration = value;
      }),
    );
    widget.player.getCurrentPosition().then(
      (value) => setState(() {
        _position = value;
      }),
    );
    _initStreams();
  }

  void _initStreams() {
    _durationSubscription = widget.player.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    _positionSubscription = widget.player.onPositionChanged.listen(
      (p) => setState(() => _position = p),
    );
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }

  void updatePlayerSeekWithStartDetail(DragStartDetails details) {
    if (_duration == null) return;
    final box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    final relative = localPosition.dx / box.size.width;
    final seekPosition = Duration(
      milliseconds: (relative * _duration!.inMilliseconds).round(),
    );
    widget.player.seek(seekPosition);
  }

  void updatePlayerSeekWithUpdateDetail(DragUpdateDetails details) {
    if (_duration == null) return;
    final box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    final relative = localPosition.dx / box.size.width;
    final seekPosition = Duration(
      milliseconds: (relative * _duration!.inMilliseconds).round(),
    );
    widget.player.seek(seekPosition);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      opaque: false,
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapMove: (details) {
          if (_duration == null) return;
          final box = context.findRenderObject() as RenderBox;
          final localPosition = box.globalToLocal(details.globalPosition);
          final relative = localPosition.dx / box.size.width;
          final seekPosition = Duration(
            milliseconds: (relative * _duration!.inMilliseconds).round(),
          );
          widget.player.seek(seekPosition);
        },
        onPanStart: updatePlayerSeekWithStartDetail,
        onPanUpdate: updatePlayerSeekWithUpdateDetail,
        // onHorizontalDragStart: updatePlayerSeekWithStartDetail,
        // onHorizontalDragUpdate: updatePlayerSeekWithUpdateDetail,
        // onVerticalDragStart: updatePlayerSeekWithStartDetail,
        // onVerticalDragUpdate: updatePlayerSeekWithUpdateDetail,
        onTapDown: (details) {
          if (_duration == null) return;
          final box = context.findRenderObject() as RenderBox;
          final localPosition = box.globalToLocal(details.globalPosition);
          final relative = localPosition.dx / box.size.width;
          final seekPosition = Duration(
            milliseconds: (relative * _duration!.inMilliseconds).round(),
          );
          widget.player.seek(seekPosition);
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            final barWidth = width / (widget.waveformData.bars.length * 2);
            return Row(
              children: widget.waveformData.bars.asMap().entries.map((entry) {
                final index = entry.key;
                final value = entry.value;
                final isActive = _position != null && _duration != null
                    ? index / widget.waveformData.bars.length <
                          _position!.inMilliseconds / _duration!.inMilliseconds
                    : false;
                return Container(
                  margin: EdgeInsets.only(right: barWidth),
                  width: barWidth,
                  height:
                      value * height +
                      2, // Add 2 to ensure visibility of very small bars
                  color: isActive ? widget.activeColor : widget.inactiveColor,
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
