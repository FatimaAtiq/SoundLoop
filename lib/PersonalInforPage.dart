import 'package:flutter/material.dart';
import 'auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
bool _isSaving = false;
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
          _nameController.text = userData['name'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _passwordController.text = '********'; 
        });
      }
    }
  }


  Future<void> _updateUserData() async {
    String? uid = await AuthService().getSavedUser();
    if (uid == null) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': _nameController.text.trim(),
      
      });
      

        if (_passwordController.text != '********' &&
        _passwordController.text.trim().isNotEmpty) {
      var user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(_passwordController.text.trim());
      }
    }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Information updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update info: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  double _clamp(double v, double min, double max) => v.clamp(min, max);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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

    final titleFont = _clamp(18 * scaleW, 14, 20);
    final inputFont = _clamp(20 * scaleW, 15, 22);

    final fieldH = _clamp(60 * scaleH, 52, 66);
    final iconSize = _clamp(28 * scaleW, 20, 30);

    final leftGap = _clamp(50 * scaleW, 28, 55);
    final betweenGap = rw(20);
    final rightGap = rw(15);

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
            child: Column(
              children: [
                SizedBox(height: topSafe + rh(10)),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: rw(5)),
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

                SizedBox(height: rh(30)),

             
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: rw(20)),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(rw(6)),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(rw(20)),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Colors.white.withOpacity(0.5),
                            size: _clamp(25 * scaleW, 18, 26),
                          ),
                        ),
                      ),
                      SizedBox(width: rw(12)),
                      Text(
                        "Edit Information",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: titleFont,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: rh(50)),

              
                _buildInputField(
                  controller: _nameController,
                  icon: Icons.person_outlined,
                  hint: "Name",
                  fieldH: fieldH,
                  iconSize: iconSize,
                  leftGap: leftGap,
                  betweenGap: betweenGap,
                  rightGap: rightGap,
                  inputFont: inputFont,
                ),

                SizedBox(height: rh(20)),

              
                _buildInputField(
                  controller: _passwordController,
                  icon: Icons.lock_outlined,
                  hint: "Password",
                  fieldH: fieldH,
                  iconSize: iconSize,
                  leftGap: leftGap,
                  betweenGap: betweenGap,
                  rightGap: rightGap,
                  inputFont: inputFont,
                  obscureText: true,
                ),

                SizedBox(height: rh(20)),

               
                _buildInputField(
                  controller: _emailController,
                  icon: Icons.mail_outlined,
                  hint: "Email",
                  fieldH: fieldH,
                  iconSize: iconSize,
                  leftGap: leftGap,
                  betweenGap: betweenGap,
                  rightGap: rightGap,
                  inputFont: inputFont,
                  enabled: false, 
                ),
                SizedBox(height: rh(40)),

Container(
  width: rw(200),
  height: rh(60),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(rw(50)),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFFE3B53C).withOpacity(0.6),
        blurRadius: rw(20),
        spreadRadius: 1,
        offset: const Offset(0, 0),
      ),
    ],
  ),
  child: ElevatedButton(
    onPressed: _isSaving ? null : _updateUserData,
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFE3B53C),
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(rw(50)),
      ),
    ),
    child: _isSaving
        ? const CircularProgressIndicator(
            color: Colors.white,
          )
        : Text(
            "Save",
            style: TextStyle(
              fontSize: _clamp(24, 18, 26),
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
  ),
),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    required double fieldH,
    required double iconSize,
    required double leftGap,
    required double betweenGap,
    required double rightGap,
    required double inputFont,
    bool obscureText = false,
    bool enabled = true,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rw(20)),
      child: SizedBox(
        height: fieldH,
        child: Container(
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
            children: [
              SizedBox(width: leftGap),
              Icon(icon, color: Colors.white70, size: iconSize),
              SizedBox(width: betweenGap),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: inputFont,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  obscureText: obscureText,
                  enabled: enabled,
                ),
              ),
              SizedBox(width: rightGap),
            ],
          ),
        ),
      ),
    );
  }

  double rw(double v) =>
      _clamp(v * (MediaQuery.of(context).size.width / 430.0), v * 0.8, v * 1.3);

}
