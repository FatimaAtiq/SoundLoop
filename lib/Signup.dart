import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:myapp/login_with_Password.dart';
import 'auth.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}


class _SignupState extends State<Signup> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 80, 33, 47),
                  Color(0xFF2a1a3a),
                  Color(0xFF1a1a2e),
                  Color.fromARGB(255, 10, 10, 20),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

     
          Positioned(
            top: 50,
            left: 5,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                  
                      Image.asset("assets/images/logo.png", height: 120),
                      const SizedBox(height: 15),

                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),

                    
                      buildField(
                        controller: _nameController,
                        hint: "Full Name",
                        icon: "assets/images/username.png",
                        validator: (v) =>
                            v!.isEmpty ? "Enter your name" : null,
                      ),
                      const SizedBox(height: 10),

                      buildField(
                        controller: _emailController,
                        hint: "Email",
                        icon: "assets/images/mail.png",
                        validator: (v) =>
                            v!.isEmpty ? "Enter your email" : null,
                      ),
                      const SizedBox(height: 10),

                      buildField(
                        controller: _passwordController,
                        hint: "Password",
                        icon: "assets/images/lock.png",
                        obscure: true,
                        validator: (v) =>
                            v!.length < 6 ? "Minimum 6 characters" : null,
                      ),
                      const SizedBox(height: 10),

                      buildField(
                        controller: _confirmPasswordController,
                        hint: "Confirm Password",
                        icon: "assets/images/lock.png",
                        obscure: true,
                        validator: (v) =>
                            v != _passwordController.text
                                ? "Passwords do not match"
                                : null,
                      ),
                      const SizedBox(height: 15),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async{
                            if (_formKey.currentState!.validate()) {
                                     try {
          await AuthService().signUpUser(
            email: _emailController.text,
            password: _passwordController.text,
            name: _nameController.text,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Account created successfully")),
          );

          Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => login_with_password()),
);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                        
    
                            backgroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 5),

                      orDivider(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        GestureDetector(
  onTap: () async {
    User? user = await AuthService().signUpWithGoogle();

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Google account registered successfully")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => login_with_password(),
        ),
      );
    }
  },
  child: socialButton("assets/images/google.png"),
),

                          const SizedBox(width: 20),
                          socialButton("assets/images/fackbook.png"),
                          const SizedBox(width: 20),
                          socialButton("assets/images/apple.png"),
                        ],
                      ),

                      const SizedBox(height: 20),

                      
                      RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: const TextStyle(color: Colors.white),
                          children: [
                            TextSpan(
                              text: "Log In",
                              style: const TextStyle(
                                color: Color(0xFFFFB84C),
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                      Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => login_with_password()),
);
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


Widget buildField({
  required TextEditingController controller,
  required String hint,
  required String icon,
  bool obscure = false,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    obscureText: obscure,
    style: const TextStyle(color: Colors.white, fontSize: 14),
    validator: validator,
    decoration: InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 15, right: 10),
        child: Image.asset(icon, width: 16, color: Colors.white),
      ),
      filled: true,
      fillColor: const Color.fromARGB(255, 80, 33, 47),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.grey), 
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.grey),
      ),
    ),
  );
}


Widget socialButton(String path) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: const Color.fromARGB(255, 80, 33, 47),
      border: Border.all(color: Colors.grey), 
    ),
    child: Image.asset(path, height: 26),
  );
}


Widget orDivider() {
  return const Padding(
    padding: EdgeInsets.symmetric(vertical: 20),
    child: Row(
      children: [
        Expanded(child: Divider(color: Colors.grey)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "or continue with",
            style: TextStyle(color: Colors.white),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey)),
      ],
    ),
  );
}
