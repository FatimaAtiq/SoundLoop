class Song {
  final String title;
  final String artist;
  final String coverUrl;
  final String previewUrl;

  Song({
    required this.title,
    required this.artist,
    required this.coverUrl,
    required this.previewUrl,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      title: json['trackName'] ?? 'Unknown',
      artist: json['artistName'] ?? 'Unknown',
      coverUrl: json['artworkUrl100'] ?? '',
      previewUrl: json['previewUrl'] ?? '',
    );
  }
}
