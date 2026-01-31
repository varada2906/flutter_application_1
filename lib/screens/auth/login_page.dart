import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final emailC = TextEditingController();
  final passC = TextEditingController();
  final nameC = TextEditingController();
  final phoneC = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLogin = true;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _resetLoading = false;

  final Color primaryBlue = const Color(0xFF0D47A1);
  final Color secondaryBlue = const Color(0xFF002171);
  final Color lightBg = const Color(0xFFE3F2FD);

  // ================= SAVE USER TO FIRESTORE =================
  Future<void> _saveUserToFirestore(User user, {String? name, String? phone}) async {
    final ref = _firestore.collection("users").doc(user.uid);
    final userData = {
      "uid": user.uid,
      "email": user.email,
      "name": name ?? "User",
      "phone": phone ?? "",
      "role": user.email == "admin@smartpune.com"
          ? "admin"
          : user.email == "driver@smartpune.com"
              ? "driver"
              : "user",
      "createdAt": FieldValue.serverTimestamp(),
      "lastLogin": FieldValue.serverTimestamp(),
      "status": "active",
    };
    final doc = await ref.get();
    if (!doc.exists) {
      await ref.set(userData);
    } else {
      await ref.update({"lastLogin": FieldValue.serverTimestamp()});
    }
  }

  // ================= SIGN UP =================
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailC.text.trim(),
        password: passC.text.trim(),
      );
      final user = userCredential.user;
      if (user != null) {
        await _saveUserToFirestore(user, name: nameC.text.trim(), phone: phoneC.text.trim());
        await _sendWelcomeNotification(emailC.text.trim(), nameC.text.trim());
      }
      setState(() => _loading = false);
      _showSnackBar('Account created successfully!', isError: false);
      _navigateBasedOnRole(emailC.text.trim());
    } on FirebaseAuthException catch (e) {
      setState(() => _loading = false);
      _showSnackBar(e.message ?? 'Sign up failed', isError: true);
    } catch (e) {
      setState(() => _loading = false);
      _showSnackBar('Something went wrong', isError: true);
    }
  }

  // ================= LOGIN =================
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailC.text.trim(),
        password: passC.text.trim(),
      );
      if (userCredential.user != null) await _saveUserToFirestore(userCredential.user!);
      setState(() => _loading = false);
      _navigateBasedOnRole(emailC.text.trim());
    } on FirebaseAuthException catch (e) {
      setState(() => _loading = false);
      _showSnackBar(e.message ?? 'Login failed', isError: true);
    } catch (e) {
      setState(() => _loading = false);
      _showSnackBar('Something went wrong', isError: true);
    }
  }

  void _navigateBasedOnRole(String email) {
    if (email == "admin@smartpune.com") {
      Navigator.pushReplacementNamed(context, '/adminDashboard');
    } else if (email == "driver@smartpune.com") {
      Navigator.pushReplacementNamed(context, '/driver/routeInfo');
    } else {
      Navigator.pushReplacementNamed(context, '/search');
    }
  }

  Future<void> _sendWelcomeNotification(String email, String name) async {
    try {
      await _firestore.collection("notifications").add({
        "type": "new_user",
        "email": email,
        "name": name,
        "timestamp": FieldValue.serverTimestamp(),
        "read": false,
      });
    } catch (e) { print(e); }
  }

  Future<void> _forgotPassword() async {
    final email = await showDialog<String>(context: context, builder: (_) => ForgotPasswordDialog());
    if (email == null || email.isEmpty) return;
    setState(() => _resetLoading = true);
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showSnackBar('Password reset email sent');
    } catch (e) {
      _showSnackBar('Error sending email', isError: true);
    } finally {
      setState(() => _resetLoading = false);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700),
    );
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _formKey.currentState?.reset();
      emailC.clear(); passC.clear(); nameC.clear(); phoneC.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryBlue,
      body: SingleChildScrollView(
        // Constrain the content to at least the height of the screen
        child: Column(
          children: [
            // --- TOP HEADER ---
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: lightBg,
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(80)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_bus, size: 35, color: primaryBlue),
                      Icon(Icons.more_horiz, color: primaryBlue.withOpacity(0.5)),
                      Icon(Icons.directions_railway, size: 45, color: primaryBlue),
                      Icon(Icons.more_horiz, color: primaryBlue.withOpacity(0.5)),
                      Icon(Icons.directions_bike, size: 35, color: primaryBlue),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Smart Pune Commute",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26, 
                      fontWeight: FontWeight.bold, 
                      color: Color(0xFF002171),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),

            // --- BOTTOM FORM AREA ---
            Container(
              color: lightBg,
              child: Container(
                // Use constraints to prevent overflow while allowing scrolling
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                padding: const EdgeInsets.fromLTRB(30, 40, 30, 40),
                decoration: BoxDecoration(
                  color: secondaryBlue,
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(80)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _isLogin ? "Welcome Back" : "Register New Account",
                          style: const TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      if (!_isLogin) ...[
                        _buildLabel("First Name"),
                        _buildTextField(nameC, "John", Icons.person_outline),
                        const SizedBox(height: 15),
                        _buildLabel("Phone Number"),
                        _buildTextField(phoneC, "9876543210", Icons.phone_android),
                        const SizedBox(height: 15),
                      ],
                      _buildLabel("Email"),
                      _buildTextField(emailC, "johndoe@xyz.com", Icons.email_outlined),
                      const SizedBox(height: 15),
                      _buildLabel("Password"),
                      _buildTextField(passC, "********", Icons.lock_outline, isPass: true),
                      
                      const SizedBox(height: 5),
                      if(_isLogin) Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _forgotPassword,
                          child: const Text("Forgot password?", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // SUBMIT BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: secondaryBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _loading ? null : (_isLogin ? _login : _signUp),
                          child: _loading 
                            ? CircularProgressIndicator(color: secondaryBlue) 
                            : Text(_isLogin ? "Log In" : "Sign Up", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),

                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_isLogin ? "Don't have an account? " : "Already have an account? ",
                            style: const TextStyle(color: Colors.white70)),
                          GestureDetector(
                            onTap: _toggleMode,
                            child: Text(_isLogin ? "Sign Up" : "Sign In", 
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      // Extra space at bottom to ensure scrolling works well with keyboard
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Align(
    alignment: Alignment.centerLeft, 
    child: Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 5),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
    )
  );

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPass = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPass ? _obscurePassword : false,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: primaryBlue),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        suffixIcon: isPass ? IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ) : null,
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (v) => v == null || v.isEmpty ? "Required field" : null,
    );
  }
}

class ForgotPasswordDialog extends StatefulWidget {
  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final emailC = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Reset Password"),
      content: TextField(
        controller: emailC,
        decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(onPressed: () => Navigator.pop(context, emailC.text.trim()), child: const Text("Send Reset Link")),
      ],
    );
  }
}