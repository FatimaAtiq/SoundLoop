import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:myapp/artist_song.dart';
import 'dart:convert';
import 'profile.dart';
import 'Search.dart';
import 'MusicPlayerPage.dart';
import './model/song.dart';
import 'playlistsong.dart';


class FavoritesPage extends StatefulWidget {
  final void Function(BuildContext context)? onSearchTap;
  final void Function(BuildContext context)? onAccountTap;

  const FavoritesPage({super.key, this.onSearchTap, this.onAccountTap});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  int selectedTab = 0;
  bool isLoading = true;

  List<FavoriteSong> favoriteSongs = [];
  List<UserPlaylist> userPlaylists = [];
  List<FavoriteArtist> favoriteArtists = [];

  final AudioPlayer _player = AudioPlayer();
  String currentPlaying = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final songsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .orderBy('addedAt', descending: true)
          .get();

      final playlistsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('playlists')
          .orderBy('createdAt', descending: true)
          .get();

      final artistsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favoriteArtists')
          .orderBy('addedAt', descending: true)
          .get();

      setState(() {
        favoriteSongs = songsSnapshot.docs
            .map((doc) => FavoriteSong.fromMap(doc.data(), doc.id))
            .toList();

        userPlaylists = playlistsSnapshot.docs
            .map((doc) => UserPlaylist.fromMap(doc.data(), doc.id))
            .toList();

        favoriteArtists = artistsSnapshot.docs
            .map((doc) => FavoriteArtist.fromMap(doc.data(), doc.id))
            .toList();

        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading favorites data: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _removeFavorite(String songId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(songId)
          .delete();

      setState(() {
        favoriteSongs.removeWhere((song) => song.id == songId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from favorites'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      debugPrint('Error removing favorite: $e');
    }
  }

  Future<void> _removeFavoriteArtist(String artistId, String artistName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favoriteArtists')
          .doc(artistId)
          .delete();

      setState(() {
        favoriteArtists.removeWhere((artist) => artist.id == artistId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed $artistName from favorites'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      debugPrint('Error removing favorite artist: $e');
    }
  }

  void _playPreview(String url) async {
    if (currentPlaying == url) {
      await _player.stop();
      setState(() => currentPlaying = '');
      return;
    }
    await _player.play(UrlSource(url));
    setState(() => currentPlaying = url);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
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

    Widget tabContent() {
      if (isLoading) {
        return Center(
          child: Padding(
            padding: EdgeInsets.only(top: rh(100)),
            child: const CircularProgressIndicator(
              color: Color(0xFFFFC93C),
            ),
          ),
        );
      }

      if (selectedTab == 0) {
        if (favoriteSongs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.favorite_border,
            message: 'No favorite songs yet',
            subtitle: 'Like songs to see them here',
            rh: rh,
            scaleW: scaleW,
          );
        }

        return Column(
          children: favoriteSongs.map((song) {
            final isPlaying = currentPlaying == song.previewUrl;
            return Padding(
              padding: EdgeInsets.only(bottom: rh(15)),
              child: FavouritesCard(
                songId: song.id,
                image: song.coverUrl,
                title: song.title,
                artist: song.artist,
                previewUrl: song.previewUrl,
                isPlaying: isPlaying,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MusicPlayerPage(
                        song: Song(
                          title: song.title,
                          artist: song.artist,
                          coverUrl: song.coverUrl,
                          previewUrl: song.previewUrl,
                        ),
                        playlist: favoriteSongs
                            .map((s) => Song(
                                  title: s.title,
                                  artist: s.artist,
                                  coverUrl: s.coverUrl,
                                  previewUrl: s.previewUrl,
                                ))
                            .toList(),
                        currentIndex: favoriteSongs.indexOf(song),
                      ),
                    ),
                  );
                },
                onPlay: () => _playPreview(song.previewUrl),
                onRemove: () => _showRemoveDialog(song.id, song.title),
              ),
            );
          }).toList(),
        );
      }

      if (selectedTab == 1) {
        if (userPlaylists.isEmpty) {
          return _buildEmptyState(
            icon: Icons.queue_music,
            message: 'No playlists yet',
            subtitle: 'Create playlists in Library',
            rh: rh,
            scaleW: scaleW,
          );
        }

        return Column(
          children: userPlaylists.map((playlist) {
            return Padding(
              padding: EdgeInsets.only(bottom: rh(15)),
              child: PlaylistCard(
                image: playlist.image,
                title: playlist.name,
                creator: playlist.creator,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlaylistPage(
                        playlistId: playlist.id,
                        playlistName: playlist.name,
                        playlistImage: playlist.image,
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      }

      if (selectedTab == 2) {
        if (favoriteArtists.isEmpty) {
          return _buildEmptyState(
            icon: Icons.person_outline,
            message: 'No favorite artists yet',
            subtitle: 'Like artists to see them here',
            rh: rh,
            scaleW: scaleW,
          );
        }

        return Column(
          children: favoriteArtists.map((artist) {
            return Padding(
              padding: EdgeInsets.only(bottom: rh(15)),
              child: ArtistFavCard(
                artistId: artist.id,
                image: artist.image,
                name: artist.name,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ArtistDetailPage(
                        artistName: artist.name,
                        artistImage: artist.image,
                      ),
                    ),
                  );
                },
                onRemove: () => _showRemoveArtistDialog(artist.id, artist.name),
              ),
            );
          }).toList(),
        );
      }

      return Container();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1C),
      body: Stack(
        children: [
          Positioned(
            top: topSafe + rh(10),
            left: rw(1),
            right: rw(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset('assets/images/logo.png',
                        width: rw(100), height: rh(70)),
                    Transform.translate(
                      offset: Offset(-rw(30), 0),
                      child: Image.asset('assets/images/soundloop_text.png',
                          width: rw(150), height: rh(70)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (widget.onSearchTap != null) {
                          widget.onSearchTap!(context);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SearchPage()),
                          );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(rw(8)),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(rw(20)),
                        ),
                        child: Icon(Icons.search,
                            color: Colors.white,
                            size: _clamp(30 * scaleW, 22, 32)),
                      ),
                    ),
                    SizedBox(width: rw(12)),
                    GestureDetector(
                      onTap: () {
                        if (widget.onAccountTap != null) {
                          widget.onAccountTap!(context);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AccountPage()),
                          );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(rw(8)),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(rw(20)),
                        ),
                        child: Icon(Icons.account_circle_outlined,
                            color: Colors.white.withOpacity(0.5),
                            size: _clamp(30 * scaleW, 22, 32)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Positioned(
            top: topSafe + rh(100),
            left: rw(3),
            right: rw(3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildTabButton("Songs", 0, rw, scaleW),
                SizedBox(width: rw(5)),
                buildTabButton("Playlists", 1, rw, scaleW),
                SizedBox(width: rw(5)),
                buildTabButton("Artists", 2, rw, scaleW),
              ],
            ),
          ),
          Positioned(
            top: topSafe + rh(210),
            left: rw(25),
            right: rw(25),
            bottom: rh(20),
            child: SingleChildScrollView(
              child: tabContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String subtitle,
    required double Function(double) rh,
    required double scaleW,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: rh(100)),
        child: Column(
          children: [
            Icon(
              icon,
              size: _clamp(80 * scaleW, 60, 90),
              color: Colors.white.withOpacity(0.3),
            ),
            SizedBox(height: rh(20)),
            Text(
              message,
              style: TextStyle(
                color: Colors.white70,
                fontSize: _clamp(18 * scaleW, 14, 20),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: rh(10)),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: _clamp(14 * scaleW, 12, 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTabButton(
    String text,
    int index,
    double Function(double) rw,
    double scaleW,
  ) {
    final isSelected = selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: _clamp(130 * scaleW, 105, 150),
        height: _clamp(38 * scaleW, 32, 44),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFC93C) : Colors.white10,
          borderRadius: BorderRadius.circular(rw(25)),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _showRemoveDialog(String songId, String songTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D2333),
        title: const Text(
          'Remove from Favorites',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Remove "$songTitle" from favorites?',
          style: const TextStyle(color: Colors.white70),
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
              _removeFavorite(songId);
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

  void _showRemoveArtistDialog(String artistId, String artistName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D2333),
        title: const Text(
          'Remove from Favorites',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Remove "$artistName" from favorite artists?',
          style: const TextStyle(color: Colors.white70),
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
              _removeFavoriteArtist(artistId, artistName);
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

class FavouritesCard extends StatelessWidget {
  final String songId;
  final String image;
  final String title;
  final String artist;
  final String previewUrl;
  final bool isPlaying;
  final VoidCallback? onTap;
  final VoidCallback? onPlay;
  final VoidCallback? onRemove;

  const FavouritesCard({
    super.key,
    required this.songId,
    required this.image,
    required this.title,
    required this.artist,
    required this.previewUrl,
    this.isPlaying = false,
    this.onTap,
    this.onPlay,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFF1D2333),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isPlaying
                ? const Color(0xFFFFC93C).withOpacity(0.5)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade800,
                    child: const Icon(
                      Icons.music_note,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
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
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isPlaying
                          ? const Color(0xFFFFC93C)
                          : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause_circle : Icons.play_circle,
                color: isPlaying ? const Color(0xFFFFC93C) : Colors.white,
                size: 36,
              ),
              onPressed: onPlay,
            ),
            IconButton(
              icon: Icon(
                Icons.favorite,
                color: Colors.red.withOpacity(0.8),
                size: 28,
              ),
              onPressed: onRemove,
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class PlaylistCard extends StatelessWidget {
  final String image;
  final String title;
  final String creator;
  final VoidCallback? onTap;

  const PlaylistCard({
    super.key,
    required this.image,
    required this.title,
    required this.creator,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
        height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFF1D2333),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: displayImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "By $creator",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArtistFavCard extends StatelessWidget {
  final String artistId;
  final String image;
  final String name;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const ArtistFavCard({
    super.key,
    required this.artistId,
    required this.image,
    required this.name,
    this.onTap,
    this.onRemove,
  });

  ImageProvider<Object> _getImageProvider(String img) {
    if (img.startsWith('data:image')) {
      final base64Str = img.split(',').last;
      final bytes = base64Decode(base64Str);
      return MemoryImage(bytes);
    } else if (img.startsWith('http')) {
      return NetworkImage(img);
    } else if (img.isNotEmpty) {
      return AssetImage(img);
    } else {
      return const AssetImage('assets/images/default_artist.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: const Color(0xFF1D2333),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 32,
              backgroundImage: _getImageProvider(image),
              onBackgroundImageError: (_, __) {},
              child: image.isEmpty
                  ? const Icon(Icons.person, size: 32, color: Colors.white54)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.favorite,
                color: Colors.red.withOpacity(0.8),
                size: 28,
              ),
              onPressed: onRemove,
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class FavoriteSong {
  final String id;
  final String title;
  final String artist;
  final String coverUrl;
  final String previewUrl;
  final DateTime addedAt;

  FavoriteSong({
    required this.id,
    required this.title,
    required this.artist,
    required this.coverUrl,
    required this.previewUrl,
    required this.addedAt,
  });

  factory FavoriteSong.fromMap(Map<String, dynamic> map, String docId) {
    return FavoriteSong(
      id: docId,
      title: map['title'] ?? 'Unknown Title',
      artist: map['artist'] ?? 'Unknown Artist',
      coverUrl: map['coverUrl'] ?? '',
      previewUrl: map['previewUrl'] ?? '',
      addedAt: (map['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class UserPlaylist {
  final String id;
  final String name;
  final String image;
  final String creator;
  final DateTime createdAt;

  UserPlaylist({
    required this.id,
    required this.name,
    required this.image,
    required this.creator,
    required this.createdAt,
  });

  factory UserPlaylist.fromMap(Map<String, dynamic> map, String docId) {
    return UserPlaylist(
      id: docId,
      name: map['name'] ?? 'Untitled Playlist',
      image: map['image'] ?? '',
      creator: map['creator'] ?? 'Unknown',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class FavoriteArtist {
  final String id;
  final String name;
  final String image;
  final DateTime addedAt;

  FavoriteArtist({
    required this.id,
    required this.name,
    required this.image,
    required this.addedAt,
  });

  factory FavoriteArtist.fromMap(Map<String, dynamic> map, String docId) {
    return FavoriteArtist(
      id: docId,
      name: map['name'] ?? 'Unknown Artist',
      image: map['image'] ?? '',
      addedAt: (map['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}