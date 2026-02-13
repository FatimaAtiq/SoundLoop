import 'package:flutter/material.dart';
import 'package:myapp/Mainpage.dart%20';
import 'get_started_screen.dart';
import 'auth.dart';


void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreenWrapper(),
  ));
}
class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  @override
  void initState() {
    super.initState();
    _startApp();

      

  }
    void _startApp() async {
   
    await Future.delayed(const Duration(seconds: 3));

    String? uid = await AuthService().getSavedUser();

    if (uid != null) {
      var userData = await AuthService().getUserData(uid);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>MainPage(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GetStartedScreen()),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return const SplashScreenUI();
  }
}

class SplashScreenUI extends StatelessWidget {
  const SplashScreenUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 10, 10, 20),
              Color(0xFF1a1a2e),
              Color(0xFF2a1a3a),
              Color.fromARGB(255, 80, 33, 47),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.01, 0.7, 0.8, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/logo.png", height: 120),
              const SizedBox(height: 5),
              Image.asset("assets/images/soundloop_text.png", height: 50),
              const SizedBox(height: 5),
              Image.asset("assets/images/text.png", height: 10),
            ],
          ),
        ),
      ),
    );
  }
}