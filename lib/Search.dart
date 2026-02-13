import 'package:flutter/material.dart';
import 'package:myapp/MusicPlayerPage.dart';
import 'package:myapp/services/searchsong.dart';
import './model/song.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SearchPage(),
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  
  final TextEditingController _controller = TextEditingController();
  List<Song> filteredSongs = [];
  bool isLoading = false;

  double _clamp(double v, double min, double max) => v.clamp(min, max);


  void searchSongs(String query) async {
    setState(() => isLoading = true);
    try {
      final results = await fetchSongsBySearch(query);
      setState(() => filteredSongs = results);
    } catch (e) {
      print('Error fetching songs: $e');
      setState(() => filteredSongs = []);
    } finally {
      setState(() => isLoading = false);
    }
  }

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
    final logoTop = topSafe + rh(10);
    final backTop = topSafe + rh(110);
    final resultsTop = topSafe + rh(190);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1C),
      body: Stack(
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
          ),

          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: rh(120)),
            child: SizedBox(
              height: _clamp(1100 * scaleH, 850, 1200),
              child: Stack(
                children: [
                  Positioned(
                    top: logoTop,
                    left: rw(1),
                    right: rw(20),
                    child: Row(
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
                  ),

                  Positioned(
                    top: backTop,
                    left: rw(20),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(rw(6)),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(rw(20)),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white,
                          size: _clamp(25 * scaleW, 18, 26),
                        ),
                      ),
                    ),
                  ),

              
                  Positioned(
                    top: backTop,
                    left: rw(70),
                    right: rw(20),
                    child: Container(
                      height: _clamp(45 * scaleH, 40, 52),
                      padding: EdgeInsets.symmetric(horizontal: rw(12)),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(rw(25)),
                      ),
                      child: Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: rw(35),
                                height: rw(35),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFFFFF).withOpacity(0.7),
                                      blurRadius: rw(15),
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.search,
                                color: Colors.white,
                                size: _clamp(20 * scaleW, 16, 22),
                              ),
                            ],
                          ),
                          SizedBox(width: rw(10)),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: _clamp(16 * scaleW, 13, 18),
                              ),
                              decoration: InputDecoration(
                                hintText: "Search Songs",
                                hintStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: _clamp(16 * scaleW, 13, 18),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (value) => searchSongs(value),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    top: resultsTop,
                    left: rw(25),
                    right: rw(0),
                    child: SizedBox(
                      height: _clamp(520 * scaleH, 380, 650),
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : filteredSongs.isEmpty
                              ? const Center(
                                  child: Text(
                                    "No songs found",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              : SingleChildScrollView(
                                  padding: EdgeInsets.symmetric(horizontal: rw(15)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                  children: filteredSongs.map((song) => Padding(
  padding: EdgeInsets.only(bottom: rh(15)),
  child: SearchCard(
    song: song,
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MusicPlayerPage(song: song),
        ),
      );
    },
  ),
)).toList(),


                                        
                                  ),
                                ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchCard extends StatelessWidget {
  final Song song;
  final VoidCallback? onTap;

  const SearchCard({
    super.key,
    required this.song,
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

    double rw(double v) => _clamp(v * scaleW, v * 0.80, v * 1.30);
    double rh(double v) => _clamp(v * scaleH, v * 0.80, v * 1.30);

    final cardW = _clamp(340 * scaleW, 280, 380);
    final cardH = _clamp(60 * scaleH, 54, 70);
    final imgW = _clamp(70 * scaleW, 60, 85);
    final imgH = cardH;
    final titleFont = _clamp(18 * scaleW, 14, 20);
    final artistFont = _clamp(12 * scaleW, 10, 14);

    return GestureDetector(
      onTap: onTap ?? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MusicPlayerPage(song: song),
          ),
        );
      },
      child: Container(
        width: cardW,
        height: cardH,
        decoration: BoxDecoration(
          color: const Color(0xFF1D2333),
          borderRadius: BorderRadius.circular(rw(18)),
        ),
        child: Row(
          children: [
            Container(
              width: imgW,
              height: imgH,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(rw(12)),
                image: DecorationImage(
                  image: NetworkImage(song.coverUrl),
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
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: titleFont,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: rh(1)),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: artistFont,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.7),
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
