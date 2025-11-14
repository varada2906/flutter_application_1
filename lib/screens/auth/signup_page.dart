import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final confirmPassC = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (passC.text != confirmPassC.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // Create user in Firebase
      await _auth.createUserWithEmailAndPassword(
        email: emailC.text.trim(),
        password: passC.text.trim(),
      );

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signup successful! Please log in.')),
      );

      Navigator.pop(context); // Go back to Login
    } on FirebaseAuthException catch (e) {
      setState(() => _loading = false);

      String errorMsg = 'Signup failed. Please try again.';

      if (e.code == 'email-already-in-use') {
        errorMsg = 'This email is already registered.';
      } else if (e.code == 'invalid-email') {
        errorMsg = 'Invalid email address.';
      } else if (e.code == 'weak-password') {
        errorMsg = 'Password must be at least 6 characters.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red.shade600),
      );
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error: $e'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  @override
  void dispose() {
    emailC.dispose();
    passC.dispose();
    confirmPassC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define colors to match LoginPage's theme
    final primaryColor = Colors.indigo.shade700;
    final accentColor = Colors.lightBlue.shade400;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // --- Header Section (Matching LoginPage) ---
              Container(
                height: 250, // Slightly shorter header for sign up
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
                          size: 70, color: accentColor),
                      const SizedBox(height: 10),
                      const Text(
                        'Create Account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Join Smart Pune Commute',
                        style:
                            TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Sign Up Form ---
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
                          'Secure Signup',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 25),
                        
                        // Email Field
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

                        // Password Field
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
                            if (v == null || v.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 25),

                        // Confirm Password Field
                        TextFormField(
                          controller: confirmPassC,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
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
                              return 'Please confirm your password';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 30),

                        // Sign Up Button
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
                                    'SIGN UP',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Back to Login Button
                        SizedBox(
                          height: 55,
                          child: OutlinedButton(
                            onPressed: _loading ? null : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryColor,
                              side: BorderSide(color: primaryColor, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'BACK TO LOGIN',
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