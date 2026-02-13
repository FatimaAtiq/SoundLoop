import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/song.dart';

class SongApi {
  static Future<List<Song>> fetchSongsByArtist(String artistName) async {
    final url = Uri.parse(
      "https://itunes.apple.com/search?term=${Uri.encodeComponent(artistName)}&entity=song&limit=20",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['results'] == null) return [];

      return (data['results'] as List)
          .map((json) => Song.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to fetch songs for $artistName');
    }
  }
}
