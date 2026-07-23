import 'package:flutter/material.dart';
import 'package:frontend/context/constant.dart';
import 'package:frontend/tableau/tableau.dart';
import 'package:rive/rive.dart';

mixin T2 on State<StatefulWidget>, Tableau {
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

  @override
  Future<void> onInitDone() async {
    super.onInitDone();
    playAmbiance(
      Constants.ambianceAudioAssetPath,
      loop: true,
      fadeIn: true,
      restartIfAlreadyPlaying: false,
    );
  }

  //////////////////////////////////////////////////////////////////////////////
  ///                               Action handlers                          ///
  //////////////////////////////////////////////////////////////////////////////

  void handleTap() {
    // Exemple d'action lors du tap : envoyer un message via WebSocket
    sendMessageToServer('User tapped on the screen!');
  }

  void handleTapApple() {
    // Exemple d'action lors du tap sur la pomme : envoyer un message via WebSocket
    sendMessageToServer('User tapped on the apple!');
    playSoundsDesign(
      Constants.bruitage1AudioAssetPath,
      loop: false,
      fadeIn: false,
      restartIfAlreadyPlaying: true,
    );
  }

  @override
  void onMessageFromServer(String message) {
    print('Message reçu dans Tableau1: $message');
  }
}
