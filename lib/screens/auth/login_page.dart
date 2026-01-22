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
  bool _obscurePassword = true;
  bool _resetLoading = false;

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
      _showSnackBar(message, isError: true);
    } catch (e) {
      setState(() => _loading = false);
      _showSnackBar('An unexpected error occurred: $e', isError: true);
    }
  }

  // Forgot Password Function
  Future<void> _forgotPassword() async {
    // Show dialog for email input
    final email = await showDialog<String>(
      context: context,
      builder: (context) => ForgotPasswordDialog(),
    );

    if (email == null || email.isEmpty) return;

    setState(() => _resetLoading = true);

    try {
      await _auth.sendPasswordResetEmail(email: email);
      setState(() => _resetLoading = false);
      _showSnackBar(
        'Password reset email sent! Check your inbox.',
        isError: false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _resetLoading = false);
      String message = 'Failed to send reset email';
      if (e.code == 'user-not-found') {
        message = 'No account found with this email';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address';
      } else if (e.code == 'network-request-failed') {
        message = 'Network error. Please check your connection';
      }
      _showSnackBar(message, isError: true);
    } catch (e) {
      setState(() => _resetLoading = false);
      _showSnackBar('Error: $e', isError: true);
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
                                // Main map/route icon
                                Icon(
                                  Icons.route,
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
                            'Smart Pune Commute',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your Complete Travel Hub',
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

              // --- Login Form ---
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
                              'Welcome Back',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Sign in to access all transport options',
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
                            const SizedBox(height: 8),

                            // Forgot Password Button
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: _resetLoading ? null : _forgotPassword,
                                style: TextButton.styleFrom(
                                  foregroundColor: lightBlue,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                icon: _resetLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF64FFDA),
                                        ),
                                      )
                                    : const Icon(Icons.lock_reset, size: 16),
                                label: Text(
                                  _resetLoading ? 'Sending...' : 'Forgot Password?',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Login Button
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
                                        'SIGN IN',
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
                                    'OR',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontWeight: FontWeight.w500,
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

                            // Create Account Button
                            SizedBox(
                              height: 58,
                              child: OutlinedButton(
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/signup'),
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
                                  'CREATE NEW ACCOUNT',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            
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

// Forgot Password Dialog
class ForgotPasswordDialog extends StatefulWidget {
  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF112240),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: const Color(0xFF64FFDA).withOpacity(0.3),
          width: 1,
        ),
      ),
      title: Row(
        children: [
          Icon(Icons.lock_reset, color: const Color(0xFF64FFDA)),
          const SizedBox(width: 12),
          Text(
            'Reset Password',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  labelStyle: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                  ),
                  prefixIcon: Icon(Icons.email, color: const Color(0xFF64FFDA)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty || !v.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white.withOpacity(0.7),
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _emailController.text.trim());
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF64FFDA),
            foregroundColor: const Color(0xFF0A192F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Send Reset Link'),
        ),
      ],
    );
  }
}

// Transport Type Icon Widget
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

// Custom wave painter for bottom decoration
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