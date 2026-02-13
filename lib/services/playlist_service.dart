import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/playlist.dart';

class PlaylistService {
  final CollectionReference playlistsCollection =
      FirebaseFirestore.instance.collection('playlists');

  Future<List<Playlist>> fetchPlaylists(String userId) async {
    final snapshot = await playlistsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => Playlist.fromDocument(doc)).toList();
  }

  Future<Playlist> addPlaylist(String userId, Map<String, String> data) async {
    final docRef = await playlistsCollection.add({
      'userId': userId,
      'name': data['title'] ?? 'Untitled Playlist',
      'creator': data['creator'] ?? 'Unknown',
      'image': data['image'] ?? 'assets/images/default_cover.png',
      'createdAt': FieldValue.serverTimestamp(),
    });

    final doc = await docRef.get();
    return Playlist.fromDocument(doc);
  }
}
