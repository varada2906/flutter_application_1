import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Razorpay razorpay;

  @override
  void initState() {
    super.initState();
    razorpay = Razorpay();

    // Handlers for payment events
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
  }

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
      'key': 'rzp_test_RcTdRnmVYAlF4h', // 👉 Replace with your Key ID only
      'amount': 2000, // amount in paise (₹20.00)
      'name': 'Varada App',
      'description': 'Test Payment',
      'prefill': {
        'contact': '9876543210',
        'email': 'varadakorlahalli@gmail.com'
      },
      'external': {
        'wallets': ['paytm'] // optional
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
    razorpay.clear(); // clean up handlers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Razorpay Test Payment")),
      body: Center(
        child: ElevatedButton(
          onPressed: openCheckout,
          child: const Text("Pay ₹20.00 with Razorpay"),
        ),
      ),
    );
  }
}  