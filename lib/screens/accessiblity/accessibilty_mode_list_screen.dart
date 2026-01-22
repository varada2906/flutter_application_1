import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AccessibilityModeListScreen extends StatefulWidget {
  const AccessibilityModeListScreen({super.key});

  @override
  State<AccessibilityModeListScreen> createState() => _AccessibilityModeListScreenState();
}

class _AccessibilityModeListScreenState extends State<AccessibilityModeListScreen> {
  late Razorpay razorpay;
  String _currentBusName = "";
  String _currentPrice = "";
  String _currentPassType = "";

  @override
  void initState() {
    super.initState();
    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      await FirebaseFirestore.instance.collection('tickets').add({
        'busName': _currentBusName,
        'price': _currentPrice,
        'passType': _currentPassType,
        'userEmail': 'varadakorlahalli@gmail.com',
        'paymentId': response.paymentId,
        'status': 'Active',
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        _showStyledSnackBar("Ticket Booked Successfully!", Colors.green);
      }
    } catch (e) {
      debugPrint("Firestore Error: $e");
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

  void _handlePaymentError(PaymentFailureResponse response) => _showStyledSnackBar("Payment Failed", Colors.red);
  void _handleExternalWallet(ExternalWalletResponse response) {}

  void openCheckout(String busName, String price, String passType) {
    _currentBusName = busName;
    _currentPrice = price;
    _currentPassType = passType;

    var options = {
      'key': 'rzp_test_RcTdRnmVYAlF4h',
      'amount': (double.parse(price) * 100).toInt(),
      'name': 'Smart Pune Commute',
      'description': '$passType Ticket: $busName',
      'prefill': {'contact': '9876543210', 'email': 'varadakorlahalli@gmail.com'},
    };
    razorpay.open(options);
  }

  @override
  void dispose() {
    razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
            indicatorColor: Colors.amber,
            indicatorWeight: 4,
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'Students'),
              Tab(text: 'Regular'),
              Tab(text: 'Seniors'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList('Student'),
            _buildList('Regular'),
            _buildList('Senior'),
          ],
        ),
      ),
    );
  }

  Widget _buildList(String type) {
    // Shared list builder for cleaner code
    final items = type == 'Student' 
      ? [const ['Student Express', 'ST-101', '15.00', Colors.green]]
      : type == 'Regular'
        ? [const ['Pune City Express', 'PN-101', '30.00', Colors.blue]]
        : [const ['Senior Care Ride', 'SC-505', '10.00', Colors.orange]];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _BusCard(
          busName: items[index][0] as String,
          busNo: items[index][1] as String,
          price: items[index][2] as String,
          busType: '$type Pass',
          color: items[index][3] as Color,
          onPurchase: (bus, price) => openCheckout(bus, price, type),
        );
      },
    );
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