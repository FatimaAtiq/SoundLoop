import 'package:flutter/material.dart';


List<Map<String, String>> playlists = [
  {
    "title": "My Favourites",
    "creator": "System",
    "image": "assets/images/pop.png",
  }
];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CreatePlaylistPage(
        onSubmit: (playlistData) {
          playlists.add(playlistData);
          // ignore: avoid_print
          print("All Playlists → $playlists");
        },
      ),
    );
  }
}

class CreatePlaylistPage extends StatefulWidget {
  final Function(Map<String, String>) onSubmit;

  const CreatePlaylistPage({
    super.key,
    required this.onSubmit,
  });

  @override
  State<CreatePlaylistPage> createState() => _CreatePlaylistPageState();
}

class _CreatePlaylistPageState extends State<CreatePlaylistPage> {
  final nameController = TextEditingController();
  final creatorController = TextEditingController();

  String selectedImage = "assets/Genres/Pop.png";

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

    final pad = rw(20);
    final gap20 = rh(20);
    final gap30 = rh(30);

    final labelFont = _clamp(16 * scaleW, 14, 17);
    final btnFont = _clamp(18 * scaleW, 15, 20);

    final imageSize = _clamp(80 * scaleW, 64, 92);
    final imageListH = _clamp(80 * scaleH, 64, 95);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Create Playlist",
          style: TextStyle(
            fontSize: _clamp(20 * scaleW, 16, 22),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(pad),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(
                color: Colors.white,
                fontSize: _clamp(16 * scaleW, 14, 18),
              ),
              decoration: InputDecoration(
                labelText: "Playlist Name",
                labelStyle: TextStyle(color: Colors.white70, fontSize: labelFont),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
              ),
            ),

            SizedBox(height: gap20),

            TextField(
              controller: creatorController,
              style: TextStyle(
                color: Colors.white,
                fontSize: _clamp(16 * scaleW, 14, 18),
              ),
              decoration: InputDecoration(
                labelText: "Creator Name",
                labelStyle: TextStyle(color: Colors.white70, fontSize: labelFont),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
              ),
            ),

            SizedBox(height: gap30),

            Text(
              "Select Playlist Image",
              style: TextStyle(
                color: Colors.white70,
                fontSize: labelFont,
              ),
            ),

            SizedBox(height: rh(10)),

            SizedBox(
              height: imageListH,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  imageOption("assets/images/pop.png", imageSize),
                  imageOption("assets/images/lofi.png", imageSize),
                  imageOption("assets/images/bollywood.png", imageSize),
                  imageOption("assets/images/classic.png", imageSize),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
onPressed: () {
  final name = nameController.text.trim();
  final creator = creatorController.text.trim();

  if (name.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please enter a playlist name"),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  final playlistData = {
    "title": name,
    "creator": creator.isEmpty ? "Anonymous" : creator,
    "image": selectedImage,
  };

  widget.onSubmit(playlistData);

  Navigator.pop(context);
},
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFFFC93C),
    padding: EdgeInsets.symmetric(
      vertical: _clamp(14 * scaleH, 12, 16),
      horizontal: rw(40),
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(rw(30)),
    ),
  ),
  child: Text(
    "Submit",
    style: TextStyle(
      color: Colors.black,
      fontSize: btnFont,
      fontWeight: FontWeight.bold,
    ),
  ),
),

            ),
          ],
        ),
      ),
    );
  }

  Widget imageOption(String img, double size) {
    final bool selected = img == selectedImage;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedImage = img;
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: size * 0.15),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? const Color(0xFFFFC93C) : Colors.transparent,
            width: 3,
          ),
        ),
        child: Image.asset(
          img,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
