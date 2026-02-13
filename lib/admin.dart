import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
  _tabController = TabController(length: 2, vsync: this);

  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
          
     
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Admin Panel",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),

                    ],
                  ),
                ),

          
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFDAB659), Color(0xFFB8941E)],
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: "Registered Users"),
                      Tab(text: "Add Artist"),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

             
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      _RegisteredUsersTab(),
                       _AddArtistTab(),
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
}


class _RegisteredUsersTab extends StatefulWidget {
  const _RegisteredUsersTab();

  @override
  State<_RegisteredUsersTab> createState() => _RegisteredUsersTabState();
}

class _RegisteredUsersTabState extends State<_RegisteredUsersTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection("users").orderBy("createdAt", descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFDAB659)));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No users found.",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final users = snapshot.data!.docs;

        int activeCount = users.where((u) => u["role"] == "user").length;

        return Column(
          children: [
         
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Users: ${users.length}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Active: $activeCount",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final joinDate = user["createdAt"] != null
                      ? (user["createdAt"] as Timestamp).toDate()
                      : DateTime.now();

                  return _UserCard(
                    name: user["name"] ?? "Unknown",
                    email: user["email"] ?? "Unknown",
                    joinDate: "${joinDate.day}-${joinDate.month}-${joinDate.year}",
                    onDelete: () => _deleteUser(user.id, user["name"] ?? "User"),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(String docId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2a1a3a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text("Delete User", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          "Are you sure you want to delete '$name'? This will remove their account permanently.",
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firestore.collection("users").doc(docId).delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("$name deleted successfully!"),
                    backgroundColor: Colors.red,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Failed to delete $name: $e"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final String name;
  final String email;
  final String joinDate;
  final VoidCallback onDelete;

  const _UserCard({
    required this.name,
    required this.email,
    required this.joinDate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFDAB659).withOpacity(0.7),
                  const Color(0xFFDAB659).withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(email, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                const SizedBox(height: 4),
                Text("Joined: $joinDate", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
              ],
            ),
          ),

         
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
    );
  }
  }

class _AddArtistTab extends StatefulWidget {
  const _AddArtistTab();

  @override
  State<_AddArtistTab> createState() => _AddArtistTabState();
}

class _AddArtistTabState extends State<_AddArtistTab> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _imageController = TextEditingController();

  bool _isLoading = false;

  Future<void> _addArtist() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _firestore.collection("artists").add({
        "name": _nameController.text.trim(),
        "image": _imageController.text.trim(),
        "createdAt": FieldValue.serverTimestamp(),
      });

      _nameController.clear();
   
      _imageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Artist added successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to add artist: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Add New Artist",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: _nameController,
                label: "Artist Name",
                icon: Icons.person,
              ),

              const SizedBox(height: 12),

        

              _buildTextField(
                controller: _imageController,
                label: "Image URL (optional)",
                icon: Icons.image,
                required: false,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addArtist,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDAB659),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          "Add Artist",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      validator: required
          ? (value) => value == null || value.isEmpty ? "Required field" : null
          : null,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFFDAB659)),
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        filled: true,
        fillColor: Colors.black.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
