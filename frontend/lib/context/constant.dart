class Constants {
  // system : même hôte/port que la page, via le proxy nginx (/ws)
  static String get websocketUrl {
    final base = Uri.base;
    return Uri(
      scheme: base.scheme == 'https' ? 'wss' : 'ws',
      host: base.host,
      port: base.hasPort ? base.port : null,
      path: '/ws',
    ).toString();
  }

  // tableaux

  // tableau T0
  static const String doorOpenRiveAssetPath = 'door.riv';
  static const String soundDesignDoor = 'filante_ambiance.mp3';
  static const String soundDesignGlitch = 'SD_Pomme.wav';

  // tableau T1
  static const String appleRiveAssetPath = 'apple.riv';
  static const String ambianceAudioAssetPath = 'filante_ambiance.mp3';
  static const String bruitage1AudioAssetPath = 'SD_Pomme.wav';
}
