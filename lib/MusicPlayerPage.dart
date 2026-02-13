import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './model/song.dart';

class MusicPlayerPage extends StatefulWidget {
  final Song song;
  final List<Song> playlist;
  final int currentIndex;

  const MusicPlayerPage({
    super.key,
    required this.song,
    this.playlist = const [],
    this.currentIndex = 0,
  });

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  late AudioPlayer _audioPlayer;

  bool isPlaying = false;
  bool isRepeat = false;
  bool isShuffle = false;
  bool isFavorite = false;

  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  late int currentIndex;
  late Song currentSong;

  double rw(double v) =>
      v * (MediaQuery.of(context).size.width / 375);

  double rh(double v) =>
      v * (MediaQuery.of(context).size.height / 812);

  double rf(double v) =>
      v * MediaQuery.of(context).textScaleFactor.clamp(0.9, 1.2);


  @override
  void initState() {
    super.initState();
    currentIndex = widget.currentIndex;
    currentSong = widget.song;
    _audioPlayer = AudioPlayer();
    _setupAudioPlayer();
    _playSong();
    _checkIfFavorite();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => duration = d);
    });

    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => position = p);
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => isPlaying = state == PlayerState.playing);
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          isPlaying = false;
          position = Duration.zero;
        });
        if (isRepeat) {
          _playSong();
        } else {
          _playNext();
        }
      }
    });
  }

  Future<void> _playSong() async {
    await _audioPlayer.stop();
    await _audioPlayer.play(UrlSource(currentSong.previewUrl));
  }

  Future<void> _togglePlayPause() async {
    isPlaying ? await _audioPlayer.pause() : await _audioPlayer.resume();
  }

  Future<void> _playNext() async {
    if (widget.playlist.isEmpty ||
        currentIndex >= widget.playlist.length - 1) {
      return;
    }

    setState(() {
      currentIndex++;
      currentSong = widget.playlist[currentIndex];
      position = Duration.zero;
    });
    _playSong();
    _checkIfFavorite();
  }

  Future<void> _playPrevious() async {
    if (widget.playlist.isEmpty || currentIndex <= 0) return;

    setState(() {
      currentIndex--;
      currentSong = widget.playlist[currentIndex];
      position = Duration.zero;
    });
    _playSong();
    _checkIfFavorite();
  }

  String _format(Duration d) =>
      "${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}";


  Future<void> _checkIfFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => isFavorite = false);
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .where('title', isEqualTo: currentSong.title)
          .where('artist', isEqualTo: currentSong.artist)
          .get();

      setState(() {
        isFavorite = snapshot.docs.isNotEmpty;
      });
    } catch (e) {
      debugPrint('Error checking favorite status: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add favorites')),
      );
      return;
    }

    try {
      final favoritesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites');

      if (isFavorite) {
        final snapshot = await favoritesRef
            .where('title', isEqualTo: currentSong.title)
            .where('artist', isEqualTo: currentSong.artist)
            .get();

        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }

        setState(() => isFavorite = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed "${currentSong.title}" from favorites'),
            backgroundColor: Colors.grey,
          ),
        );
      } else {
        await favoritesRef.add({
          'title': currentSong.title,
          'artist': currentSong.artist,
          'coverUrl': currentSong.coverUrl,
          'previewUrl': currentSong.previewUrl,
          'addedAt': Timestamp.now(),
        });

        setState(() => isFavorite = true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added "${currentSong.title}" to favorites'),
            backgroundColor: const Color(0xFFDAB659),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update favorites'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  Future<void> _showAddToPlaylistDialog() async {
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

    final playlists = playlistsSnapshot.docs;

    if (playlists.isEmpty) {
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
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    final playlistName = playlist['name'] ?? 'Untitled';
                    final playlistImage = playlist['image'] ?? '';

                    return ListTile(
                      leading: playlistImage.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                playlistImage,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 50,
                                  height: 50,
                                  color: const Color(0xFFFFC93C).withOpacity(0.3),
                                  child: const Icon(
                                    Icons.playlist_play,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFC93C).withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.playlist_play,
                                color: Colors.white,
                              ),
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
                        _addSongToPlaylist(user.uid, playlist.id);
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

  Future<void> _addSongToPlaylist(String userId, String playlistId) async {
    try {
      final existingSong = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('playlists')
          .doc(playlistId)
          .collection('songs')
          .where('title', isEqualTo: currentSong.title)
          .where('artist', isEqualTo: currentSong.artist)
          .get();

      if (existingSong.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Song already exists in this playlist'),
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
        'title': currentSong.title,
        'artist': currentSong.artist,
        'coverUrl': currentSong.coverUrl,
        'previewUrl': currentSong.previewUrl,
        'addedAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added "${currentSong.title}" to playlist'),
          backgroundColor: const Color(0xFFFFC93C),
        ),
      );
    } catch (e) {
      debugPrint('Error adding song to playlist: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add song to playlist'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final coverSize =
        MediaQuery.of(context).size.width.clamp(280, 420) * 0.75;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF50212F),
              Color(0xFF2A1A3A),
              Color(0xFF1A1A2E),
              Color(0xFF0A0A14),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: rw(20),
                  vertical: rh(20),
                ),
                child: Column(
                  children: [
                    _topBar(),
                    SizedBox(height: rh(30)),
                    _albumCover(coverSize),
                    SizedBox(height: rh(25)),
                    _songInfo(),
                    SizedBox(height: rh(25)),
                    _progressBar(),
                    SizedBox(height: rh(25)),
                    _controls(),
                    SizedBox(height: rh(20)),
                    _extraControls(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _topBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        Text(
          "Now Playing",
          style: TextStyle(
            color: Colors.white,
            fontSize: rf(18),
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: _showMoreOptions,
        ),
      ],
    );
  }

  void _showMoreOptions() {
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
              // Song info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        currentSong.coverUrl,
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
                            currentSong.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            currentSong.artist,
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
              ListTile(
                leading: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? const Color(0xFFDAB659) : Colors.white,
                ),
                title: Text(
                  isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _toggleFavorite();
                },
              ),
              ListTile(
                leading: const Icon(Icons.playlist_add, color: Colors.white),
                title: const Text(
                  'Add to Playlist',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showAddToPlaylistDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.white),
                title: const Text(
                  'Share',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.white),
                title: const Text(
                  'Song Info',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _albumCover(double size) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 15),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.network(
          currentSong.coverUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Center(child: Icon(Icons.music_note, size: 60)),
        ),
      ),
    );
  }

  Widget _songInfo() {
    return Column(
      children: [
        Text(
          currentSong.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: rf(22),
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: rh(8)),
        Text(
          currentSong.artist,
          style: TextStyle(
            color: Colors.white70,
            fontSize: rf(14),
          ),
        ),
      ],
    );
  }

  Widget _progressBar() {
    return Column(
      children: [
        Slider(
          value: position.inSeconds
              .clamp(0, duration.inSeconds)
              .toDouble(),
          max: duration.inSeconds.toDouble().clamp(1, double.infinity),
          activeColor: const Color(0xFFDAB659),
          inactiveColor: Colors.white24,
          onChanged: (v) =>
              _audioPlayer.seek(Duration(seconds: v.toInt())),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_format(position),
                style: TextStyle(color: Colors.white60, fontSize: rf(12))),
            Text(_format(duration),
                style: TextStyle(color: Colors.white60, fontSize: rf(12))),
          ],
        )
      ],
    );
  }

  Widget _controls() {
    final shortest = MediaQuery.of(context).size.shortestSide;

    final iconSize = (shortest * 0.08).clamp(36.0, 56.0);
    final playSize = (shortest * 0.14).clamp(60.0, 90.0);
    final spacing = (shortest * 0.06).clamp(16.0, 32.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _circleButton(
          icon: Icons.skip_previous_rounded,
          size: iconSize,
          onTap: _playPrevious,
        ),

        SizedBox(width: spacing),

        GestureDetector(
          onTap: _togglePlayPause,
          child: Container(
            height: playSize,
            width: playSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFDAB659), Color(0xFFB8935C)],
              ),
            ),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: playSize * 0.55,
              color: Colors.white,
            ),
          ),
        ),

        SizedBox(width: spacing),

        _circleButton(
          icon: Icons.skip_next_rounded,
          size: iconSize,
          onTap: _playNext,
        ),
      ],
    );
  }

  Widget _circleButton({
    required IconData icon,
    required double size,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(size / 2),
      onTap: onTap,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.12),
        ),
        child: Icon(
          icon,
          size: size * 0.55,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _extraControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _icon(Icons.shuffle, isShuffle, () {
          setState(() => isShuffle = !isShuffle);
        }),
        _icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            isFavorite,
            _toggleFavorite, // Direct favorite toggle
        ),
        _icon(Icons.repeat, isRepeat, () {
          setState(() => isRepeat = !isRepeat);
        }),
      ],
    );
  }

  Widget _icon(IconData icon, bool active, VoidCallback onTap) {
    return IconButton(
      icon: Icon(
        icon,
        color: active ? const Color(0xFFDAB659) : Colors.white70,
        size: rf(26),
      ),
      onPressed: onTap,
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}