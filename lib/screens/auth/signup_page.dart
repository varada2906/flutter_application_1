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
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (passC.text != confirmPassC.text) {
      _showSnackBar('Passwords do not match', isError: true);
      return;
    }

    setState(() => _loading = true);

    try {
      await _auth.createUserWithEmailAndPassword(
        email: emailC.text.trim(),
        password: passC.text.trim(),
      );

      setState(() => _loading = false);

      _showSnackBar('Signup successful! Please log in.', isError: false);

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

      _showSnackBar(errorMsg, isError: true);
    } catch (e) {
      setState(() => _loading = false);
      _showSnackBar('Unexpected error: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
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
    final darkBlue = const Color(0xFF0A192F); // Dark blue primary
    final lightBlue = const Color(0xFF64FFDA); // Teal accent
    final blueAccent = const Color(0xFF1E88E5); // Light blue
    final cardColor = const Color(0xFF112240); // Slightly lighter dark blue

    return Scaffold(
      backgroundColor: darkBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // --- Header with Gradient ---
              Container(
                height: 280,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      darkBlue,
                      const Color(0xFF112240),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative elements
                    Positioned(
                      top: 20,
                      right: 30,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: lightBlue.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 30,
                      left: 30,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: blueAccent.withOpacity(0.1),
                        ),
                      ),
                    ),
                    
                    // Main content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Transportation Composite Logo
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: lightBlue.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Main person icon for signup
                                Icon(
                                  Icons.person_add,
                                  size: 50,
                                  color: lightBlue,
                                ),
                                // Small transport icons around
                                Positioned(
                                  top: 15,
                                  left: 20,
                                  child: Icon(
                                    Icons.directions_bus,
                                    size: 18,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                Positioned(
                                  top: 15,
                                  right: 20,
                                  child: Icon(
                                    Icons.train,
                                    size: 18,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                Positioned(
                                  bottom: 15,
                                  left: 20,
                                  child: Icon(
                                    Icons.directions_car,
                                    size: 18,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                Positioned(
                                  bottom: 15,
                                  right: 20,
                                  child: Icon(
                                    Icons.pedal_bike,
                                    size: 18,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Join Smart Pune Commute',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.7),
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --- Sign Up Form ---
              Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Card(
                    elevation: 0,
                    color: cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Welcome text
                            const Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Create an account to access all transport options',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Transport Icons Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _TransportTypeIcon(icon: Icons.directions_bus, label: 'Bus'),
                                const SizedBox(width: 20),
                                _TransportTypeIcon(icon: Icons.train, label: 'Train'),
                                const SizedBox(width: 20),
                                _TransportTypeIcon(icon: Icons.directions_car, label: 'Car'),
                                const SizedBox(width: 20),
                                _TransportTypeIcon(icon: Icons.pedal_bike, label: 'Bike'),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // Email Field
                            TextFormField(
                              controller: emailC,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                                labelStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                                hintText: 'your@email.com',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                ),
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: lightBlue,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: lightBlue,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.05),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.isEmpty || !v.contains('@')) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Password Field
                            TextFormField(
                              controller: passC,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: lightBlue,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: lightBlue,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.05),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (v.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Confirm Password Field
                            TextFormField(
                              controller: confirmPassC,
                              obscureText: _obscureConfirmPassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                labelStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_reset_outlined,
                                  color: lightBlue,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: lightBlue,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.05),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (v != passC.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 28),

                            // Sign Up Button
                            SizedBox(
                              height: 58,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: lightBlue,
                                  foregroundColor: darkBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 6,
                                  shadowColor: lightBlue.withOpacity(0.5),
                                ),
                                child: _loading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.black,
                                          strokeWidth: 3,
                                        ),
                                      )
                                    : const Text(
                                        'CREATE ACCOUNT',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Divider with "or"
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.white.withOpacity(0.2),
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'ALREADY HAVE AN ACCOUNT?',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.white.withOpacity(0.2),
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Back to Login Button
                            SizedBox(
                              height: 58,
                              child: OutlinedButton(
                                onPressed: _loading ? null : () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: lightBlue,
                                  side: BorderSide(
                                    color: lightBlue,
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  backgroundColor: Colors.transparent,
                                ),
                                child: const Text(
                                  'BACK TO LOGIN',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Terms and Privacy Notice
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(
                                'By creating an account, you agree to our Terms of Service and Privacy Policy',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom decorative wave
              Container(
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: darkBlue,
                ),
                child: CustomPaint(
                  painter: _WavePainter(color: cardColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Transport Type Icon Widget (same as LoginPage)
class _TransportTypeIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  
  const _TransportTypeIcon({
    Key? key,
    required this.icon,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF64FFDA).withOpacity(0.3),
            ),
          ),
          child: Icon(
            icon,
            size: 22,
            color: const Color(0xFF64FFDA),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// Custom wave painter for bottom decoration (same as LoginPage)
class _WavePainter extends CustomPainter {
  final Color color;
  
  _WavePainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.25, size.height * 0.5,
      size.width * 0.5, size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 0.9,
      size.width, size.height * 0.7,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}