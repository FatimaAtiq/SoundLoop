import 'package:flutter/material.dart';
import 'FavoritesPage.dart';
import 'homepage.dart';
import 'profile.dart';
import 'Search.dart';
import 'library.dart';
import 'artist.dart';
import 'package:firebase_core/firebase_core.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}


class MainPage extends StatefulWidget {
  final int initialIndex;
  const MainPage({super.key, this.initialIndex = 0});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  late int selectedIndex;
  bool navDisabled = false;

  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;

    screens = [
      HomePage(
        onSearchTap: (context) => openOverlay(context, const SearchPage()),
        onAccountTap: (context) => openOverlay(context, const AccountPage()),
      ),
      FavoritesPage(
        onSearchTap: (context) => openOverlay(context, const SearchPage()),
        onAccountTap: (context) => openOverlay(context, const AccountPage()),
      ),
      LibraryPage(
        onSearchTap: (context) => openOverlay(context, const SearchPage()),
        onAccountTap: (context) => openOverlay(context, const AccountPage()),
      ),
      ArtistPage(
        onSearchTap: (context) => openOverlay(context, const SearchPage()),
        onAccountTap: (context) => openOverlay(context, const AccountPage()),
      ),
    ];
  }

  void openOverlay(BuildContext context, Widget page) async {
    setState(() => navDisabled = true);
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    setState(() => navDisabled = false);
  }

  LinearGradient getNavGradient() {
    if (navDisabled) {
      return const LinearGradient(
        colors: [Color(0xFF0D0D1C), Color(0xFF0D0D1C)],
      );
    }
    return const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0xFF0B0614),
        Color(0xFF3B1927),
      ],
    );
  }

  double _clamp(double v, double min, double max) => v.clamp(min, max);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    
    final scaleW = w / 430.0;
    final scaleH = h / 932.0;

  
    final navHeight = _clamp(140 * scaleH, 110, 160);
    final navRadius = _clamp(40 * scaleW, 28, 44);
    final iconPadding = _clamp(8 * scaleW, 6, 10);

    final gap = _clamp(18 * scaleH, 12, 20);

    final indicatorH = _clamp(6 * scaleH, 4, 7);
    final indicatorW = _clamp(140 * scaleW, 110, 170);
    final indicatorRadius = _clamp(20 * scaleW, 14, 22);

    final homeIconSize = _clamp(39 * scaleW, 30, 42);
    final otherIconSize = _clamp(35 * scaleW, 28, 38);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1C),
      body: Stack(
        children: [
          screens[selectedIndex],

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: navHeight,
              decoration: BoxDecoration(
                gradient: getNavGradient(),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(navRadius),
                  topRight: Radius.circular(navRadius),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      navIcon(Icons.home_outlined, 0,
                          padding: iconPadding,
                          sizeSelected: homeIconSize,
                          sizeOther: otherIconSize),
                      navIcon(Icons.favorite_border, 1,
                          padding: iconPadding,
                          sizeSelected: homeIconSize,
                          sizeOther: otherIconSize),
                      navIcon(Icons.library_music_outlined, 2,
                          padding: iconPadding,
                          sizeSelected: homeIconSize,
                          sizeOther: otherIconSize),
                    ],
                  ),
                  SizedBox(height: gap),
                  Container(
                    height: indicatorH,
                    width: indicatorW,
                    decoration: BoxDecoration(
                      color: navDisabled
                          ? Colors.grey.shade700
                          : Colors.yellow.shade600,
                      borderRadius: BorderRadius.circular(indicatorRadius),
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

  Widget navIcon(
      IconData iconData,
      int index, {
        required double padding,
        required double sizeSelected,
        required double sizeOther,
      }) {
    final bool isSelected = !navDisabled && selectedIndex == index;

    return GestureDetector(
      onTap: () {
        if (!navDisabled) {
          setState(() => selectedIndex = index);
        }
      },
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: isSelected
              ? const [
            BoxShadow(
              color: Color(0xFFFFC56D),
              blurRadius: 25,
              spreadRadius: -14,
            ),
          ]
              : [],
        ),
        child: Icon(
          iconData,
          size: index == 0 ? sizeSelected : sizeOther,
          color: isSelected ? const Color(0xFFFFC56D) : Colors.white70,
        ),
      ),
    );
  }
}
