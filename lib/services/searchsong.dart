import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/song.dart';

Future<List<Song>> fetchSongsBySearch(String query) async {
  if (query.isEmpty) return [];

  final url = Uri.parse(
      "https://itunes.apple.com/search?term=${Uri.encodeQueryComponent(query)}&entity=song&limit=25");
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    final List<dynamic> results = data['results'] ?? [];
    return results.map((json) => Song.fromJson(json)).toList();
  } else {
    throw Exception('Failed to fetch songs');
  }
}
