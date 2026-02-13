import 'package:flutter/material.dart';
import 'package:myapp/MusicPlayerPage.dart';
import 'profile.dart';
import 'artist.dart';
import 'search.dart';
import 'package:audioplayers/audioplayers.dart';
import './model/song.dart';
import './services/api.dart';
import 'genre_song_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';


class HomePage extends StatefulWidget {

  const HomePage({super.key, required void Function(dynamic context) onSearchTap , required void Function(dynamic context) onAccountTap});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
    List<Song> songs = [];
  bool isLoading = true;
  final AudioPlayer _player = AudioPlayer();
  String currentPlaying = '';
List<Artist> artists = [];
bool isArtistLoading = true;

   @override
  void initState() {
    super.initState();
    loadData("bollywood");
     loadArtists();
  }
    Future<void> loadData(String query) async {
    setState(() => isLoading = true);
    try {
      final loadedSongs = await ItunesApiService.fetchSongs(query);
      setState(() {
        songs = loadedSongs;
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() => isLoading = false);
    }
  }



Future<void> loadArtists() async {
  setState(() => isArtistLoading = true);

  try {
    final snapshot = await FirebaseFirestore.instance
        .collection("artists")
        .orderBy("createdAt", descending: true)
        .get();

    artists = snapshot.docs.map((doc) {
      final data = doc.data();
      return Artist.fromMap(data, doc.id);
          return null;
    }).whereType<Artist>().toList();
  } catch (e) {
    debugPrint("Error loading artists: $e");
  } finally {
    setState(() => isArtistLoading = false);
  }
}


  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1C),
      body: SafeArea(
        child: Stack(
          children: [
         
            Container(
               decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 80, 33, 47),
                      Color(0xFF2a1a3a),
                      Color(0xFF1a1a2e),
                      Color.fromARGB(255, 10, 10, 20),
                      Color(0xFF1a1a2e),
                      Color(0xFF2a1a3a),
                      Color.fromARGB(255, 80, 33, 47),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.1, 0.2, 0.3, 0.6, 0.7, 0.8, 1.0],
                  ),
                ),
            ),

            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16,
                10,
                16,
                MediaQuery.of(context).padding.bottom + 90, 
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/logo.png',
                              height: 45,
                            ),
                            const SizedBox(width: 6),
                            Image.asset(
                              'assets/images/soundloop_text.png',
                              height: 45,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SearchPage()),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.account_circle_outlined,
                            color: Colors.white.withOpacity(0.6)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AccountPage()),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

             
                  const Text(
                    "Welcome Back!",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 25),

                 
                  const Text(
                    "Genres!",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: const [
                      MusicCategoryCard("assets/images/bollywood.png", "BOLLYWOOD"),
                      MusicCategoryCard("assets/images/released.png", "RELEASED"),
                      MusicCategoryCard("assets/images/kpop.png", "K-POP"),
                      MusicCategoryCard("assets/images/lofi.png", "LO-FI"),
                      MusicCategoryCard("assets/images/pop.png", "POP"),
                      MusicCategoryCard("assets/images/classic.png", "CLASSICS"),
                    ],
                  ),

                  const SizedBox(height: 35),

                  
                  const Text(
                    "Trending Songs",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

               SizedBox(
      height:200, 
      child: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.white.withOpacity(0.7),
                strokeWidth: 2,
              ),
            )
          : songs.isEmpty
              ? Center(
                  child: Text(
                    "No songs available",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,

                  itemCount: songs.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    return SizedBox(

                      child: SongCard(
                        title: songs[index].title,
                        image: songs[index].coverUrl,
                        artist: songs[index].artist,
                        isPlaying: currentPlaying == songs[index].previewUrl,
                        onTap: () {
                          Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => MusicPlayerPage(
                                              song: songs[index],
                                              playlist: songs,
                                              currentIndex: index,
                                            ),
                                          ),
                                        );
                        },
                      ),
                    );
                  },
                ),
               ),

                  const SizedBox(height: 35),

                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Artists",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ArtistPage()),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                SizedBox(
  height: 130,
  child: isArtistLoading
      ? const Center(child: CircularProgressIndicator(color: Colors.white))
      : ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: artists.length,
          itemBuilder: (context, index) {
            final artist = artists[index];
            return ArtistCard(
              artist.image.isNotEmpty
                  ? artist.image
                  : 'assets/images/default_artist.png', 
              artist.name,
            );
          },
        ),
),


                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class MusicCategoryCard extends StatelessWidget {
  final String title;
  final String image;
  final Color themeColor;
  final VoidCallback? onTap;

  const MusicCategoryCard(
    this.image,
    this.title, {
    this.themeColor = const Color(0xFFDAB659),
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
   return GestureDetector(
          onTap: onTap ?? () {
           
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => GenrePage(
                  genreName: title,
                  genreImage: image,
                  themeColor: themeColor,
                ),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              ),
            );
          },
      child: Container(
        width: MediaQuery.of(context).size.width / 2 - 26,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF1D2333),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                image,
                width: 70,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class SongCard extends StatelessWidget {
  final String title;
  final String image;
  final String artist;
  final bool isPlaying;
  final double imageSize;
  final VoidCallback? onTap;

  const SongCard({
    super.key,
    required this.title,
    required this.image,
    required this.artist,
    this.isPlaying = false,
    this.imageSize = 140,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: imageSize,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isPlaying ? Colors.white.withOpacity(0.08) : Colors.transparent,
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: image.startsWith('http')
                        ? Image.network(
                            image,
                            height: imageSize,
                            width: imageSize,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: imageSize,
                                width: imageSize,
                                color: Colors.grey.shade800,
                                child: Icon(
                                  Icons.music_note,
                                  color: Colors.white.withOpacity(0.5),
                                  size: imageSize * 0.4,
                                ),
                              );
                            },
                          )
                        : Image.asset(
                            image,
                            height: imageSize,
                            width: imageSize,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                if (isPlaying)
                  const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            Text(
              artist,
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class ArtistCard extends StatelessWidget {
  final String image, name;

  const ArtistCard(this.image, this.name, {super.key});

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
     
      displayImage = const AssetImage('assets/images/atifaslam.png');
    }

    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 14),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: displayImage,
            backgroundColor: Colors.grey.shade800,
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class Artist {
  final String id;
  final String name;
  final String image; 
  final DateTime createdAt;

  Artist({
    required this.id,
    required this.name,
    required this.image,
    required this.createdAt,
  });

  factory Artist.fromMap(Map<String, dynamic> map, String docId) {
    return Artist(
      id: docId,
      name: map['name'] ?? 'Unknown',
      image: map['image'] ?? '', // can be base64
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
