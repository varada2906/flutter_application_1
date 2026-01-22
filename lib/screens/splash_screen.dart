// import 'package:flutter/material.dart';

// class SplashScreen extends StatefulWidget {
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(Duration(seconds: 2), () {
//       Navigator.pushReplacementNamed(context, '/login');
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 115, 162, 202),
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.directions_bus_filled, size: 96, color: Colors.white),
//             SizedBox(height: 24),
//             Text(
//               "The Best App for\nBooking Bus Tickets",
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 24,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/screens/auth/login_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Hide status bar for true fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    Future.delayed(const Duration(seconds: 7), () {
      if (mounted) {
        // Restore status bar
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Transportation-themed background
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?q=80&w=2069&auto=format&fit=crop',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),

          // Centered main content
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 25,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Transport icons - FIXED: Wrap in SingleChildScrollView for horizontal scrolling if needed
                      SizedBox(
                        height: 60,
                        child: ListView(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          children: const [
                            SizedBox(width: 8),
                            _TransportIcon(icon: Icons.directions_bus),
                            SizedBox(width: 12),
                            _TransportIcon(icon: Icons.train),
                            SizedBox(width: 12),
                            _TransportIcon(icon: Icons.directions_car),
                            SizedBox(width: 12),
                            _TransportIcon(icon: Icons.motorcycle),
                            SizedBox(width: 12),
                            _TransportIcon(icon: Icons.directions_bike),
                            SizedBox(width: 8),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // App Name/Logo
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.cyan.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                        ),
                        child: Text(
                          "PUNE TRAVEL HUB",
                          style: TextStyle(
                            color: Colors.cyan[100],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Main Title
                      Text(
                        "Smart Pune\nCommute",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // App Description
                      Text(
                        "All-in-One Transport\nTicket & Travel App",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Location with icon
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.cyan[200],
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Pune, Maharashtra",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
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

          // Loading indicator at bottom
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.cyan.withOpacity(0.8),
                    ),
                    backgroundColor: Colors.white.withOpacity(0.2),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Loading...",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
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

// Alternative: Smaller transport icons with Wrap widget
class _TransportIcon extends StatelessWidget {
  final IconData icon;
  
  const _TransportIcon({
    Key? key,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.cyan.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyan.withOpacity(0.3)),
      ),
      child: Icon(
        icon,
        color: Colors.cyan[200],
        size: 22, // Reduced size
      ),
    );
  }
}
