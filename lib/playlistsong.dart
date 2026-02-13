import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';

class PlaylistPage extends StatefulWidget {
  final String playlistName;
  final String playlistImage;
  final String playlistId;

   PlaylistPage({
    super.key,
    required this.playlistName,
    required this.playlistImage,
    required this.playlistId,
  });

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  final AudioPlayer _player = AudioPlayer();
  String currentPlaying = '';
  List<PlaylistSong> songs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    setState(() => isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('playlists')
          .doc(widget.playlistId)
          .collection('songs')
          .orderBy('addedAt', descending: false)
          .get();

      setState(() {
        songs = snapshot.docs
            .map((doc) => PlaylistSong.fromMap(doc.data(), doc.id))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading songs: $e');
      setState(() => isLoading = false);
    }
  }

  void playPreview(String url) async {
    if (currentPlaying == url) {
      await _player.stop();
      setState(() => currentPlaying = '');
      return;
    }
    await _player.play(UrlSource(url));
    setState(() => currentPlaying = url);
  }

  void shufflePlaylist() {
    setState(() {
      songs.shuffle();
    });
  }

  Future<void> _removeSong(String songId, int index) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('playlists')
          .doc(widget.playlistId)
          .collection('songs')
          .doc(songId)
          .delete();

      setState(() {
        songs.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Song removed from playlist'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      debugPrint('Error removing song: $e');
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2a1a3a),
              Color(0xFF1a1a2e),
              Color(0xFF0a0a14),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFFC93C),
                        ),
                      )
                    : _buildSongsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    ImageProvider<Object> displayImage;

    if (widget.playlistImage.startsWith('data:image')) {
      final base64Str = widget.playlistImage.split(',').last;
      final bytes = base64Decode(base64Str);
      displayImage = MemoryImage(bytes);
    } else if (widget.playlistImage.startsWith('http')) {
      displayImage = NetworkImage(widget.playlistImage);
    } else if (widget.playlistImage.isNotEmpty) {
      displayImage = AssetImage(widget.playlistImage);
    } else {
      displayImage = const AssetImage('assets/images/default_playlist.png');
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
        
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                color: Colors.white,
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.shuffle),
                color: const Color(0xFFFFC93C),
                onPressed: shufflePlaylist,
              ),
            ],
          ),
          const SizedBox(height: 20),

        
          Container(
            height: 180,
            width: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFC93C).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image(
                image: displayImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFFFC93C).withOpacity(0.3),
                    child: const Icon(
                      Icons.playlist_play,
                      size: 60,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            widget.playlistName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

 
          Text(
            '${songs.length} songs',
            style: const TextStyle(
              color: Color(0xFFFFC93C),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),

    
          ElevatedButton.icon(
            onPressed: () {
              if (songs.isNotEmpty) {
                playPreview(songs[0].previewUrl);
              }
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Play All'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC93C),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongsList() {
    if (songs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_off,
              size: 60,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No songs in this playlist',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add songs from the search page',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        final isPlaying = currentPlaying == song.previewUrl;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isPlaying
                ? const Color(0xFFFFC93C).withOpacity(0.15)
                : Colors.white.withOpacity(0.05),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 25,
                  child: Center(
                    child: isPlaying
                        ? const Icon(
                            Icons.equalizer,
                            color: Color(0xFFFFC93C),
                            size: 20,
                          )
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    song.coverUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey.shade800,
                        child: const Icon(
                          Icons.music_note,
                          color: Colors.white,
                          size: 20,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            title: Text(
              song.title,
              style: TextStyle(
                color: isPlaying ? const Color(0xFFFFC93C) : Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              song.artist,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause_circle : Icons.play_circle,
                    color: isPlaying ? const Color(0xFFFFC93C) : Colors.white,
                    size: 32,
                  ),
                  onPressed: () => playPreview(song.previewUrl),
                ),
                IconButton(
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: Colors.red.withOpacity(0.8),
                    size: 24,
                  ),
                  onPressed: () => _showRemoveConfirmation(song.id, index),
                ),
              ],
            ),
            onTap: () => playPreview(song.previewUrl),
          ),
        );
      },
    );
  }

  void _showRemoveConfirmation(String songId, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D2333),
        title: const Text(
          'Remove Song',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Remove this song from the playlist?',
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
              _removeSong(songId, index);
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class PlaylistSong {
  final String id;
  final String title;
  final String artist;
  final String coverUrl;
  final String previewUrl;
  final DateTime addedAt;

  PlaylistSong({
    required this.id,
    required this.title,
    required this.artist,
    required this.coverUrl,
    required this.previewUrl,
    required this.addedAt,
  });

  factory PlaylistSong.fromMap(Map<String, dynamic> map, String docId) {
    return PlaylistSong(
      id: docId,
      title: map['title'] ?? 'Unknown Title',
      artist: map['artist'] ?? 'Unknown Artist',
      coverUrl: map['coverUrl'] ?? '',
      previewUrl: map['previewUrl'] ?? '',
      addedAt: (map['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'coverUrl': coverUrl,
      'previewUrl': previewUrl,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }
}