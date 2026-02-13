import 'package:flutter/material.dart';
import 'login_with_Password.dart';
import 'package:flutter/gestures.dart';

class login extends StatelessWidget {
  const login({super.key});

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
            left: 5,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/logo.png", height: 100),
                const SizedBox(height: 30),

                const Text(
                  "Welcome back!",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),

                const SizedBox(height: 30),

                customButton(
                  iconPath: "assets/images/google.png",
                  text: "Continue with Google",
                  onPressed: () {},
                ),
                const SizedBox(height: 15),

                customButton(
                  iconPath: "assets/images/fackbook.png",
                  text: "Continue with Facebook",
                  onPressed: () {},
                ),
                const SizedBox(height: 15),

                customButton(
                  iconPath: "assets/images/apple.png",
                  text: "Continue with Apple",
                  onPressed: () {},
                ),

                orDivider(),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const login_with_password(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 18),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                    shadowColor: Colors.white.withOpacity(0.8),
                  ),
                  child: const Text(
                    "Login with password",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                RichText(
                  text: TextSpan(
                    text: "Don’t have an account? ",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    children: [
                      TextSpan(
                        text: "Sign Up",
                        style: const TextStyle(
                          color: Color(0xFFFFB84C),
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = (
                            
                          ) {
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget customButton({
    required String iconPath,
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 300,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 80, 33, 47),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(
                color: Color.fromARGB(255, 109, 109, 109), width: 1.0),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconPath, height: 40),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget orDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: Colors.grey,
              thickness: 1,
              endIndent: 10,
            ),
          ),
          const Text(
            "or",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Divider(
              color: Colors.grey,
              thickness: 1,
              indent: 10,
            ),
          ),
        ],
      ),
    );
  }
}
