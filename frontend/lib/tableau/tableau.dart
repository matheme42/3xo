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

  // Méthode pour obtenir le nom de la classe du tableau (T0, T1, T2, etc.)
  String className();

  @override
  void initState() {
    super.initState();
    _appContext = Provider.of<AppContext>(context, listen: false);
    init().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          tableauInitialized = true;
        });
      });
    });
  }

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    if (!tableauInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return const SizedBox.shrink(); // Placeholder, should be overridden by subclasses
  }

  @override
  void dispose() {
    super.dispose();
  }

  void sendMessageToServer(String message) {
    _appContext.websocket.sendMessage(message);
  }

  Future<RiveWidgetController?> getRiveControllerFromRiveName(
    String riveName,
  ) async {
    final riveFile = await File.asset(
      '${className()}/VIS/Rive/$riveName',
      riveFactory: Factory.rive,
    );
    if (riveFile == null) {
      print('Erreur: Impossible de charger le fichier Rive $riveName');
      return null;
    }
    return RiveWidgetController(riveFile);
  }

  AssetImage getImageFromAsset(String assetName) {
    return AssetImage('${className()}/VIS/Images/$assetName');
  }

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
      url: "assets/${className()}/Mus/$name",
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
      url: "assets/${className()}/Amb/$name",
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
      url: "assets/${className()}/SD/$name",
      loop: loop,
      fadeIn: fadeIn,
      restartIfAlreadyPlaying: restartIfAlreadyPlaying,
    );
  }
}
