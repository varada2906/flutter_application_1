import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final email = emailC.text.trim();
      final pass = passC.text.trim();

      // Sign in with Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );

      final user = userCredential.user;

      setState(() => _loading = false);

      // Redirect based on role or email
      if (user != null) {
        if (email == "admin@smartpune.com") {
          Navigator.pushReplacementNamed(context, '/adminDashboard');
        } else if (email == "driver@smartpune.com") {
          Navigator.pushReplacementNamed(context, '/driver/routeInfo');
        } else {
          Navigator.pushReplacementNamed(context, '/search');
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _loading = false);
      String message = 'Login failed';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red.shade600),
      );
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: $e'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.indigo.shade700;
    final accentColor = Colors.lightBlue.shade400;
    const double iconSize = 50;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // --- Header Section ---
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(60),
                    bottomRight: Radius.circular(60),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_bus_filled,
                          size: 80, color: accentColor),
                      const SizedBox(height: 10),
                      const Text(
                        'Smart Pune Commute',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Your Daily Travel Partner',
                        style:
                            TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Login Form ---
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 30),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Email
                        TextFormField(
                          controller: emailC,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            labelStyle: TextStyle(
                                color: primaryColor.withOpacity(0.8)),
                            prefixIcon:
                                Icon(Icons.email_outlined, color: accentColor),
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: primaryColor, width: 2),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey.shade300, width: 1),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty || !v.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 25),

                        // Password
                        TextFormField(
                          controller: passC,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                                color: primaryColor.withOpacity(0.8)),
                            prefixIcon:
                                Icon(Icons.lock_outline, color: accentColor),
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: primaryColor, width: 2),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey.shade300, width: 1),
                            ),
                          ),
                          obscureText: true,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Enter your password';
                            }
                            return null;
                          },
                        ),

                        // --- Accessibility + Voice Assistant below Password ---
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              iconSize: 36,
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Voice Assistant activated'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.volume_up,
                                  color: Colors.green),
                              tooltip: 'Voice Assistant',
                            ),
                            const SizedBox(width: 24),
                            IconButton(
                              iconSize: iconSize,
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Accessibility features opened'),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.accessibility_new_outlined,
                                color: Colors.grey,
                              ),
                              tooltip: 'Accessibility',
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Login Button
                        SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 8,
                            ),
                            child: _loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  )
                                : const Text(
                                    'LOGIN',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Signup Button
                        SizedBox(
                          height: 55,
                          child: OutlinedButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/signup'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryColor,
                              side: BorderSide(color: primaryColor, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'CREATE ACCOUNT',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
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
}
