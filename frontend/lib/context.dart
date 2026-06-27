import 'dart:async';

import 'package:frontend/types/musique.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class AppContext extends ChangeNotifier {
  List<Musique> music = [];

  void getAvailableMusic() {
    String audioUrl = "https://fr.getsamplefiles.com/download/mp3/sample-3.mp3";
    String audioUrl2 =
        "https://fr.getsamplefiles.com/download/mp3/sample-1.mp3";

    String artist = "SadIks";
    String album = "Xo";

    List<String> coverUrls = [
      "https://i.ytimg.com/vi/7jzVvnF7x5o/hqdefault.jpg?sqp=-oaymwFBCPYBEIoBSFryq4qpAzMIARUAAIhCGAHYAQHiAQoIGBACGAY4AUAB8AEB-AH-CYAC0AWKAgwIABABGEcgWyhlMA8=&rs=AOn4CLB8OClCu_-Xf0_FgfaZqZV6T1vEUQ",
      "https://i.ytimg.com/vi/MC6cK-VexQw/hqdefault.jpg?sqp=-oaymwFBCPYBEIoBSFryq4qpAzMIARUAAIhCGAHYAQHiAQoIGBACGAY4AUAB8AEB-AH-CYAC0AWKAgwIABABGGUgTShIMA8=&rs=AOn4CLDM6PyvKg7Y_lqx6biUJ3RyqA6QsQ",
      "https://i.ytimg.com/vi/1naMfd8ERKI/hqdefault.jpg?sqp=-oaymwFBCPYBEIoBSFryq4qpAzMIARUAAIhCGAHYAQHiAQoIGBACGAY4AUAB8AEB-AHkBoAC0AWKAgwIABABGEkgVChlMA8=&rs=AOn4CLCA-gJBu33HSiE58XRYAw7-HxunRA",
      "https://i.ytimg.com/vi/vGD1uYU2bsc/hqdefault.jpg?sqp=-oaymwFBCNACELwBSFryq4qpAzMIARUAAIhCGAHYAQHiAQoIGBACGAY4AUAB8AEB-AH-CYAC0AWKAgwIABABGH8gKig_MA8=&rs=AOn4CLAtdg4xRv9RcV2xwYmrKYlqEboTiQ",
      "https://i.ytimg.com/vi/2NMbTrxIK_Q/hqdefault.jpg?sqp=-oaymwFBCPYBEIoBSFryq4qpAzMIARUAAIhCGAHYAQHiAQoIGBACGAY4AUAB8AEB-AH-CYAC0AWKAgwIABABGEIgVihlMA8=&rs=AOn4CLBvRwTAWqwM7fonqQrNZkWOdeaC4g",
    ];
    List<String> titles = [
      "1. F1lante",
      "2. Oei2",
      "3. Br3loque",
      "4. snolw4ys",
      "5. Boi5",
    ];
    // Exemple de description ou paroles
    String description =
        "3ox est le premier album de SadIks, sorti en 2024. Il mélange des influences de hip-hop, de trap et de musique électronique pour créer une atmosphère sombre et introspective. Les paroles abordent des thèmes tels que la solitude, la dépression et les relations toxiques.";
    String description2 =
        "3ox is the first album by SadIks, released in 2024. It blends influences from hip-hop, trap, and electronic music to create a dark and introspective atmosphere. The lyrics address themes such as loneliness, depression, and toxic relationships.";

    for (var i = 0; i < titles.length; i++) {
      String title = "$album - ${titles[i]}";
      music.add(
        Musique(
          title: title,
          artist: artist,
          album: album,
          coverUrl: coverUrls[i],
          audioUrl: i % 2 == 0 ? audioUrl : audioUrl2,
          lyricsOrDescription: i % 2 == 0 ? description : description2,
        ),
      );
    }
    notifyListeners();
  }

  Future<void> init() async {
    // En production, utilisez 'wss://' si vous êtes en HTTPS
    final channel = WebSocketChannel.connect(Uri.parse('ws://localhost/ws'));

    // Pour écouter les messages
    channel.stream.listen((message) {
      print('Message reçu: $message');
    });

    // Pour envoyer un message
    channel.sink.add('Hello Server!');
    getAvailableMusic();
  }
}
