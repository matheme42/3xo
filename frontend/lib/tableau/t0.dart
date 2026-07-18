import 'package:flutter/material.dart';
import 'package:frontend/tableau/tableau.dart';
import 'package:rive/rive.dart';

mixin T0 on State<StatefulWidget>, Tableau {
  // allow an automatic match between the tableau and the class name,
  // and the associated assets, for example: T1 -> assets/apple.riv, assets/filante_ambiance.mp3, etc.
  @override
  String className() {
    return 'T0';
  }

  //////////////////////////////////////////////////////////////////////////////
  ///                                Constantes                              ///
  //////////////////////////////////////////////////////////////////////////////

  static const String appleRiveAssetPath = 'door_open.riv';
  static const String soundDesignDoor = 'filante_ambiance.mp3';
  static const String soundDesignGlitch = 'SD_Pomme.wav';

  //////////////////////////////////////////////////////////////////////////////
  ///                              Local variables                           ///
  //////////////////////////////////////////////////////////////////////////////

  // rive file for the apple animation
  RiveWidgetController? appleRiveController;

  //////////////////////////////////////////////////////////////////////////////
  /// Tableau initialization methods, called once when the tableau is mounted///
  //////////////////////////////////////////////////////////////////////////////
  @override
  Future<void> init() async {
    appleRiveController = await getRiveControllerFromRiveName(
      appleRiveAssetPath,
    );
  }

  //////////////////////////////////////////////////////////////////////////////
  ///                               Action handlers                          ///
  //////////////////////////////////////////////////////////////////////////////

  void handleTap() {
    // Exemple d'action lors du tap : envoyer un message via WebSocket
    sendMessageToServer('User tapped on the screen!');
    playSoundsDesign(
      soundDesignDoor,
      loop: false,
      fadeIn: false,
      restartIfAlreadyPlaying: true,
    );
    playSoundsDesign(
      soundDesignGlitch,
      loop: false,
      fadeIn: false,
      restartIfAlreadyPlaying: true,
    );
  }
}
