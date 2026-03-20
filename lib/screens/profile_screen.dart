import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
// Import your existing FeedbackScreen
import 'feedback_screen.dart'; // Make sure the path is correct

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

        // Update user profile in Firestore with image URL if needed
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'profileImageUrl': downloadUrl,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

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

      // Update Firestore to remove image URL
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'profileImageUrl': FieldValue.delete(),
      });

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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login', // Your login route name
                  (route) => false,
                );
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
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

  // --------------------------- TICKET HISTORY FUNCTION ----------------------------
  void _viewTicketHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketHistoryScreen(userEmail: user.email!),
      ),
    );
  }

  // --------------------------- CONTACT US FUNCTION ----------------------------
  void _openContactUs() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ContactUsScreen(),
      ),
    );
  }

  // --------------------------- FEEDBACK FUNCTION ----------------------------
  void _openFeedback() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeedbackScreen(), // Using your existing FeedbackScreen
      ),
    ).then((_) {
      // This callback runs when you return from FeedbackScreen
      // You can add any refresh logic here if needed
    });
  }

  // --------------------------- HELPDESK FUNCTION ----------------------------
  void _openHelpdesk() {
    // You can implement this later
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Helpdesk screen coming soon!")),
    );
  }

  // --------------------------- SETTINGS FUNCTION ----------------------------
  void _openSettings() {
    // You can implement this later
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Settings screen coming soon!")),
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
               
                // Ticket History
                _buildMenuItem(
                  icon: Icons.history,
                  title: 'Ticket History',
                  onTap: _viewTicketHistory,
                  trailing: _tag("View All", Colors.green.shade700),
                ),
              
                // Contact Us
                _buildMenuItem(
                  icon: Icons.call_outlined,
                  title: 'Contact Us',
                  onTap: _openContactUs,
                ),

                // Feedback - Now properly connected to your existing FeedbackScreen
                _buildMenuItem(
                  icon: Icons.feedback_outlined,
                  title: 'Feedback',
                  onTap: _openFeedback,
                ),


                const Divider(height: 1),
                
                // Logout
                _buildMenuItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: logout,
                  trailing: _tag("Sign Out", Colors.red),
                ),

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
              // Avatar with Image Upload Functionality
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
                  // Firebase Username
                  Text(
                    user.email!.split('@')[0],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  // Firebase Email
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

// --------------------------- CONTACT US SCREEN ----------------------------
class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch phone dialer';
    }
  }

  Future<void> _launchEmail(String email, {String subject = '', String body = ''}) async {
    final Uri uri = Uri.parse('mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch email app';
    }
  }

  Future<void> _launchSMS(String phone, {String message = ''}) async {
    final Uri uri = Uri.parse('sms:$phone?body=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch SMS app';
    }
  }

  Future<void> _openMap() async {
    final Uri uri = Uri.parse('https://maps.google.com/?q=Pune+Maharashtra+India');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openWhatsApp({String phone = '919876543210', String message = ''}) async {
    final Uri uri = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch WhatsApp';
    }
  }

  void _showQuickFeedbackDialog(BuildContext context) {
    final TextEditingController feedbackController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quick Feedback'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Your Email',
                    hintText: 'Enter your email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: feedbackController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Your Feedback',
                    hintText: 'Tell us what you think...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (feedbackController.text.isNotEmpty) {
                  // Save feedback to Firestore
                  try {
                    User? user = FirebaseAuth.instance.currentUser;
                    await FirebaseFirestore.instance.collection('quick_feedback').add({
                      'userEmail': emailController.text.isNotEmpty ? emailController.text : (user?.email ?? 'Anonymous'),
                      'userId': user?.uid ?? 'guest',
                      'feedback': feedbackController.text,
                      'timestamp': FieldValue.serverTimestamp(),
                      'source': 'Contact Us Quick Feedback',
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Thank you for your feedback!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Image/Banner
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade400, Colors.teal.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.support_agent,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'We\'re Here to Help',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Actions Row
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickActionButton(
                        icon: Icons.phone,
                        label: 'Call',
                        color: Colors.green,
                        onTap: () => _launchPhone('18001234567'),
                      ),
                      _buildQuickActionButton(
                        icon: Icons.email,
                        label: 'Email',
                        color: Colors.blue,
                        onTap: () => _launchEmail(
                          'support@varadaapp.com',
                          subject: 'Support Request from App',
                          body: 'User: ${FirebaseAuth.instance.currentUser?.email ?? 'Guest'}\n\n',
                        ),
                      ),
                      _buildQuickActionButton(
                        icon: Icons.message,
                        label: 'SMS',
                        color: Colors.purple,
                        onTap: () => _launchSMS(
                          '9876543210',
                          message: 'Hello, I need help with the app.',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickActionButton(
                        icon: Icons.chat,
                        label: 'WhatsApp',
                        color: Colors.green.shade800,
                        onTap: () => _openWhatsApp(
                          phone: '919876543210',
                          message: 'Hello, I need help with the Varada App.',
                        ),
                      ),
                      _buildQuickActionButton(
                        icon: Icons.location_on,
                        label: 'Office',
                        color: Colors.red,
                        onTap: _openMap,
                      ),
                      _buildQuickActionButton(
                        icon: Icons.feedback,
                        label: 'Quick Feedback',
                        color: Colors.orange,
                        onTap: () => _showQuickFeedbackDialog(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Customer Support Section
                  _buildContactSection(
                    title: 'Customer Support',
                    icon: Icons.headset_mic,
                    children: [
                      _buildContactItem(
                        icon: Icons.phone,
                        title: 'Toll Free',
                        subtitle: '1800-123-4567',
                        trailing: '24/7 Available',
                        onTap: () => _launchPhone('18001234567'),
                      ),
                      _buildContactItem(
                        icon: Icons.email,
                        title: 'Email Support',
                        subtitle: 'support@varadaapp.com',
                        trailing: '24hr Response',
                        onTap: () => _launchEmail('support@varadaapp.com'),
                      ),
                      _buildContactItem(
                        icon: Icons.access_time,
                        title: 'Working Hours',
                        subtitle: 'Monday - Sunday',
                        trailing: '24/7',
                        onTap: null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Office Address Section
                  _buildContactSection(
                    title: 'Office Address',
                    icon: Icons.location_city,
                    children: [
                      _buildContactItem(
                        icon: Icons.location_on,
                        title: 'Head Office',
                        subtitle: '123 Business Park, MG Road, Pune - 411001',
                        trailing: 'Get Directions',
                        onTap: _openMap,
                      ),
                      _buildContactItem(
                        icon: Icons.access_time,
                        title: 'Office Hours',
                        subtitle: 'Monday - Friday',
                        trailing: '9:00 AM - 6:00 PM',
                        onTap: null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                 
                

                  // Emergency Contacts
                  _buildContactSection(
                    title: 'Emergency Contacts',
                    icon: Icons.warning,
                    children: [
                      _buildContactItem(
                        icon: Icons.local_police,
                        title: 'Police Helpline',
                        subtitle: 'For emergencies',
                        trailing: '100',
                        onTap: () => _launchPhone('100'),
                      ),
                      _buildContactItem(
                        icon: Icons.local_hospital,
                        title: 'Ambulance',
                        subtitle: 'Medical emergency',
                        trailing: '108',
                        onTap: () => _launchPhone('108'),
                      ),
                      _buildContactItem(
                        icon: Icons.fire_truck,
                        title: 'Fire Brigade',
                        subtitle: 'Fire emergency',
                        trailing: '101',
                        onTap: () => _launchPhone('101'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // FAQ Section
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.help, color: Colors.teal),
                              SizedBox(width: 8),
                              Text(
                                'Frequently Asked Questions',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildFAQItem(
                            question: 'How do I book a bus pass?',
                            answer: 'Go to the home screen, select your route, choose pass type, and complete payment.',
                          ),
                          _buildFAQItem(
                            question: 'How can I cancel my booking?',
                            answer: 'Visit Ticket History in your profile and select the ticket you want to cancel.',
                          ),
                          _buildFAQItem(
                            question: 'What payment methods are accepted?',
                            answer: 'We accept all major credit/debit cards, UPI, net banking, and wallets.',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Send Message Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchEmail(
                        'support@varadaapp.com',
                        subject: 'Support Request',
                        body: 'User: ${FirebaseAuth.instance.currentUser?.email ?? 'Guest'}\n\n',
                      ),
                      icon: const Icon(Icons.send, color: Colors.white),
                      label: const Text(
                        'Send us a Message',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // App Version
                  Center(
                    child: Text(
                      'App Version 1.0.0',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 25),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.teal, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    String? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.teal.shade50,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: Colors.teal),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: trailing != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: onTap != null ? Colors.teal.shade50 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                trailing,
                style: TextStyle(
                  color: onTap != null ? Colors.teal : Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• $question',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '  $answer',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// Ticket History Screen
class TicketHistoryScreen extends StatelessWidget {
  final String userEmail;

  const TicketHistoryScreen({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket History'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tickets')
            .where('userEmail', isEqualTo: userEmail)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tickets booked yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Book your first bus pass!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var ticket = snapshot.data!.docs[index];
              var data = ticket.data() as Map<String, dynamic>;
              
              // Format timestamp
              String dateTime = 'Just now';
              if (data['timestamp'] != null) {
                Timestamp timestamp = data['timestamp'] as Timestamp;
                DateTime date = timestamp.toDate();
                dateTime = DateFormat('dd MMM yyyy, hh:mm a').format(date);
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        Colors.teal.shade50,
                        Colors.white,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: _getPassTypeColor(data['passType'] ?? 'Regular').withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                data['passType'] ?? 'Regular',
                                style: TextStyle(
                                  color: _getPassTypeColor(data['passType'] ?? 'Regular'),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: data['status'] == 'Active' 
                                    ? Colors.green.shade50 
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: data['status'] == 'Active' 
                                        ? Colors.green 
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    data['status'] ?? 'Active',
                                    style: TextStyle(
                                      color: data['status'] == 'Active' 
                                          ? Colors.green.shade700 
                                          : Colors.grey.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          data['busName'] ?? 'Bus',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Payment ID: ${data['paymentId'] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Amount Paid',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '₹${data['price'] ?? '0.00'}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Booked On',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dateTime,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  Color _getPassTypeColor(String passType) {
    switch (passType.toLowerCase()) {
      case 'student':
        return Colors.green;
      case 'senior':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}