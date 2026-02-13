import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile.dart';
import 'search.dart';
import 'artist_song.dart'; 
import 'dart:convert';

class ArtistPage extends StatefulWidget {
  final void Function(BuildContext context)? onSearchTap;
  final void Function(BuildContext context)? onAccountTap;
  final VoidCallback? onBackTap;

  const ArtistPage({
    super.key,
    this.onSearchTap,
    this.onAccountTap,
    this.onBackTap,
  });

  @override
  State<ArtistPage> createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  List<Artist> artists = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadArtists();
  }

  Future<void> loadArtists() async {
    setState(() => isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("artists")
          .orderBy("createdAt", descending: true)
          .get();

      artists = snapshot.docs.map((doc) {
        final data = doc.data();
        return Artist.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint("Error loading artists: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  double _clamp(double v, double min, double max) => v.clamp(min, max);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scaleW = size.width / 430.0;
    final scaleH = size.height / 932.0;

    double rw(double v) => _clamp(v * scaleW, v * 0.80, v * 1.30);
    double rh(double v) => _clamp(v * scaleH, v * 0.80, v * 1.30);

    final iconSize = rw(30);
    final backIconSize = rw(25);
    final titleW = rw(200);
    final titleH = rh(55);
    final titleFont = rw(17);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1C),
      body: Container(
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
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(top: rh(140)),
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : artists.isEmpty
                        ? const Center(
                            child: Text(
                              "No artists found",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.only(
                              left: rw(20),
                              right: rw(20),
                              top: rh(20),
                              bottom: rh(20),
                            ),
                            itemCount: artists.length,
                            itemBuilder: (context, index) {
                              final artist = artists[index];
                              final image = artist.image.isNotEmpty
                                  ? artist.image
                                  : 'assets/images/default_artist.png';
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(rw(14)),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ArtistDetailPage(
                                          artistName: artist.name,
                                          artistImage: image,
                                        ),
                                      ),
                                    );
                                  },
                                  child: ArtistCard(
                                    image: image,
                                    name: artist.name,
                                  ),
                                ),
                              );
                            },
                          ),
              ),

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: rw(10)),
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
                              GestureDetector(
                                onTap: () {
                                  if (widget.onSearchTap != null) {
                                    widget.onSearchTap!(context);
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SearchPage(),
                                      ),
                                    );
                                  }
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
                                    size: iconSize,
                                  ),
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
                                        builder: (_) => const AccountPage(),
                                      ),
                                    );
                                  }
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
                                    size: iconSize,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: rh(10)),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: rw(20)),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: widget.onBackTap ?? () => Navigator.pop(context),
                            child: Container(
                              padding: EdgeInsets.all(rw(6)),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(rw(20)),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_rounded,
                                color: Colors.white,
                                size: backIconSize,
                              ),
                            ),
                          ),
                          SizedBox(width: rw(20)),
                          Expanded(
                            child: Center(
                              child: Container(
                                width: titleW,
                                height: titleH,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.07),
                                  borderRadius: BorderRadius.circular(rw(30)),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Artists",
                                  style: TextStyle(
                                    fontSize: titleFont,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFFFC93C),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ArtistCard extends StatelessWidget {
  final String image;
  final String name;

  const ArtistCard({super.key, required this.image, required this.name});

  double _clamp(double v, double min, double max) => v.clamp(min, max);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scaleW = size.width / 430.0;
    final scaleH = size.height / 932.0;

    double rw(double v) => _clamp(v * scaleW, v * 0.80, v * 1.30);
    double rh(double v) => _clamp(v * scaleH, v * 0.80, v * 1.30);

    final cardH = rh(110);
    final imgW = rw(100);
    final nameFont = rw(18);

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
      displayImage = const AssetImage('assets/images/default_artist.png');
    }

    return Container(
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
          SizedBox(width: rw(14)),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: nameFont,
                fontWeight: FontWeight.bold,
              ),
            ),
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

  Artist({
    required this.id,
    required this.name,
    required this.image,
  });

  factory Artist.fromMap(Map<String, dynamic> map, String id) {
    return Artist(
      id: id,
      name: map['name'] ?? '',
      image: map['image'] ?? '',
    );
  }
}
