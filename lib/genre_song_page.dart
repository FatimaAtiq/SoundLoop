import 'package:flutter/material.dart';
import 'package:myapp/MusicPlayerPage.dart';
import './services/api.dart';
import './model/song.dart';
import 'package:audioplayers/audioplayers.dart';

class GenrePage extends StatefulWidget {
  final String genreName;
  final String genreImage;
  final Color themeColor;

  const GenrePage({
    super.key,
    required this.genreName,
    required this.genreImage,
    this.themeColor = const Color(0xFFDAB659),
  });

  @override
  State<GenrePage> createState() => _GenrePageState();
}

class _GenrePageState extends State<GenrePage> with SingleTickerProviderStateMixin {
  List<Song> songs = [];
  bool isLoading = true;
  final AudioPlayer _player = AudioPlayer();
  String currentPlaying = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    loadGenreSongs();
    _animationController.forward();
  }

  Future<void> loadGenreSongs() async {
    setState(() => isLoading = true);
    try {
      
      String query = widget.genreName.toLowerCase();
      
      query = query.replaceAll('-', ' ');
      
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

 

  @override
  void dispose() {
    _player.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
       
          AnimatedContainer(
            duration: const Duration(seconds: 2),
            width: double.infinity,
            height: double.infinity,
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
                )
          ),
          
          SafeArea(
            child: Column(
              children: [
           
                _buildHeader(context),
                
           
                Expanded(
                  child: isLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: widget.themeColor,
                                strokeWidth: 3,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Loading ${widget.genreName} tracks...',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : songs.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.music_off,
                                    size: 80,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'No songs found',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : FadeTransition(
                              opacity: _fadeAnimation,
                              child: _buildSongsList(),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.themeColor.withOpacity(0.2),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
        
          Row(
            children: [
            
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(
                    color: widget.themeColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  color: Colors.white,
                  iconSize: 20,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.genreName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      widget.themeColor,
                      widget.themeColor.withOpacity(0.7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.themeColor.withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.shuffle),
                  color: Colors.white,
                  iconSize: 24,
                  onPressed: () {
                    if (songs.isNotEmpty) {
                      songs.shuffle();
                      setState(() {});
                    }
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
       
          Row(
            children: [
            
              Hero(
                tag: 'genre_${widget.genreName}',
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: widget.themeColor.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      widget.genreImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                widget.themeColor.withOpacity(0.6),
                                widget.themeColor.withOpacity(0.3),
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.music_note,
                            size: 50,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 20),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${songs.length} Tracks',
                      style: TextStyle(
                        color: widget.themeColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Curated collection of ${widget.genreName.toLowerCase()} music',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSongsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        final isPlaying = currentPlaying == song.previewUrl;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isPlaying
                ? LinearGradient(
                    colors: [
                      widget.themeColor.withOpacity(0.2),
                      widget.themeColor.withOpacity(0.05),
                    ],
                  )
                : null,
            border: Border.all(
              color: isPlaying
                  ? widget.themeColor.withOpacity(0.5)
                  : Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MusicPlayerPage(song: song),
      ),
    );
  },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Center(
                        child: isPlaying
                            ? Icon(
                                Icons.equalizer,
                                color: widget.themeColor,
                                size: 28,
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          song.coverUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade800,
                              child: Icon(
                                Icons.music_note,
                                color: Colors.white.withOpacity(0.5),
                                size: 30,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                  
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
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
                    
               
              
                    
                    const SizedBox(width: 8),
                 
                    
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  
 
}