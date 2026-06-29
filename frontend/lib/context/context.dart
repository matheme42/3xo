import 'dart:async';

import 'package:flutter/foundation.dart' hide Factory;
import 'package:frontend/api/player.dart';
import 'package:frontend/api/websocket.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class AppContext extends ChangeNotifier {
  late WebsocketService websocket;
  late AudioPlayerService player;
  late AudioPlayerService bruitagePlayer;

  // rive file for the apple animation
  late File appleRiveFile;
  RiveWidgetController? appleRiveController;
  ViewModelInstance? appleRiveViewModel;

  Future<void> init() async {
    player = AudioPlayerService();
    bruitagePlayer = AudioPlayerService();
    websocket = WebsocketService();

    appleRiveFile = (await File.asset(
      'assets/apple.riv',
      riveFactory: Factory.rive,
    ))!;

    appleRiveController = RiveWidgetController(appleRiveFile);
    // appleRiveViewModel = appleRiveController?.dataBind(DataBind.auto());

    // En production, utilisez 'wss://' si vous êtes en HTTPS
    await websocket.connect();
    websocket.sendMessage('Hello Server!');
  }
}
