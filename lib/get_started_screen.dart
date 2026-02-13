import 'package:flutter/material.dart';
import 'login.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
        
          Container(
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
            ),
          ),

      
          Positioned(
            top: 50,
            left: 30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.05),
                    Colors.white.withOpacity(0.0),
                  ],
                  radius: 0.8,
                  center: Alignment.center,
                ),
              ),
            ),
          ),
          Positioned(
            top: 150,
            right: 40,
            child: CircleAvatar(
              radius: 30,
              backgroundColor:
                  const Color.fromARGB(255, 126, 126, 126).withOpacity(0.03),
            ),
          ),
          Positioned(
            bottom: 180,
            left: 60,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white.withOpacity(0.05),
            ),
          ),

          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                "assets/images/girl.png",
                height: 250,
              ),
            ),
          ),

        
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a2e),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // RichText description
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: 'Mulish',
                        fontWeight: FontWeight.bold,
                        wordSpacing: 6.5,
                      ),
                      children: [
                        TextSpan(text: "From the "),
                        TextSpan(
                          text: "latest ",
                          style: TextStyle(color: Color(0xFFE8A84C)),
                        ),
                        TextSpan(text: "to the "),
                        TextSpan(
                          text: "greatest ",
                          style: TextStyle(color: Color(0xFFE8A84C)),
                        ),
                        TextSpan(text: "hits, play your "),
                        TextSpan(
                          text: "favorite tracks ",
                          style: TextStyle(color: Color(0xFFE8A84C)),
                        ),
                        TextSpan(text: "on "),
                        TextSpan(
                          text: "SoundLoop ",
                          style: TextStyle(color: Color(0xFFE8A84C)),
                        ),
                        TextSpan(text: "now!"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: () {
                      print("Get Started Pressed");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const login()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 80, vertical: 18),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                      shadowColor: Colors.white.withOpacity(0.5),
                    ),
                    child: const Text(
                      "Get Started",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Mulish',
                        letterSpacing: 0.5,
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
