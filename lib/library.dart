import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'profile.dart';
import 'Search.dart';
import 'createplaylist.dart';
import 'playlistsong.dart';

class LibraryPage extends StatefulWidget {
  final void Function(BuildContext context)? onSearchTap;
  final void Function(BuildContext context)? onAccountTap;

  const LibraryPage({super.key, this.onSearchTap, this.onAccountTap});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final PlaylistService _playlistService = PlaylistService();
  bool isLoading = true;
  List<Playlist> playlists = [];

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    setState(() => isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => isLoading = false);
        return;
      }

      final data = await _playlistService.fetchPlaylists(user.uid);
      setState(() {
        playlists = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Failed to load playlists: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _addNewPlaylist(Map<String, String> data) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to create playlists')),
        );
        return;
      }

      final newPlaylist = await _playlistService.addPlaylist(user.uid, data);

      setState(() {
        playlists.insert(0, newPlaylist);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Playlist created successfully'),
          backgroundColor: Color(0xFFFFC93C),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add playlist')),
      );
    }
  }

  Future<void> _deletePlaylist(String playlistId, int index) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await _playlistService.deletePlaylist(user.uid, playlistId);

      setState(() {
        playlists.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Playlist deleted successfully'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete playlist')),
      );
    }
  }

  double _clamp(double v, double min, double max) => v.clamp(min, max);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    final scaleW = w / 430.0;
    final scaleH = h / 932.0;

    double rw(double v) => _clamp(v * scaleW, v * 0.80, v * 1.30);
    double rh(double v) => _clamp(v * scaleH, v * 0.80, v * 1.30);

    final topSafe = MediaQuery.of(context).padding.top;
    final labelFont = _clamp(17 * scaleW, 13, 18);
    final createFont = _clamp(20 * scaleW, 15, 22);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1C),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1.5, -1.5),
                  end: Alignment(0.5, 0.8),
                  colors: [
                    Color(0xE6E84040),
                    Color(0xFF1A0F20),
                    Color(0xFF0D0D1C),
                  ],
                  stops: [0.0, 0.35, 1.0],
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: rw(15), vertical: rh(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: rw(100),
                        height: rh(70),
                      ),
                      Transform.translate(
                        offset: Offset(-rw(30), 0),
                        child: Image.asset(
                          'assets/images/soundloop_text.png',
                          width: rw(150),
                          height: rh(70),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(rw(20)),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => SearchPage()),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(rw(8)),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(rw(20)),
                            ),
                            child: Icon(
                              Icons.search,
                              color: Colors.white,
                              size: _clamp(30 * scaleW, 22, 32),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: rw(12)),

                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(rw(20)),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => AccountPage()),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(rw(8)),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(rw(20)),
                            ),
                            child: Icon(
                              Icons.account_circle_outlined,
                              color: Colors.white.withOpacity(0.5),
                              size: _clamp(30 * scaleW, 22, 32),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: rh(10)),
            Center(
              child: Container(
                width: rw(220),
                height: _clamp(50 * scaleH, 44, 55),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(rw(30)),
                ),
                child: Center(
                  child: Text(
                    "Your Playlists",
                    style: TextStyle(
                      fontSize: labelFont,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFC93C),
                      shadows: [
                        Shadow(
                          blurRadius: rw(25),
                          color: const Color(0xFFFFC93C).withOpacity(0.9),
                        ),
                        Shadow(
                          blurRadius: rw(45),
                          color: const Color(0xFFFFC93C).withOpacity(0.6),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: rh(8)),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: rw(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CreatePlaylistPage(onSubmit: _addNewPlaylist),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: _clamp(60 * scaleH, 52, 66),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(rw(30)),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: _clamp(40 * scaleW, 32, 46),
                                    height: _clamp(40 * scaleW, 32, 46),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          const Color(0xFFFFC93C).withOpacity(0.3),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFFC93C)
                                              .withOpacity(0.7),
                                          blurRadius: rw(30),
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.add,
                                    color: const Color(0xFFFFC93C),
                                    size: _clamp(30 * scaleW, 22, 32),
                                  ),
                                ],
                              ),
                              SizedBox(width: rw(8)),
                              Text(
                                "Create Playlist",
                                style: TextStyle(
                                  color: const Color(0xFFFFC93C),
                                  fontSize: createFont,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: const Color(0xFFFFC93C)
                                          .withOpacity(0.8),
                                      blurRadius: rw(18),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: rh(20)),

                    if (isLoading)
                      Center(
                        child: CircularProgressIndicator(color: Color(0xFFFFC93C)),
                      )
                    else if (playlists.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: rh(50)),
                          child: Column(
                            children: [
                              Icon(
                                Icons.library_music_outlined,
                                size: _clamp(80 * scaleW, 60, 90),
                                color: Colors.white.withOpacity(0.3),
                              ),
                              SizedBox(height: rh(20)),
                              Text(
                                "No Playlists Yet",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: _clamp(18 * scaleW, 14, 20),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: rh(10)),
                              Text(
                                "Create your first playlist above",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: _clamp(14 * scaleW, 12, 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: playlists.length,
                        itemBuilder: (context, index) {
                          final p = playlists[index];
                          return PlaylistCard(
                            playlistId: p.id,
                            image: p.image,
                            title: p.name,
                            creator: p.creator,
                            onDelete: () => _showDeleteConfirmation(p.id, index),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PlaylistPage(
                                    playlistName: p.name,
                                    playlistImage: p.image,
                                    playlistId: p.id,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(String playlistId, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D2333),
        title: const Text(
          'Delete Playlist',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this playlist?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePlaylist(playlistId, index);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class PlaylistCard extends StatelessWidget {
  final String playlistId;
  final String image;
  final String title;
  final String creator;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const PlaylistCard({
    super.key,
    required this.playlistId,
    required this.image,
    required this.title,
    required this.creator,
    this.onDelete,
    this.onTap,
  });

  double _clamp(double v, double min, double max) => v.clamp(min, max);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final scaleW = w / 430.0;
    final scaleH = h / 932.0;
    double rw(double v) => _clamp(v * scaleW, v * 0.8, v * 1.3);
    double rh(double v) => _clamp(v * scaleH, v * 0.8, v * 1.3);

    final cardH = _clamp(110 * scaleH, 90, 125);
    final imgW = _clamp(100 * scaleW, 80, 120);
    final titleFont = _clamp(18 * scaleW, 14, 20);
    final creatorFont = _clamp(14 * scaleW, 12, 16);

    ImageProvider<Object> displayImage;

    if (image.startsWith('data:image')) {
      final base64Str = image.split(',').last;
      final bytes = base64Decode(base64Str);
      displayImage = MemoryImage(bytes);
    } else if (image.startsWith('http')) {
      displayImage = NetworkImage(image);
    } else if (image.isNotEmpty) {
      displayImage = AssetImage(image);
    } else {
      displayImage = const AssetImage('assets/images/default_playlist.png');
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: cardH,
        margin: EdgeInsets.only(bottom: rh(20)),
        decoration: BoxDecoration(
          color: const Color(0xFF1D2333),
          borderRadius: BorderRadius.circular(rw(18)),
        ),
        child: Row(
          children: [
            Container(
              width: imgW,
              height: cardH,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(rw(12)),
                image: DecorationImage(
                  image: displayImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: rw(12)),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleFont,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: rh(5)),
                  Text(
                    "By $creator",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: creatorFont,
                    ),
                  ),
                ],
              ),
            ),
            if (onDelete != null)
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.red.withOpacity(0.8),
                  size: _clamp(24 * scaleW, 20, 28),
                ),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}

class Playlist {
  final String id;
  final String name;
  final String image;
  final String creator;
  final DateTime createdAt;

  Playlist({
    required this.id,
    required this.name,
    required this.image,
    required this.creator,
    required this.createdAt,
  });

  factory Playlist.fromMap(Map<String, dynamic> map, String docId) {
    return Playlist(
      id: docId,
      name: map['name'] ?? 'Untitled Playlist',
      image: map['image'] ?? '',
      creator: map['creator'] ?? 'Unknown',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'creator': creator,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class PlaylistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Playlist>> fetchPlaylists(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('playlists')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Playlist.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching playlists: $e');
      throw Exception('Failed to fetch playlists');
    }
  }

  Future<Playlist> addPlaylist(String userId, Map<String, String> data) async {
    try {
      final nameInput = data['title']?.trim();
      final creatorInput = data['creator']?.trim();

      final newPlaylist = Playlist(
        id: '',
        name: nameInput != null && nameInput.isNotEmpty
            ? nameInput
            : 'Untitled Playlist',
        image: data['image'] ?? '',
        creator:
            creatorInput != null && creatorInput.isNotEmpty ? creatorInput : 'Anonymous',
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('playlists')
          .add(newPlaylist.toMap());

      return Playlist(
        id: docRef.id,
        name: newPlaylist.name,
        image: newPlaylist.image,
        creator: newPlaylist.creator,
        createdAt: newPlaylist.createdAt,
      );
    } catch (e) {
      debugPrint('Error adding playlist: $e');
      throw Exception('Failed to add playlist');
    }
  }

  Future<void> deletePlaylist(String userId, String playlistId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('playlists')
          .doc(playlistId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting playlist: $e');
      throw Exception('Failed to delete playlist');
    }
  }

  Future<void> updatePlaylist(
      String userId, String playlistId, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('playlists')
          .doc(playlistId)
          .update(updates);
    } catch (e) {
      debugPrint('Error updating playlist: $e');
      throw Exception('Failed to update playlist');
    }
  }
}
