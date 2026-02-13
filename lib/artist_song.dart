import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/MusicPlayerPage.dart';
import './model/song.dart';
import './services/artist_api.dart';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

class ArtistDetailPage extends StatefulWidget {
  final String artistName;
  final String artistImage;

  const ArtistDetailPage({
    super.key,
    required this.artistName,
    required this.artistImage,
  });

  @override
  State<ArtistDetailPage> createState() => _ArtistDetailPageState();
}

class _ArtistDetailPageState extends State<ArtistDetailPage> {
  late bool isFavourite;
  bool isLoading = true;
  bool isCheckingFavorite = true;
  List<Song> songs = [];

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? currentPlayingUrl;

  double _clamp(double v, double min, double max) => v.clamp(min, max);

  @override
  void initState() {
    super.initState();
    isFavourite = false;
    _checkIfFavorite();
    fetchSongs();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _checkIfFavorite() async {
    setState(() => isCheckingFavorite = true);
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        isFavourite = false;
        isCheckingFavorite = false;
      });
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favoriteArtists')
          .where('name', isEqualTo: widget.artistName)
          .get();

      setState(() {
        isFavourite = snapshot.docs.isNotEmpty;
        isCheckingFavorite = false;
      });
    } catch (e) {
      debugPrint('Error checking favorite artist: $e');
      setState(() => isCheckingFavorite = false);
    }
  }

  Future<void> _toggleFavoriteArtist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to favorite artists')),
      );
      return;
    }

    try {
      final favoritesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favoriteArtists');

      if (isFavourite) {
        final snapshot = await favoritesRef
            .where('name', isEqualTo: widget.artistName)
            .get();

        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }

        setState(() => isFavourite = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed ${widget.artistName} from favorites'),
            backgroundColor: Colors.grey,
          ),
        );
      } else {
        await favoritesRef.add({
          'name': widget.artistName,
          'image': widget.artistImage,
          'addedAt': Timestamp.now(),
        });

        setState(() => isFavourite = true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${widget.artistName} to favorites'),
            backgroundColor: const Color(0xFFFFC93C),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error toggling favorite artist: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update favorites'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchSongs() async {
    setState(() => isLoading = true);
    try {
      final fetchedSongs = await SongApi.fetchSongsByArtist(widget.artistName);
      setState(() => songs = fetchedSongs);
    } catch (e) {
      print("Error fetching songs: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void playPreview(String url) async {
    if (currentPlayingUrl == url) {
      if (_audioPlayer.state == PlayerState.playing) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.resume();
      }
    } else {
      currentPlayingUrl = url;
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
    }
    setState(() {});
  }

  ImageProvider<Object> _getImageProvider(String image) {
    if (image.startsWith('data:image')) {
      final base64Str = image.split(',').last;
      final bytes = base64Decode(base64Str);
      return MemoryImage(bytes);
    } else if (image.startsWith('http')) {
      return NetworkImage(image);
    } else if (image.isNotEmpty) {
      return AssetImage(image);
    } else {
      return const AssetImage('assets/images/default_artist.png');
    }
  }

  void _showSongOptions(BuildContext context, Song song, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1D2333),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        song.coverUrl.isNotEmpty
                            ? song.coverUrl
                            : widget.artistImage,
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 50,
                          width: 50,
                          color: Colors.grey.shade800,
                          child: const Icon(Icons.music_note, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            song.artist,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 30, color: Colors.white12),
              _buildOption(Icons.favorite_border, 'Add to Favorites', () {
                Navigator.pop(context);
                _addSongToFavorites(song);
              }),
              _buildOption(Icons.playlist_add, 'Add to Playlist', () {
                Navigator.pop(context);
                _showAddToPlaylistDialog(song);
              }),
              _buildOption(Icons.open_in_full, 'Open in Player', () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MusicPlayerPage(
                      song: song,
                      playlist: songs,
                      currentIndex: index,
                    ),
                  ),
                );
              }),
              _buildOption(Icons.share, 'Share', () {
                Navigator.pop(context);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white.withOpacity(0.8)),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: onTap,
    );
  }

  Future<void> _addSongToFavorites(Song song) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add favorites')),
      );
      return;
    }

    try {
      final existing = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .where('title', isEqualTo: song.title)
          .where('artist', isEqualTo: song.artist)
          .get();

      if (existing.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Song already in favorites'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .add({
        'title': song.title,
        'artist': song.artist,
        'coverUrl': song.coverUrl,
        'previewUrl': song.previewUrl,
        'addedAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added "${song.title}" to favorites'),
          backgroundColor: const Color(0xFFFFC93C),
        ),
      );
    } catch (e) {
      debugPrint('Error adding to favorites: $e');
    }
  }

  Future<void> _showAddToPlaylistDialog(Song song) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add songs to playlists')),
      );
      return;
    }

    final playlistsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('playlists')
        .orderBy('createdAt', descending: true)
        .get();

    if (!mounted) return;

    if (playlistsSnapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No playlists found. Create one first!'),
          backgroundColor: Color(0xFFFFC93C),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1D2333),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add to Playlist',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 30, color: Colors.white12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: playlistsSnapshot.docs.length,
                  itemBuilder: (context, index) {
                    final playlist = playlistsSnapshot.docs[index];
                    final playlistName = playlist['name'] ?? 'Untitled';

                    return ListTile(
                      leading: const Icon(
                        Icons.playlist_play,
                        color: Color(0xFFFFC93C),
                      ),
                      title: Text(
                        playlistName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.add,
                        color: Color(0xFFFFC93C),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _addSongToPlaylist(user.uid, playlist.id, song);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addSongToPlaylist(
      String userId, String playlistId, Song song) async {
    try {
      final existing = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('playlists')
          .doc(playlistId)
          .collection('songs')
          .where('title', isEqualTo: song.title)
          .where('artist', isEqualTo: song.artist)
          .get();

      if (existing.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Song already in this playlist'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('playlists')
          .doc(playlistId)
          .collection('songs')
          .add({
        'title': song.title,
        'artist': song.artist,
        'coverUrl': song.coverUrl,
        'previewUrl': song.previewUrl,
        'addedAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added "${song.title}" to playlist'),
          backgroundColor: const Color(0xFFFFC93C),
        ),
      );
    } catch (e) {
      debugPrint('Error adding to playlist: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    double rw(double v) => _clamp(v * w / 430.0, v * 0.8, v * 1.3);
    double rh(double v) => _clamp(v * h / 932.0, v * 0.8, v * 1.3);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE84040),
              Color(0xFF1A0F20),
              Color(0xFF0D0D1C),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: rw(20), vertical: rh(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _iconButton(
                      icon: Icons.arrow_back_ios_new,
                      onTap: () => Navigator.pop(context),
                      size: rw(25),
                    ),
                    _iconButton(
                      icon: isCheckingFavorite
                          ? Icons.favorite_border
                          : (isFavourite ? Icons.favorite : Icons.favorite_border),
                      onTap: isCheckingFavorite ? () {} : _toggleFavoriteArtist,
                      size: rw(25),
                      backgroundColor: Colors.white.withOpacity(0.12),
                      iconColor: isFavourite ? Colors.red : Colors.white,
                    ),
                  ],
                ),

                SizedBox(height: rh(20)),

                Container(
                  width: double.infinity,
                  height: rh(220),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(rw(20)),
                    image: DecorationImage(
                      image: _getImageProvider(widget.artistImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                SizedBox(height: rh(20)),

                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: rw(40), vertical: rh(12)),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2F45),
                      borderRadius: BorderRadius.circular(rw(30)),
                    ),
                    child: Text(
                      widget.artistName,
                      style: TextStyle(
                        color: const Color(0xFFFFC93C),
                        fontSize: rw(24),
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            blurRadius: 8.0,
                            color: const Color(0xFFFFC93C).withOpacity(0.7),
                          ),
                          Shadow(
                            blurRadius: 16.0,
                            color: const Color(0xFFFFC93C).withOpacity(0.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: rh(20)),

                isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFFFFC93C)))
                    : songs.isEmpty
                        ? const Center(
                            child: Text("No songs found",
                                style: TextStyle(color: Colors.white)),
                          )
                        : ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: songs.length,
                            itemBuilder: (context, index) {
                              final song = songs[index];
                              final isPlaying =
                                  currentPlayingUrl == song.previewUrl &&
                                      _audioPlayer.state == PlayerState.playing;

                              return GestureDetector(
                                onTap: () => playPreview(song.previewUrl),
                                child: Container(
                                  margin: EdgeInsets.only(bottom: rh(14)),
                                  padding: EdgeInsets.all(rw(12)),
                                  decoration: BoxDecoration(
                                    color: isPlaying
                                        ? Colors.yellow.withOpacity(0.1)
                                        : const Color(0xFF1D2333),
                                    borderRadius: BorderRadius.circular(rw(16)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: rw(50),
                                        height: rw(50),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(rw(12)),
                                          image: DecorationImage(
                                            image: _getImageProvider(
                                                song.coverUrl.isNotEmpty
                                                    ? song.coverUrl
                                                    : widget.artistImage),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: rw(14)),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              song.title,
                                              style: TextStyle(
                                                color: isPlaying
                                                    ? Colors.yellow
                                                    : Colors.white,
                                                fontSize: rw(16),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(height: rh(4)),
                                            Text(
                                              song.artist,
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.6),
                                                fontSize: rw(12),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      IconButton(
                                        icon: Icon(
                                          isPlaying
                                              ? Icons.pause_circle
                                              : Icons.play_circle,
                                          color: Colors.white,
                                        ),
                                        iconSize: 28,
                                        onPressed: () =>
                                            playPreview(song.previewUrl),
                                      ),

                                      IconButton(
                                        icon: Icon(
                                          Icons.more_vert,
                                          color: Colors.white.withOpacity(0.6),
                                        ),
                                        iconSize: 24,
                                        onPressed: () =>
                                            _showSongOptions(context, song, index),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                SizedBox(height: rh(20)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required VoidCallback onTap,
    double size = 28,
    Color backgroundColor = const Color(0x1FFFFFFF),
    Color iconColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(size * 0.25),
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(size),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: size,
        ),
      ),
    );
  }
}