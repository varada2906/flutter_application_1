import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccessibilityModeListScreen extends StatefulWidget {
  const AccessibilityModeListScreen({super.key});

  @override
  State<AccessibilityModeListScreen> createState() => _AccessibilityModeListScreenState();
}

class _AccessibilityModeListScreenState extends State<AccessibilityModeListScreen> with SingleTickerProviderStateMixin {
  late Razorpay razorpay;
  late TabController _tabController;  
  
  String _currentBusName = "";
  String _currentPrice = "";
  String _currentPassType = "";
  
  String get _userEmail => FirebaseAuth.instance.currentUser?.email ?? 'varadakorlahalli@gmail.com';

  @override
  void initState() {
    super.initState();
    
    print("🚀 AccessibilityModeListScreen initialized");
    _tabController = TabController(length: 4, vsync: this);
    
    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("💰 Payment Success: ${response.paymentId}");
    try {
      await FirebaseFirestore.instance.collection('tickets').add({
        'busName': _currentBusName,
        'price': _currentPrice,
        'passType': _currentPassType,
        'userEmail': _userEmail,
        'paymentId': response.paymentId,
        'status': 'Active',
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      // Ticket विकला गेल्यावर त्याची count वाढवा
      await FirebaseFirestore.instance
          .collection('busList')
          .where('name', isEqualTo: _currentBusName)
          .where('passType', isEqualTo: _currentPassType)
          .get()
          .then((snapshot) {
            if (snapshot.docs.isNotEmpty) {
              snapshot.docs.first.reference.update({
                'bookedCount': FieldValue.increment(1)
              });
              print("📊 Booked count updated for $_currentBusName");
            }
          });
      
      if (mounted) {
        _showStyledSnackBar("Ticket Booked Successfully!", Colors.green);
      }
    } catch (e) {
      debugPrint("❌ Firestore Error: $e");
      _showStyledSnackBar("Error: $e", Colors.red);
    }
  }

  void _showStyledSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("❌ Payment Failed: ${response.message}");
    _showStyledSnackBar("Payment Failed", Colors.red);
  }
  
  void _handleExternalWallet(ExternalWalletResponse response) {}

  void openCheckout(String busName, String price, String passType) {
    print("💳 Opening checkout for $busName - ₹$price");
    _currentBusName = busName;
    _currentPrice = price;
    _currentPassType = passType;

    var options = {
      'key': 'rzp_test_RcTdRnmVYAlF4h',
      'amount': (double.parse(price) * 100).toInt(),
      'name': 'Smart Pune Commute',
      'description': '$passType Ticket: $busName',
      'prefill': {
        'contact': '9876543210', 
        'email': _userEmail,
      },
    };
    
    try {
      razorpay.open(options);
    } catch (e) {
      print("❌ Razorpay Error: $e");
      _showStyledSnackBar("Error: $e", Colors.red);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("🏗️ Building AccessibilityModeListScreen");
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text('Pune Commute', 
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          indicatorWeight: 4,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          isScrollable: true,
          tabs: const [
            Tab(text: '🎓 Students'),
            Tab(text: '🚌 Regular'),
            Tab(text: '👴 Seniors'),
            Tab(text: '🎫 My Tickets'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBusList('Student'),
          _buildBusList('Regular'),
          _buildBusList('Senior'),
          _buildMyTickets(),
        ],
      ),
    );
  }

  // बसची यादी - Debugging Logs सह
  Widget _buildBusList(String passType) {
    print("🔍 Searching for $passType buses...");
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('busList')
          .where('passType', isEqualTo: passType)
          // .where('isActive', isEqualTo: true)  // ही line तात्पुरती काढून टाकली
          .snapshots(),
      builder: (context, snapshot) {
        print("📡 Connection state for $passType: ${snapshot.connectionState}");
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print("❌ ERROR for $passType: ${snapshot.error}");
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 50, color: Colors.red.shade300),
                const SizedBox(height: 10),
                Text('Error: ${snapshot.error}', style: GoogleFonts.poppins()),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          print("⚠️ No $passType buses found in Firebase");
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_bus_outlined, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text("No $passType buses available", 
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16)),
                const SizedBox(height: 8),
                Text("Add buses from Admin Panel", 
                  style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          );
        }

        print("✅ Found ${snapshot.data!.docs.length} $passType buses");
        
        final buses = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: buses.length,
          itemBuilder: (context, index) {
            var bus = buses[index].data() as Map<String, dynamic>;
            print("🚌 Bus: ${bus['name']} - ₹${bus['price']} - Active: ${bus['isActive']}");
            
            return _BusCard(
              busName: bus['name'] ?? 'Unknown Bus',
              busNo: bus['routeNumber'] ?? 'N/A',
              price: bus['price']?.toString() ?? '0',
              busType: '$passType Pass',
              color: _getCategoryColor(passType),
              onPurchase: (busName, price) => openCheckout(busName, price, passType),
            );
          },
        );
      },
    );
  }

  // User ची Tickets दाखवण्यासाठी
  Widget _buildMyTickets() {
    print("🎫 Loading tickets for user: $_userEmail");
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tickets')
          .where('userEmail', isEqualTo: _userEmail)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print("❌ Tickets Error: ${snapshot.error}");
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 50, color: Colors.red.shade300),
                const SizedBox(height: 10),
                Text('Error: ${snapshot.error}', style: GoogleFonts.poppins()),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          print("📭 No tickets found for $_userEmail");
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text("No tickets booked yet", 
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Text("Book your first bus ticket!", 
                  style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 14)),
              ],
            ),
          );
        }

        print("✅ Found ${snapshot.data!.docs.length} tickets");
        final tickets = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            var ticket = tickets[index].data() as Map<String, dynamic>;
            return _buildTicketCard(ticket, tickets[index].id);
          },
        );
      },
    );
  }

  // Ticket Card for User
  Widget _buildTicketCard(Map<String, dynamic> ticket, String docId) {
    Color ticketColor = _getCategoryColor(ticket['passType']);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ticketColor.withOpacity(0.1),
              Colors.white,
            ],
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: ticketColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          ticket['passType'] == 'Student' ? Icons.school :
                          ticket['passType'] == 'Senior' ? Icons.elderly : Icons.person,
                          size: 14,
                          color: ticketColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ticket['passType'] ?? 'Regular',
                          style: GoogleFonts.poppins(
                            color: ticketColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ticket['status'] == 'Active' ? Colors.green.shade50 : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      ticket['status'] ?? 'Active',
                      style: GoogleFonts.poppins(
                        color: ticket['status'] == 'Active' ? Colors.green.shade700 : Colors.orange.shade700,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                ticket['busName'] ?? 'Unknown Bus',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Payment ID: ${ticket['paymentId']?.substring(0, 8)}...",
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontSize: 11,
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
                        "Total Amount",
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        "₹${ticket['price']}",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A237E),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Booked on",
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        _formatDate(ticket['timestamp']),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.qr_code, size: 20, color: Colors.indigo.shade300),
                  const SizedBox(width: 4),
                  Text(
                    "View Ticket",
                    style: GoogleFonts.poppins(
                      color: Colors.indigo,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String? passType) {
    if (passType == 'Student') return Colors.green;
    if (passType == 'Senior') return Colors.orange;
    return Colors.blue;
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "Just now";
    try {
      DateTime date = (timestamp as Timestamp).toDate();
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return "Unknown date";
    }
  }
}

class _BusCard extends StatelessWidget {
  final String busName, busNo, price, busType;
  final Color color;
  final Function(String, String) onPurchase;

  const _BusCard({
    required this.busName, required this.busNo, required this.price,
    required this.busType, required this.color, required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(busType, 
                        style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const Icon(Icons.more_horiz, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 15),
                Text(busName, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF2D3142))),
                Text("Route: $busNo • High Frequency", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.access_time_filled, size: 16, color: Colors.indigo),
                    const SizedBox(width: 5),
                    Text("Every 15 mins", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 20),
                    const Icon(Icons.verified_user, size: 16, color: Colors.indigo),
                    const SizedBox(width: 5),
                    Text("Insured Travel", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("TOTAL FARE", style: GoogleFonts.poppins(fontSize: 10, letterSpacing: 1, color: Colors.grey)),
                    Text("₹$price", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF2D3142))),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => onPurchase(busName, price),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                  ),
                  child: Text('Book Now', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}