import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminTicketPage extends StatefulWidget {
  const AdminTicketPage({super.key});

  @override
  State<AdminTicketPage> createState() => _AdminTicketPageState();
}

class _AdminTicketPageState extends State<AdminTicketPage> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TabController _tabController;
  
  // Form controllers for adding buses
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _routeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String _selectedPassType = 'Regular';
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _routeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text("Admin Dashboard", 
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.indigo.shade900,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "🎫 Tickets", icon: Icon(Icons.receipt)),
            Tab(text: "🚌 Manage Buses", icon: Icon(Icons.directions_bus)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Tickets View
          _buildTicketsTab(),
          
          // Tab 2: Bus Management
          _buildBusManagementTab(),
        ],
      ),
    );
  }

  // ============= TAB 1: TICKETS =============
  Widget _buildTicketsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('tickets').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState("No tickets booked yet");
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
    );
  }

  // ============= TAB 2: BUS MANAGEMENT =============
  Widget _buildBusManagementTab() {
    return Column(
      children: [
        // Add Bus Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _showAddBusDialog,
            icon: const Icon(Icons.add),
            label: Text("Add New Bus", style: GoogleFonts.poppins()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade900,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        
        // Buses List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('busList').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState('No buses added yet.\nClick "Add New Bus" to get started');
              }

              final buses = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: buses.length,
                itemBuilder: (context, index) {
                  return _buildBusCard(buses[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Bus Card for Admin
  Widget _buildBusCard(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Color categoryColor = _getCategoryColor(data['passType']);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          border: !(data['isActive'] ?? true) 
              ? Border.all(color: Colors.grey.shade300)
              : null,
          borderRadius: BorderRadius.circular(15),
        ),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: categoryColor.withOpacity(0.2),
            child: Icon(
              data['isActive'] ?? true ? Icons.directions_bus : Icons.block,
              color: data['isActive'] ?? true ? categoryColor : Colors.grey,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  data['name'] ?? 'Unknown Bus',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: (data['isActive'] ?? true) 
                        ? TextDecoration.none 
                        : TextDecoration.lineThrough,
                    color: (data['isActive'] ?? true) ? Colors.black : Colors.grey,
                  ),
                ),
              ),
              if (!(data['isActive'] ?? true))
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('Inactive', 
                    style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
                ),
            ],
          ),
          subtitle: Text("Route: ${data['routeNumber']} • ₹${data['price']}"),
          trailing: Text(
            data['passType'] ?? 'Regular',
            style: TextStyle(color: categoryColor, fontWeight: FontWeight.bold),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Divider(),
                  _infoRow("Booked Count", "${data['bookedCount'] ?? 0}"),
                  _infoRow("Status", (data['isActive'] ?? true) ? "Active" : "Inactive"),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Edit Button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showEditBusDialog(doc),
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text("Edit"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Toggle Active/Inactive Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _toggleBusStatus(doc),
                          icon: Icon(
                            (data['isActive'] ?? true) ? Icons.block : Icons.check_circle,
                            size: 16,
                          ),
                          label: Text(
                            (data['isActive'] ?? true) ? 'Deactivate' : 'Activate',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (data['isActive'] ?? true) 
                                ? Colors.orange.shade700 
                                : Colors.green.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Delete Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _deleteBus(doc),
                          icon: const Icon(Icons.delete, size: 16),
                          label: const Text("Delete"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add Bus Dialog
  void _showAddBusDialog() {
    _nameController.clear();
    _routeController.clear();
    _priceController.clear();
    _selectedPassType = 'Regular';
    _isActive = true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add New Bus", style: GoogleFonts.poppins()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Bus Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _routeController,
                decoration: const InputDecoration(
                  labelText: 'Route Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (₹)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedPassType,
                decoration: const InputDecoration(
                  labelText: 'Pass Type',
                  border: OutlineInputBorder(),
                ),
                items: ['Student', 'Regular', 'Senior'].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) => _selectedPassType = value!,
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: Text("Active", style: GoogleFonts.poppins()),
                value: _isActive,
                onChanged: (value) => _isActive = value,
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
            onPressed: _addBusToFirebase,
            child: const Text('Add Bus'),
          ),
        ],
      ),
    );
  }

  // Edit Bus Dialog
  void _showEditBusDialog(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    _nameController.text = data['name'] ?? '';
    _routeController.text = data['routeNumber'] ?? '';
    _priceController.text = data['price']?.toString() ?? '';
    _selectedPassType = data['passType'] ?? 'Regular';
    _isActive = data['isActive'] ?? true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Bus", style: GoogleFonts.poppins()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Bus Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _routeController,
                decoration: const InputDecoration(
                  labelText: 'Route Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (₹)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedPassType,
                decoration: const InputDecoration(
                  labelText: 'Pass Type',
                  border: OutlineInputBorder(),
                ),
                items: ['Student', 'Regular', 'Senior'].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) => _selectedPassType = value!,
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: Text("Active", style: GoogleFonts.poppins()),
                value: _isActive,
                onChanged: (value) => _isActive = value,
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
            onPressed: () => _updateBusInFirebase(doc),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // Add to Firebase
  void _addBusToFirebase() async {
    if (_nameController.text.isEmpty || 
        _routeController.text.isEmpty || 
        _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      await _firestore.collection('busList').add({
        'name': _nameController.text,
        'routeNumber': _routeController.text,
        'price': double.parse(_priceController.text),
        'passType': _selectedPassType,
        'isActive': _isActive,
        'bookedCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bus added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Update in Firebase
  void _updateBusInFirebase(DocumentSnapshot doc) async {
    try {
      await _firestore.collection('busList').doc(doc.id).update({
        'name': _nameController.text,
        'routeNumber': _routeController.text,
        'price': double.parse(_priceController.text),
        'passType': _selectedPassType,
        'isActive': _isActive,
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bus updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Toggle Bus Status
  void _toggleBusStatus(DocumentSnapshot doc) async {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool newStatus = !(data['isActive'] ?? true);
    
    try {
      await _firestore.collection('busList').doc(doc.id).update({
        'isActive': newStatus,
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bus ${newStatus ? 'activated' : 'deactivated'}!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Delete Bus
  void _deleteBus(DocumentSnapshot doc) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bus'),
        content: const Text('Are you sure you want to delete this bus?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestore.collection('busList').doc(doc.id).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bus deleted successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // ============= COMMON WIDGETS =============
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
    if (type == 'Senior') return Colors.orange;
    return Colors.blue;
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "Just now";
    DateTime date = (timestamp as Timestamp).toDate();
    return "${date.day}/${date.month} ${date.hour}:${date.minute}";
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(message, 
            style: GoogleFonts.poppins(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}