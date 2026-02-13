import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:myapp/Mainpage.dart';
import 'package:myapp/admin.dart';
import 'package:myapp/signup.dart';
import 'auth.dart';


class login_with_password extends StatefulWidget {
  const login_with_password({super.key});

  @override
  State<login_with_password> createState() => _LoginWithPasswordState();
}

class _LoginWithPasswordState extends State<login_with_password> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
              onPressed: () => Navigator.pop(context),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  Image.asset("assets/images/logo.png", height: 100),
                  const SizedBox(height: 30),
                  const Text(
                    "Login into your Account",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 23, right: 8),
                              child: Image.asset(
                                "assets/images/mail.png",
                                width: 15,
                                height: 15,
                                color: Colors.white,
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minHeight: 30,
                              minWidth: 30,
                            ),
                            labelText: "Email",
                            labelStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Color.fromARGB(255, 80, 33, 47),
                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter your email";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 23, right: 8),
                              child: Image.asset(
                                "assets/images/lock.png",
                                width: 15,
                                height: 15,
                                color: Colors.white,
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(minHeight: 30, minWidth: 30),
                            labelText: "Password",
                            labelStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Color.fromARGB(255, 80, 33, 47),
                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter your password";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                               
                             if(_emailController.text=="admin@gmail.com"&&_passwordController.text=="admin123"){
                              Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) =>AdminPage()),
  );
                             }
                                        try {
          await AuthService().login(
           email: _emailController.text,
           password: _passwordController.text,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login")),
          );

   Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => MainPage()),
  (route) => false,
);

        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              elevation: 8,
                              shadowColor: Colors.white.withOpacity(0.8),
                            ),
                            child: const Text(
                              "Log in",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 5),

                        orDivider(),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            socialButton("assets/images/google.png"),
                            const SizedBox(width: 20),
                            socialButton("assets/images/fackbook.png"),
                            const SizedBox(width: 20),
                            socialButton("assets/images/apple.png"),
                          ],
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
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const Signup()),
                                    );
                                  },
                              ),
                            ],
                          ),
                        )
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


Widget socialButton(String path) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: const Color.fromARGB(255, 80, 33, 47),
      border: Border.all(color: Colors.white24),
    ),
    child: Image.asset(path, height: 30),
  );
}


Widget orDivider() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Row(
      children: [
        const Expanded(child: Divider(color: Colors.grey, thickness: 1, endIndent: 10)),
        const Text(
          "or continue with",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const Expanded(child: Divider(color: Colors.grey, thickness: 1, indent: 10)),
      ],
    ),
  );
}
