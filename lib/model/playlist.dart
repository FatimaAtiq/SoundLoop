import 'package:cloud_firestore/cloud_firestore.dart';

class Playlist {
  final String id;
  final String name;
  final String creator;
  final String image;
  final String userId;
  final Timestamp? createdAt;

  Playlist({
    required this.id,
    required this.name,
    required this.creator,
    required this.image,
    required this.userId,
    this.createdAt,
  });

  factory Playlist.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Playlist(
      id: doc.id,
      name: data['name'] ?? 'Untitled Playlist',
      creator: data['creator'] ?? 'Unknown',
      image: data['image'] ?? 'assets/images/default_cover.png',
      userId: data['userId'] ?? '',
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'creator': creator,
      'image': image,
      'userId': userId,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
