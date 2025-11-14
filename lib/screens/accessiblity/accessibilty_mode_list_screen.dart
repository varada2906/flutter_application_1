import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class AccessibilityModeListScreen extends StatefulWidget {
  const AccessibilityModeListScreen({super.key});

  @override
  _AccessibilityModeListScreenState createState() =>
      _AccessibilityModeListScreenState();
}

class _AccessibilityModeListScreenState
    extends State<AccessibilityModeListScreen> {
  late Razorpay razorpay;

  @override
  void initState() {
    super.initState();
    razorpay = Razorpay();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
  }

  // ✅ Razorpay Handlers
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

  // ✅ Function to open Razorpay checkout
  void openCheckout(String busName, String price) {
    var options = {
      'key': 'rzp_test_RcTdRnmVYAlF4h', // your Razorpay key
      'amount': (double.parse(price) * 100).toInt(), // ₹ → paise
      'name': 'Smart Pune Commute',
      'description': 'Ticket for $busName',
      'prefill': {
        'contact': '9876543210',
        'email': 'varadakorlahalli@gmail.com',
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      razorpay.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Smart Pune Commute',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Available Pune Routes',
              style:
                  TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 10),

          // --- Route 1: Swargate to Hinjewadi ---
          _BusCard(
            busName: 'Pune City Express',
            busNo: 'PN 101',
            departureTime: '07:00 AM',
            arrivalTime: '08:10 AM',
            duration: '01h 10m',
            distance: '22 km',
            price: '30.00',
            busType: 'AC Volvo',
            seatsLeft: 42,
            color: Colors.green,
            onPurchase: openCheckout,
          ),
          const SizedBox(height: 15),

          // --- Route 2: Pune Station to Hadapsar ---
          _BusCard(
            busName: 'PMPML Rapid',
            busNo: 'PN 202',
            departureTime: '08:30 AM',
            arrivalTime: '09:00 AM',
            duration: '30m',
            distance: '10 km',
            price: '20.00',
            busType: 'Electric Bus',
            seatsLeft: 25,
            color: Colors.pink,
            onPurchase: openCheckout,
          ),
          const SizedBox(height: 15),

          // --- Route 3: Kothrud Depot to Viman Nagar ---
          _BusCard(
            busName: 'Metro Shuttle',
            busNo: 'PN 303',
            departureTime: '09:45 AM',
            arrivalTime: '10:30 AM',
            duration: '45m',
            distance: '18 km',
            price: '25.00',
            busType: 'Luxury AC',
            seatsLeft: 12,
            color: Colors.orange,
            onPurchase: openCheckout,
          ),
          const SizedBox(height: 15),

          // --- Route 4: Nigdi to Swargate ---
          _BusCard(
            busName: 'City Connect Plus',
            busNo: 'PN 404',
            departureTime: '10:15 AM',
            arrivalTime: '11:20 AM',
            duration: '01h 05m',
            distance: '28 km',
            price: '35.00',
            busType: 'Semi-Luxury',
            seatsLeft: 20,
            color: Colors.blue,
            onPurchase: openCheckout,
          ),
        ],
      ),
    );
  }
}

// --- Reusable Widget for Bus Card ---
class _BusCard extends StatelessWidget {
  final String busName;
  final String busNo;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final String distance;
  final String price;
  final String busType;
  final int seatsLeft;
  final Color color;
  final Function(String, String) onPurchase;

  const _BusCard({
    required this.busName,
    required this.busNo,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.distance,
    required this.price,
    required this.busType,
    required this.seatsLeft,
    required this.color,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(busName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(busNo, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(departureTime,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 6),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(duration,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                          Text(distance,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(arrivalTime,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Bus Type + Seats
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(busType,
                      style: TextStyle(
                          color: color, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 10),
                Text('$seatsLeft seats left', style: TextStyle(color: color)),
              ],
            ),

            const Divider(height: 20),

            // Price + Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Starting from',
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text('₹$price',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => onPurchase(busName, price),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Purchase Ticket',
                      style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
