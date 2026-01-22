import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminTicketPage extends StatefulWidget {
  const AdminTicketPage({super.key});

  @override
  State<AdminTicketPage> createState() => _AdminTicketPageState();
}

class _AdminTicketPageState extends State<AdminTicketPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text("Ticket Administration", 
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.indigo.shade900,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Connects to the same 'tickets' collection created by the user
        stream: _firestore.collection('tickets').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final tickets = snapshot.data!.docs;

          return Column(
            children: [
              _buildRevenueSummary(tickets),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Recent Transactions", 
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("${tickets.length} Total", style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    return _buildTicketCard(tickets[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRevenueSummary(List<QueryDocumentSnapshot> docs) {
    double totalRevenue = docs.fold(0, (sum, item) => sum + double.parse(item['price'].toString()));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.indigo.shade900,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("Total Revenue", "₹${totalRevenue.toStringAsFixed(2)}", Icons.account_balance_wallet),
          _statItem("Tickets Sold", docs.length.toString(), Icons.confirmation_number),
        ],
      ),
    );
  }

  Widget _statItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white54, size: 20),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        Text(title, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildTicketCard(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(data['passType']).withOpacity(0.2),
          child: Icon(Icons.person, color: _getCategoryColor(data['passType'])),
        ),
        title: Text(data['busName'] ?? "Unknown Route", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("User: ${data['userEmail']}", style: const TextStyle(fontSize: 12)),
        trailing: Text("₹${data['price']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Divider(),
                _infoRow("Payment ID", data['paymentId'] ?? "N/A"),
                _infoRow("Pass Type", data['passType'] ?? "Regular"),
                _infoRow("Booking Date", _formatDate(data['timestamp'])),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _firestore.collection('tickets').doc(doc.id).update({'status': 'Refunded'}),
                        child: const Text("Mark Refunded"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
                        onPressed: () => _firestore.collection('tickets').doc(doc.id).delete(),
                        child: const Text("Delete Record", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }

  Color _getCategoryColor(String? type) {
    if (type == 'Student') return Colors.green;
    if (type == 'Senior Citizen') return Colors.orange;
    return Colors.blue;
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "Just now";
    DateTime date = (timestamp as Timestamp).toDate();
    return "${date.day}/${date.month} ${date.hour}:${date.minute}";
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text("No tickets found", style: GoogleFonts.poppins(color: Colors.grey)),
        ],
      ),
    );
  }
}