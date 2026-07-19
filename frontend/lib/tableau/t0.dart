import 'package:flutter/material.dart';
import 'package:frontend/context/constant.dart';
import 'package:frontend/tableau/tableau.dart';
import 'package:rive/rive.dart';

mixin T0 on State<StatefulWidget>, Tableau {
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
      Constants.appleRiveAssetPath,
    );
  }

  //////////////////////////////////////////////////////////////////////////////
  ///                               Action handlers                          ///
  //////////////////////////////////////////////////////////////////////////////

  void handleTap() {
    // Exemple d'action lors du tap : envoyer un message via WebSocket
    sendMessageToServer('User tapped on the screen!');
    playSoundsDesign(
      Constants.soundDesignDoor,
      loop: false,
      fadeIn: false,
      restartIfAlreadyPlaying: true,
    );
    playSoundsDesign(
      Constants.ambianceAudioAssetPath,
      loop: false,
      fadeIn: false,
      restartIfAlreadyPlaying: true,
    );
  }
}
