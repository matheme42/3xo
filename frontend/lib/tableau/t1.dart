import 'package:flutter/material.dart';
import 'package:frontend/context/constant.dart';
import 'package:frontend/tableau/tableau.dart';
import 'package:rive/rive.dart';

mixin T1 on State<StatefulWidget>, Tableau {
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

    playAmbiance(
      Constants.ambianceAudioAssetPath,
      loop: true,
      fadeIn: true,
      restartIfAlreadyPlaying: false,
    );
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
    Future.delayed(const Duration(milliseconds: 3000), () {
      gotoTableau('T0'); // Navigate to Tableau 2 after 500 milliseconds
    });
  }
}
