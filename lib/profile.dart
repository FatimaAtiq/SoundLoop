import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/services/cloudinary_service.dart';
import 'signup.dart';
import 'PersonalInforPage.dart';
import 'auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AccountPage(),
    );
  }
}

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  File? _profileImage;
  String userName = "";
  String email = "";
  String profileImageUrl = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String? uid = await AuthService().getSavedUser();
    if (uid != null) {
      var userData = await AuthService().getUserData(uid);
      if (userData != null) {
        setState(() {
          userName = userData['name'] ?? '';
          email = userData['email'] ?? '';
          profileImageUrl = userData['profileImage'] ?? '';
        });
      }
    }
  }


  double _clamp(double v, double min, double max) => v.clamp(min, max);

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);

      String? uid = await AuthService().getSavedUser();
      if (uid == null) return;

      final imageUrl =
      await CloudinaryService.uploadProfileImage(imageFile, uid);

      if (imageUrl != null) {
        await AuthService().updateUserProfileImage(uid, imageUrl);

        setState(() {
          profileImageUrl = imageUrl;
        });
      }
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

    final pageHeight = _clamp(1300 * scaleH, 900, 1400);

    final avatarRadius = _clamp(70 * scaleW, 55, 80);
    final avatarIconSize = _clamp(140 * scaleW, 110, 160);

    final nameFont = _clamp(34 * scaleW, 22, 36);

    final cardWidth = _clamp(370 * scaleW, 280, 420);
    final cardVPad = _clamp(18 * scaleH, 14, 20);
    final cardHPad = rw(20);

    final infoFont = _clamp(18 * scaleW, 14, 19);

    final logoutW = _clamp(200 * scaleW, 160, 240);
    final logoutH = _clamp(60 * scaleH, 52, 66);
    final logoutFont = _clamp(24 * scaleW, 18, 26);

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
              height: pageHeight,
              child: Stack(
                children: [
                  Positioned(
                    top: topSafe + rh(10),
                    left: rw(1),
                    right: rw(20),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/logo.png",
                          width: rw(100),
                          height: rh(70),
                        ),
                        Transform.translate(
                          offset: Offset(-rw(30), 0),
                          child: Image.asset(
                            "assets/images/soundloop_text.png",
                            width: rw(150),
                            height: rh(70),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    top: topSafe + rh(110),
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
                    top: topSafe + rh(160),
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: pickImage,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: avatarRadius,
                                backgroundColor: Colors.transparent,
                                backgroundImage: profileImageUrl.isNotEmpty
                                    ? NetworkImage(profileImageUrl)
                                    : null,
                                child: profileImageUrl.isEmpty
                                    ? Icon(
                                  Icons.account_circle_outlined,
                                  size: avatarIconSize,
                                  color: Colors.white.withOpacity(0.5),
                                )
                                    : null,
                              ),
                              Positioned(
                                bottom: rh(5),
                                right: rw(5),
                                child: Container(
                                  padding: EdgeInsets.all(rw(6)),
                                  decoration: const BoxDecoration(
                                    color: Colors.black87,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    size: _clamp(20 * scaleW, 16, 22),
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: rh(15)),

                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: nameFont,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFE3B53C),
                            shadows: [
                              const Shadow(
                                blurRadius: 25.0,
                                color: Color(0xFFE3B53C),
                                offset: Offset(0, 0),
                              ),
                              Shadow(
                                blurRadius: 40.0,
                                color: const Color(0xFFE3B53C).withOpacity(0.7),
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: rh(30)),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PersonalInfoPage(),
                              ),
                            );
                          },
                          child: Container(
                            width: cardWidth,
                            padding: EdgeInsets.symmetric(
                              vertical: cardVPad,
                              horizontal: cardHPad,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF232834),
                              borderRadius: BorderRadius.circular(rw(40)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: rw(8),
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.white70,
                                  size: _clamp(22 * scaleW, 18, 24),
                                ),
                                Text(
                                  "Personal Info",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: infoFont,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Container(
                                  width: _clamp(32 * scaleW, 26, 34),
                                  height: _clamp(32 * scaleW, 26, 34),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white70,
                                    size: _clamp(20 * scaleW, 16, 22),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: rh(140)),

                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(rw(20)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE3B53C).withOpacity(0.6),
                                blurRadius: rw(20),
                                spreadRadius: 1,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            width: logoutW,
                            height: logoutH,
                            child: ElevatedButton(
                              onPressed: () async {
                                await AuthService().logout();
                                await AuthService().clearUserSession();
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (_) => const Signup()),
                                  (route) => false,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE3B53C),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(rw(50)),
                                ),
                              ),
                              child: Text(
                                "Log Out",
                                style: TextStyle(
                                  fontSize: logoutFont,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFFFFFFF),
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
          ),
        ],
      ),
    );
  }
}
