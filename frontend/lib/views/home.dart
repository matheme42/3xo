import 'dart:async';
import 'dart:math' as math;

import 'package:frontend/types/wave_form_data.dart';
import 'package:frontend/views/navigation_bar.dart';
import 'package:frontend/views/waveform_visualisateur.dart';
import 'package:frontend/wavsample.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/browser_client.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import '../context.dart';
import '../widgets/glass_container.dart';
import 'audio_player.dart';
import 'overview.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  late AudioPlayer player = AudioPlayer();
  PageController pageController = PageController(viewportFraction: 0.99);
  GlobalKey overviewKey = GlobalKey();
  int currentMusicIndex = 0;
  WaveformData? waveformData;
  FocusNode? keyboardFocusNode;
  ValueNotifier<bool> loaded = ValueNotifier<bool>(false);
  String currentAudioUrl = 'filante_ambiance.mp3';

  @override
  void initState() {
    super.initState();

    keyboardFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (keyboardFocusNode != null) {
        FocusScope.of(context).requestFocus(keyboardFocusNode);
      }
    });
    // Create the audio player.
    player = AudioPlayer();

    // Set the release mode to keep the source after playback has completed.
    player.setReleaseMode(ReleaseMode.stop);
    pageController.addListener(onPageChanged);
    // Start the player as soon as the app is displayed.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await player.setSource(AssetSource(currentAudioUrl)).then((_) async {
        await player.setVolume(0).then((_) async {
          await Future.delayed(Duration(milliseconds: 100)).then((_) async {
            await player.resume();
          });
        });
      });
      // await player.resume();
      // waveformData = await RealWaveformGenerator.generateWaveformFromAudio(
      //   "https://fr.getsamplefiles.com/download/wav/sample-2.wav",
      //   targetBars: 450,
      //   maxHeight: 1.0,
      //   minHeight: 0.0,
      //   isAsset: false,
      // );
    });
  }

  void onPageChanged() {
    setState(() {
      currentMusicIndex = pageController.page?.round() ?? 0;
    });
  }

  @override
  void dispose() {
    // Release all sources and dispose the player.
    player.dispose();

    super.dispose();
  }

  void onKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) {
      return;
    }
    int musicCount = Provider.of<AppContext>(
      context,
      listen: false,
    ).music.length;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.space: // Space
        if (player.state == PlayerState.playing) {
          player.pause();
        } else {
          player.resume();
        }
        break;
      case LogicalKeyboardKey.arrowRight: // Right Arrow
        if (currentMusicIndex < musicCount - 1) {
          currentMusicIndex++;
        }
        pageController.animateToPage(
          currentMusicIndex,
          duration: Duration(milliseconds: 300),
          curve: Curves.linear,
        );
        break;
      case LogicalKeyboardKey.arrowLeft: // Left Arrow
        if (currentMusicIndex > 0) {
          currentMusicIndex--;
        }
        pageController.animateToPage(
          currentMusicIndex,
          duration: Duration(milliseconds: 300),
          curve: Curves.linear,
        );
        break;
      // case LogicalKeyboardKey.arrowUp: // Up Arrow
      //   player.setVolume((player.volume + 0.1).clamp(0.0, 1.0));
      //   break;
      // case LogicalKeyboardKey.arrowDown: // Down Arrow
      //   player.setVolume((player.volume - 0.1).clamp(0.0, 1.0));
      //   break;
      case LogicalKeyboardKey.backspace: // return key
        player.stop();
        break;
      default:
        break;
    }
    pageController.animateToPage(
      currentMusicIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.linear,
    );
  }

  static Future<Uint8List> downloadFile(String url) async {
    final client = BrowserClient();
    final request = Request('GET', Uri.parse(url));
    final response = await client.send(request);
    final completer = Completer<Uint8List>();
    completer.complete(response.stream.toBytes());
    return completer.future;
  }

  WaveformData generateWaveformData(List<double> samples, int barCount) {
    final int sampleCount = samples.length;

    final Float32List centered = Float32List(sampleCount);

    // conversion 0..1 -> -1..1
    for (int i = 0; i < sampleCount; i++) {
      centered[i] = (samples[i] - 0.5) * 2.0;
    }

    final Float32List bars = Float32List(barCount);

    final int samplesPerBar = (sampleCount / barCount).floor();

    for (int i = 0; i < barCount; i++) {
      int start = i * samplesPerBar;
      int end = math.min(start + samplesPerBar, sampleCount);

      double sum = 0;
      double peak = 0;

      for (int j = start; j < end; j++) {
        double v = centered[j].abs();

        sum += v * v;

        if (v > peak) peak = v;
      }

      int len = end - start;

      double rms = len > 0 ? math.sqrt(sum / len) : 0;

      // mix perceptuel
      double energy = rms * 0.7 + peak * 0.3;

      // compression logarithmique (perception humaine)
      energy = math.log(1 + energy * 9) / math.log(10);

      bars[i] = energy.toDouble();
    }

    // normalisation
    double maxVal = 0;
    for (final v in bars) {
      if (v > maxVal) maxVal = v;
    }

    if (maxVal > 0) {
      for (int i = 0; i < bars.length; i++) {
        bars[i] /= maxVal;
      }
    }

    // smoothing
    for (int i = 1; i < bars.length; i++) {
      bars[i] = bars[i - 1] * 0.6 + bars[i] * 0.4;
    }

    return WaveformData(bars);
  }

  // function that fade in audio when user click on the screen and resume audio when user click again
  // with a fade in and fade out effect
  Future<void> fadeAudio() async {
    if (player.state != PlayerState.playing) {
      // fade in
      player.resume();
      double i = 0;
      while (i <= 0.2) {
        await Future.delayed(Duration(milliseconds: 250), () {
          player.setVolume(i);
        });
        i += 0.01;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (keyboardFocusNode != null) {
          FocusScope.of(context).requestFocus(keyboardFocusNode);
          fadeAudio();
        }
      },
      child: KeyboardListener(
        onKeyEvent: onKeyEvent,
        autofocus: true,
        focusNode: keyboardFocusNode!,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              alignment: Alignment.center,
              "assets/gemini_background.png",
              fit: BoxFit.cover,
            ),
            // Consumer<AppContext>(
            //   builder: (context, appContext, child) {
            //     if (appContext.music.isEmpty) {
            //       return Scaffold(
            //         body: Center(child: CircularProgressIndicator()),
            //       );
            //     }
            //     return Scaffold(
            //       floatingActionButton: FloatingActionButton(
            //         onPressed: () {
            //           AudioReader.fromUrl(currentAudioUrl)
            //               .then((wavSamples) {
            //                 waveformData = generateWaveformData(
            //                   wavSamples.samples,
            //                   400,
            //                 );
            //                 setState(() {
            //                   loaded.value = true;
            //                 });
            //               })
            //               .catchError((error) {
            //                 debugPrint('Error loading WAV file: $error');
            //               });
            //           // onClickFloatingActionButton().then((data) {
            //           //   waveformData = _generateFromRealAmplitudeData(
            //           //     data,
            //           //     450,
            //           //     minHeight: 0.0,
            //           //     maxHeight: 1.0,
            //           //   );
            //           //   setState(() {
            //           //     loaded.value = true;
            //           //   });
            //           // });
            //         },
            //         child: Icon(
            //           player.state == PlayerState.playing
            //               ? Icons.pause
            //               : Icons.play_arrow,
            //         ),
            //       ),
            //       backgroundColor: Colors.transparent,
            //       body: Row(
            //         children: <Widget>[
            //           HomeNavigationBar(
            //             currentMusicIndex: currentMusicIndex,
            //             pageController: pageController,
            //           ),
            //           // Divider with gradient effect
            //           Container(
            //             width: 2,
            //             height: double.infinity,
            //             decoration: BoxDecoration(
            //               gradient: LinearGradient(
            //                 begin: Alignment.topCenter,
            //                 end: Alignment.bottomCenter,
            //                 colors: [
            //                   Colors.white10,
            //                   Colors.white30,
            //                   Colors.white60,
            //                   Colors.white60,
            //                   Colors.white30,
            //                   Colors.white10,
            //                 ],
            //                 stops: [0.0, 0.1, 0.2, 0.4, 0.9, 1.0],
            //               ),
            //             ),
            //           ),
            //           Expanded(
            //             child: Center(
            //               child: Column(
            //                 children: [
            //                   Expanded(
            //                     flex: 12,
            //                     child: MusicOverview(
            //                       music: appContext.music,
            //                       pageController: pageController,
            //                       key: overviewKey,
            //                     ),
            //                   ),
            //                   Flexible(
            //                     flex: 2,
            //                     child: FractionallySizedBox(
            //                       heightFactor: 1,
            //                       widthFactor: 1,
            //                       // display the waveform data
            //                       child: Center(
            //                         child: ValueListenableBuilder<bool>(
            //                           valueListenable: loaded,
            //                           builder: (context, value, child) {
            //                             if (!value) {
            //                               return Center(
            //                                 child: CircularProgressIndicator(),
            //                               );
            //                             }

            //                             return Padding(
            //                               padding: const EdgeInsets.only(
            //                                 left: 8.0,
            //                               ),
            //                               child: ClipRRect(
            //                                 borderRadius: BorderRadius.only(
            //                                   topLeft: Radius.circular(16.0),
            //                                 ),
            //                                 child: Row(
            //                                   children: [
            //                                     // Divider with gradient effect
            //                                     Container(
            //                                       width: 2,
            //                                       height: double.infinity,
            //                                       decoration: BoxDecoration(
            //                                         gradient: LinearGradient(
            //                                           begin: Alignment.topCenter,
            //                                           end: Alignment.bottomCenter,
            //                                           colors: [
            //                                             Colors.white10,
            //                                             Colors.white30,
            //                                             Colors.white60,
            //                                             Colors.white60,
            //                                             Colors.white30,
            //                                             Colors.white10,
            //                                           ],
            //                                           stops: [
            //                                             0.0,
            //                                             0.1,
            //                                             0.2,
            //                                             0.4,
            //                                             0.9,
            //                                             1.0,
            //                                           ],
            //                                         ),
            //                                       ),
            //                                     ),
            //                                     Expanded(
            //                                       child: Column(
            //                                         children: [
            //                                           // Divider with gradient effect
            //                                           Container(
            //                                             height: 2,
            //                                             width: double.infinity,
            //                                             decoration: BoxDecoration(
            //                                               gradient:
            //                                                   LinearGradient(
            //                                                     begin: Alignment
            //                                                         .centerLeft,
            //                                                     end: Alignment
            //                                                         .centerRight,
            //                                                     colors: [
            //                                                       Colors.white10,
            //                                                       Colors.white30,
            //                                                       Colors.white60,
            //                                                       Colors.white60,
            //                                                       Colors.white30,
            //                                                       Colors.white10,
            //                                                     ],
            //                                                     stops: [
            //                                                       0.0,
            //                                                       0.1,
            //                                                       0.2,
            //                                                       0.4,
            //                                                       0.9,
            //                                                       1.0,
            //                                                     ],
            //                                                   ),
            //                                             ),
            //                                           ),
            //                                           Expanded(
            //                                             child: GlassContainer(
            //                                               border: Border.all(
            //                                                 color: Colors
            //                                                     .transparent,
            //                                                 width: 0,
            //                                               ),
            //                                               boxShadow: [
            //                                                 BoxShadow(
            //                                                   blurRadius: 10,
            //                                                   spreadRadius: 3,
            //                                                   color:
            //                                                       Colors.white10,
            //                                                 ),
            //                                               ],

            //                                               borderRadius:
            //                                                   BorderRadius.only(
            //                                                     topLeft:
            //                                                         Radius.circular(
            //                                                           8.0,
            //                                                         ),
            //                                                   ),
            //                                               padding:
            //                                                   EdgeInsets.only(
            //                                                     left: 8,
            //                                                     right: 8,
            //                                                     top: 8,
            //                                                     bottom: 4,
            //                                                   ),
            //                                               child: LayoutBuilder(
            //                                                 builder: (context, constraints) {
            //                                                   if (constraints
            //                                                           .maxHeight <
            //                                                       100) {
            //                                                     return Row(
            //                                                       mainAxisAlignment:
            //                                                           MainAxisAlignment
            //                                                               .start,
            //                                                       children: [
            //                                                         Flexible(
            //                                                           child: WaveformVisualizer(
            //                                                             waveformData:
            //                                                                 waveformData!,
            //                                                             activeColor:
            //                                                                 Colors
            //                                                                     .white,
            //                                                             inactiveColor:
            //                                                                 Colors
            //                                                                     .white30,
            //                                                             player:
            //                                                                 player,
            //                                                           ),
            //                                                         ),
            //                                                         Flexible(
            //                                                           child: AudioPlayerWidget(
            //                                                             player:
            //                                                                 player,
            //                                                           ),
            //                                                         ),
            //                                                       ],
            //                                                     );
            //                                                   }
            //                                                   return Column(
            //                                                     children: [
            //                                                       Expanded(
            //                                                         child: WaveformVisualizer(
            //                                                           waveformData:
            //                                                               waveformData!,
            //                                                           activeColor:
            //                                                               Colors
            //                                                                   .white,
            //                                                           inactiveColor:
            //                                                               Colors
            //                                                                   .white30,
            //                                                           player:
            //                                                               player,
            //                                                         ),
            //                                                       ),
            //                                                       AudioPlayerWidget(
            //                                                         player:
            //                                                             player,
            //                                                       ),
            //                                                     ],
            //                                                   );
            //                                                 },
            //                                               ),
            //                                             ),
            //                                           ),
            //                                         ],
            //                                       ),
            //                                     ),
            //                                   ],
            //                                 ),
            //                               ),
            //                             );
            //                           },
            //                         ),
            //                       ),
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           ),
            //         ],
            //       ),
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
