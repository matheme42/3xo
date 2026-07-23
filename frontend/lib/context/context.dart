import 'dart:async';

import 'package:flutter/foundation.dart' hide Factory;
import 'package:frontend/api/player.dart';
import 'package:frontend/api/websocket.dart';
import 'package:flutter/material.dart';

class AppContext extends ChangeNotifier {
  // Services that create a link between the app and the backend,
  // allowing to send and receive messages
  late WebsocketService websocket;

  // Services that allow to play audio files, either music,
  // ambiance or sound design
  late AudioPlayerService musiquePlayer;
  late AudioPlayerService ambiancePlayer;
  late AudioPlayerService soundsDesignPlayer;

  // current route of the app, used to navigate between different tableaux
  String currentRoute = 'T2';

  void setCurrentRoute(String route) {
    currentRoute = route;
    notifyListeners();
  }

  // initialize objects and connect to the backend
  Future<void> init() async {
    musiquePlayer = AudioPlayerService();
    ambiancePlayer = AudioPlayerService();
    soundsDesignPlayer = AudioPlayerService();
    websocket = WebsocketService();

    await websocket.connect();
  }
}
