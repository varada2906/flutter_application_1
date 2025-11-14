import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool accessibilityMode = false;

  // Firebase User
  late User user;

  // Razorpay
  late Razorpay razorpay;

  // Profile Image
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();

    // Get Firebase user
    user = FirebaseAuth.instance.currentUser!;

    // Initialize Razorpay
    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);

    // Load existing profile picture if available
    _loadProfilePicture();
  }

  // --------------------------- PROFILE PICTURE FUNCTIONS ----------------------------
  
  void _loadProfilePicture() async {
    // Check if user has a profile picture in Firebase Storage
    try {
      final ref = FirebaseStorage.instance.ref().child('profile_pictures/${user.uid}.jpg');
      final url = await ref.getDownloadURL();
      
      // Download and cache the image
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();
      final bytes = await response.fold<List<int>>(<int>[], (List<int> accumulator, List<int> element) {
        accumulator.addAll(element);
        return accumulator;
      });
      
      setState(() {
        _profileImage = File.fromRawPath(bytes as Uint8List);
      });
    } catch (e) {
      // No existing profile picture found, use default avatar
      print('No existing profile picture: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _isUploading = true;
        });

        // Upload to Firebase Storage
        final File imageFile = File(pickedFile.path);
        final String fileName = '${user.uid}.jpg';
        final Reference storageRef = FirebaseStorage.instance.ref().child('profile_pictures/$fileName');
        
        final UploadTask uploadTask = storageRef.putFile(imageFile);
        final TaskSnapshot snapshot = await uploadTask;
        final String downloadUrl = await snapshot.ref.getDownloadURL();

        setState(() {
          _profileImage = imageFile;
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Profile picture updated!")),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to upload image: $e")),
      );
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Profile Picture'),
          content: const Text('Choose an option'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt),
                  SizedBox(width: 8),
                  Text('Camera'),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.photo_library),
                  SizedBox(width: 8),
                  Text('Gallery'),
                ],
              ),
            ),
            if (_profileImage != null)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _removeProfilePicture();
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Remove', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _removeProfilePicture() async {
    try {
      setState(() {
        _isUploading = true;
      });

      // Delete from Firebase Storage
      final Reference storageRef = FirebaseStorage.instance.ref().child('profile_pictures/${user.uid}.jpg');
      await storageRef.delete();

      setState(() {
        _profileImage = null;
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Profile picture removed!")),
      );
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to remove picture: $e")),
      );
    }
  }

  // --------------------------- LOGOUT FUNCTION ----------------------------
  void logout() async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login', // Your login route name
      (route) => false,
    );
  }

  // ------------------------------------------------------------------------

  void handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ Payment Successful! ID: ${response.paymentId}")),
    );
  }

  void handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Payment Failed: ${response.message}")),
    );
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("🌐 External Wallet: ${response.walletName}")),
    );
  }

  void openCheckout() {
    var options = {
      'key': 'rzp_test_RcTdRnmVYAlF4h',
      'amount': 2000,
      'name': 'Varada App',
      'description': 'Profile Top-up',
      'prefill': {
        'contact': '9876543210',
        'email': user.email,
      }
    };

    try {
      razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment gateway failed to open.")),
      );
    }
  }

  void openChatbot() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("🤖 Opening Chatbot...")),
    );
  }

  @override
  void dispose() {
    razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
     
      body: Column(
        children: [
          _buildModernProfileHeader(context),
          _buildStatsCard(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildMenuItem(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Wallet / Make Payment',
                  onTap: openCheckout,
                  trailing: _tag("Pay Now", Colors.blue.shade700),
                ),
                const Divider(height: 1),
               
                
                
                _buildMenuItem(
                  icon: Icons.history,
                  title: 'Ticket History',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.card_giftcard,
                  title: 'My Rewards',
                  trailing: _tag("Coming Soon", Colors.orange),
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.share_location,
                  title: 'Share My Location',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.language,
                  title: 'Change Language',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.call_outlined,
                  title: 'Contact Us',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.feedback_outlined,
                  title: 'Feedback',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.help_outline,
                  title: 'Helpdesk / Grievance Redressal',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {},
                ),

                // ------------------------- LOGOUT BUTTON -------------------------
                const Divider(height: 1),
                _buildMenuItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: logout,
                  trailing: _tag("Sign Out", Colors.red),
                ),
                // -----------------------------------------------------------------

                // _buildAccessibilitySwitch(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 40, bottom: 20, left: 16, right: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade500, Colors.teal.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BackButton(color: Colors.white),
              Icon(Icons.settings, color: Colors.white),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Updated Avatar with Image Upload Functionality
              GestureDetector(
                onTap: _showImagePickerDialog,
                child: Stack(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: _isUploading
                          ? const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.white,
                              backgroundImage: _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : null,
                              child: _profileImage == null
                                  ? const Icon(Icons.person, color: Colors.teal, size: 40)
                                  : null,
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✔ Firebase Username
                  Text(
                    user.email!.split('@')[0],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  // ✔ Firebase Email
                  Text(
                    user.email!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('51', 'Balance', Icons.star, Colors.yellow.shade700),
            Container(width: 1, height: 40, color: Colors.grey.shade300),
            _buildStatItem('1', 'Level', Icons.emoji_events, Colors.amber.shade700),
            Container(width: 1, height: 40, color: Colors.grey.shade300),
            _buildStatItem('30', 'Total XP', Icons.flash_on, Colors.yellow.shade700),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color iconColor) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade700),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) trailing,
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}