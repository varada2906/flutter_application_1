import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BusDetailsPage extends StatefulWidget {
  const BusDetailsPage({super.key});

  @override
  State<BusDetailsPage> createState() => _BusDetailsPageState();
}

class _BusDetailsPageState extends State<BusDetailsPage> {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Local bus list
  List<Map<String, dynamic>> busList = [];
  
  // Text controllers
  final TextEditingController routeC = TextEditingController();
  final TextEditingController fromC = TextEditingController();
  final TextEditingController toC = TextEditingController();
  final TextEditingController busesC = TextEditingController();
  final TextEditingController typeC = TextEditingController();
  final TextEditingController priceC = TextEditingController();
  final TextEditingController ratingC = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load buses from Firestore
    _loadBusesFromFirestore();
  }

  // Load buses from Firestore
  Future<void> _loadBusesFromFirestore() async {
    try {
      final snapshot = await _firestore.collection('buses').get();
      setState(() {
        busList = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            "id": doc.id,
            "route": _getDisplayRoute(data['from'] ?? '', data['to'] ?? ''), // FIXED: Use display format
            "from": data['from'] ?? '',
            "to": data['to'] ?? '',
            "buses": data['buses']?.toString() ?? '0',
            "type": data['type'] ?? 'Electric',
            "price": data['price'] ?? '₹500',
            "rating": data['rating']?.toString() ?? '4.5',
          };
        }).toList();
      });
    } catch (e) {
      print('Error loading buses: $e');
    }
  }

  // Helper method to create display route format
  String _getDisplayRoute(String from, String to) {
    return "$from → $to"; // This is the display format
  }

  // Add bus to Firestore
  void _addBus() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Bus Route"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: fromC, 
              decoration: const InputDecoration(labelText: "From City")
            ),
            TextField(
              controller: toC, 
              decoration: const InputDecoration(labelText: "To City")
            ),
            TextField(
              controller: busesC,
              decoration: const InputDecoration(labelText: "No. of Buses"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: typeC, 
              decoration: const InputDecoration(labelText: "Bus Type (Electric/Diesel)")
            ),
            TextField(
              controller: priceC, 
              decoration: const InputDecoration(labelText: "Price")
            ),
            TextField(
              controller: ratingC, 
              decoration: const InputDecoration(labelText: "Rating (1-5)"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearFields();
              Navigator.pop(context);
            }, 
            child: const Text("Cancel")
          ),
          ElevatedButton(
            onPressed: () async {
              if (fromC.text.isNotEmpty && toC.text.isNotEmpty && 
                  busesC.text.isNotEmpty && typeC.text.isNotEmpty &&
                  priceC.text.isNotEmpty && ratingC.text.isNotEmpty) {
                try {
                  // Generate bus ID
                  final busId = "B${(busList.length + 1).toString().padLeft(3, '0')}";
                  
                  // FIXED: Save only from and to separately, not the route with arrow
                  await _firestore.collection('buses').doc(busId).set({
                    "from": fromC.text.trim(),
                    "to": toC.text.trim(),
                    "buses": int.tryParse(busesC.text) ?? 0,
                    "type": typeC.text.trim(),
                    "price": priceC.text.trim(),
                    "rating": double.tryParse(ratingC.text) ?? 4.5,
                    "stops": 1,
                    "createdAt": DateTime.now(),
                  });

                  // Clear fields and refresh
                  _clearFields();
                  await _loadBusesFromFirestore();
                  Navigator.pop(context);
                  
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Bus route added to database!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  print('Error adding bus: $e');
                  _showError('Failed to add bus: $e');
                }
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // Edit bus in Firestore
  void _editBus(int index) {
    final bus = busList[index];
    fromC.text = bus["from"] ?? '';
    toC.text = bus["to"] ?? '';
    busesC.text = bus["buses"]?.toString() ?? '0';
    typeC.text = bus["type"] ?? '';
    priceC.text = bus["price"] ?? '';
    ratingC.text = bus["rating"]?.toString() ?? '4.5';
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Bus Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: fromC, 
              decoration: const InputDecoration(labelText: "From City")
            ),
            TextField(
              controller: toC, 
              decoration: const InputDecoration(labelText: "To City")
            ),
            TextField(
              controller: busesC,
              decoration: const InputDecoration(labelText: "No. of Buses"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: typeC, 
              decoration: const InputDecoration(labelText: "Bus Type")
            ),
            TextField(
              controller: priceC, 
              decoration: const InputDecoration(labelText: "Price")
            ),
            TextField(
              controller: ratingC, 
              decoration: const InputDecoration(labelText: "Rating (1-5)"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearFields();
              Navigator.pop(context);
            }, 
            child: const Text("Cancel")
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // FIXED: Update only from and to, not route
                await _firestore.collection('buses').doc(bus["id"]).update({
                  "from": fromC.text.trim(),
                  "to": toC.text.trim(),
                  "buses": int.tryParse(busesC.text) ?? 0,
                  "type": typeC.text.trim(),
                  "price": priceC.text.trim(),
                  "rating": double.tryParse(ratingC.text) ?? 4.5,
                  "updatedAt": DateTime.now(),
                });

                // Clear fields and refresh
                _clearFields();
                await _loadBusesFromFirestore();
                Navigator.pop(context);
                
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Bus details updated in database!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                print('Error updating bus: $e');
                _showError('Failed to update bus: $e');
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // Delete bus from Firestore
  void _deleteBus(int index) {
    final bus = busList[index];
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Bus Route"),
        content: const Text("Are you sure you want to delete this route?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Cancel")
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Delete from Firestore
                await _firestore.collection('buses').doc(bus["id"]).delete();
                
                // Refresh data
                await _loadBusesFromFirestore();
                Navigator.pop(context);
                
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Bus route deleted from database!'),
                    backgroundColor: Colors.red,
                  ),
                );
              } catch (e) {
                print('Error deleting bus: $e');
                _showError('Failed to delete bus: $e');
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // Clear all text fields
  void _clearFields() {
    fromC.clear();
    toC.clear();
    busesC.clear();
    typeC.clear();
    priceC.clear();
    ratingC.clear();
  }

  // Show error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Bus Details",
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text("Manage bus routes, total buses, and bus types.",
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade700)),
        const SizedBox(height: 20),

        // Add button
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton.icon(
            onPressed: _addBus,
            icon: const Icon(Icons.add),
            label: const Text("Add Bus Route"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Bus details table
        Expanded(
          child: SingleChildScrollView(
            child: DataTable(
              border: TableBorder.all(color: Colors.grey.shade300),
              headingRowColor: MaterialStateProperty.all(Colors.blue.shade100),
              columns: const [
                DataColumn(label: Text("Bus ID")),
                DataColumn(label: Text("Route")),
                DataColumn(label: Text("From")),
                DataColumn(label: Text("To")),
                DataColumn(label: Text("Buses")),
                DataColumn(label: Text("Type")),
                DataColumn(label: Text("Price")),
                DataColumn(label: Text("Rating")),
                DataColumn(label: Text("Actions")),
              ],
              rows: busList.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> bus = entry.value;
                return DataRow(cells: [
                  DataCell(Text(bus["id"] ?? '')),
                  DataCell(Text(bus["route"] ?? '')), // This will show "From → To"
                  DataCell(Text(bus["from"] ?? '')),
                  DataCell(Text(bus["to"] ?? '')),
                  DataCell(Text(bus["buses"]?.toString() ?? '0')),
                  DataCell(Text(bus["type"] ?? '')),
                  DataCell(Text(bus["price"] ?? '')),
                  DataCell(Text(bus["rating"]?.toString() ?? '4.5')),
                  DataCell(Row(
                    children: [
                      IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editBus(index)),
                      IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteBus(index)),
                    ],
                  )),
                ]);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}