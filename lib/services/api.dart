import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/song.dart';

class ItunesApiService {
  static Future<List<Song>> fetchSongs(String query) async {
    final url = Uri.parse(
        'https://itunes.apple.com/search?term=$query&entity=song&limit=20');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['results'];
      return data.map((json) => Song.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch songs');
    }
  }
}
