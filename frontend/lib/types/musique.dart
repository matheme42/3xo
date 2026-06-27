class Musique {
  String title;
  String artist;
  String album;
  String coverUrl;
  String audioUrl;
  String? lyricsOrDescription;

  Musique({
    required this.title,
    required this.artist,
    required this.album,
    required this.coverUrl,
    required this.audioUrl,
    this.lyricsOrDescription,
  });
}
