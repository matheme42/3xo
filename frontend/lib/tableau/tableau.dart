// class abstraite qui permet de définir toutes les méthodes et propriétés
// communes à tous les tableaux
import 'package:flutter/material.dart';
import 'package:frontend/context/context.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

mixin Tableau
    on State<StatefulWidget>, TickerProviderStateMixin<StatefulWidget> {
  late AppContext _appContext;

  bool tableauInitialized = false;

  // Méthode pour initialiser le tableau
  // charge les données nécessaires et configure l'état initial du tableau
  // exemple: charger les données depuis une API, initialiser les variables d'état, etc.
  // charge les scenes 3D, sons, images, etc.
  // lancer ambiance sonore, musique, etc.
  Future<void> init();

  @mustCallSuper
  Future<void> onInitDone() async {
    // Méthode appelée après l'initialisation du tableau
    // exemple: lancer des animations, démarrer des timers, etc.

    if (mounted) {
      setState(() {
        tableauInitialized = true;
      });
    }
    _appContext.websocket.registerMessageHandler(
      className,
      onMessageFromServer,
    );
    _appContext.websocket.sendMessage(className, 'Entered tableau $className');
  }

  // Méthode pour gérer les messages reçus du serveur
  // must be implemented by the class that uses this mixin
  void onMessageFromServer(String message);

  // Méthode pour obtenir le nom de la classe du tableau (T0, T1, T2, etc.)
  // get runtimeType of the current class, and remove the "State" suffix to get the tableau name
  // and remove the "ableau" prefix to get the tableau name
  String get className {
    return runtimeType
        .toString()
        .replaceAll('State', '')
        .replaceAll('ableau', '');
  }

  @override
  void initState() {
    super.initState();
    _appContext = Provider.of<AppContext>(context, listen: false);
    init().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onInitDone();
      });
    });
  }

  @override
  void dispose() {
    _appContext.websocket.unregisterMessageHandler(
      className,
      onMessageFromServer,
    );
    super.dispose();
  }

  void sendMessageToServer(String message) {
    _appContext.websocket.sendMessage(className, message);
  }

  Future<RiveWidgetController?> getRiveControllerFromRiveName(
    String riveName,
  ) async {
    final riveFile = await File.asset(
      '/VIS/Rive/$riveName',
      riveFactory: Factory.rive,
    );
    if (riveFile == null) {
      print('Erreur: Impossible de charger le fichier Rive $riveName');
      return null;
    }
    return RiveWidgetController(riveFile);
  }

  AssetImage getImageFromAsset(String assetName) {
    return AssetImage('VIS/Images/$assetName');
  }

  /// *** Methodes disponibles dans tous les tableaux pour jouer des sons, musiques, ambiances, etc. *** ///
  ///
  ///
  ///

  void gotoTableau(String tableauName) {
    _appContext.setCurrentRoute(tableauName);
  }

  void playMusic(
    String name, {
    bool loop = true,
    bool fadeIn = true,
    bool restartIfAlreadyPlaying = false,
  }) {
    _appContext.musiquePlayer.play(
      vsync: this,
      url: "assets/Mus/$name",
      loop: loop,
      fadeIn: fadeIn,
      restartIfAlreadyPlaying: restartIfAlreadyPlaying,
    );
  }

  void playAmbiance(
    String name, {
    bool loop = true,
    bool fadeIn = true,
    bool restartIfAlreadyPlaying = false,
  }) {
    _appContext.ambiancePlayer.play(
      vsync: this,
      url: "assets/Amb/$name",
      loop: loop,
      fadeIn: fadeIn,
      restartIfAlreadyPlaying: restartIfAlreadyPlaying,
    );
  }

  void playSoundsDesign(
    String name, {
    bool loop = false,
    bool fadeIn = false,
    bool restartIfAlreadyPlaying = true,
  }) {
    _appContext.soundsDesignPlayer.play(
      vsync: this,
      url: "assets/SD/$name",
      loop: loop,
      fadeIn: fadeIn,
      restartIfAlreadyPlaying: restartIfAlreadyPlaying,
    );
  }
}
