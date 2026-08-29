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
  final TextEditingController busIdC = TextEditingController(); // New controller for Bus ID
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

  // Load buses from Firestore with real-time updates
  Future<void> _loadBusesFromFirestore() async {
    try {
      final snapshot = await _firestore.collection('buses').get();
      print('📊 Loading ${snapshot.docs.length} buses from Firestore');
      
      setState(() {
        busList = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            "id": doc.id,
            "route": "${data['from'] ?? ''} → ${data['to'] ?? ''}",
            "from": data['from'] ?? '',
            "to": data['to'] ?? '',
            "buses": data['buses']?.toString() ?? '0',
            "type": data['type'] ?? 'Electric',
            "price": data['price'] ?? '₹500',
            "rating": data['rating']?.toString() ?? '4.5',
          };
        }).toList();
      });
      
      print('✅ Loaded ${busList.length} buses');
    } catch (e) {
      print('❌ Error loading buses: $e');
      _showError('Failed to load buses: $e');
    }
  }

  // Check if Bus ID already exists
  Future<bool> _isBusIdExists(String busId) async {
    try {
      final doc = await _firestore.collection('buses').doc(busId).get();
      return doc.exists;
    } catch (e) {
      print('Error checking bus ID: $e');
      return false;
    }
  }

  // Add bus to Firestore
  Future<void> _addBus() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Add Bus Route"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: busIdC,
                decoration: const InputDecoration(
                  labelText: "Bus ID (e.g., B001, BUS123)",
                  border: OutlineInputBorder(),
                  hintText: "Enter unique Bus ID",
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fromC, 
                decoration: const InputDecoration(
                  labelText: "From City",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: toC, 
                decoration: const InputDecoration(
                  labelText: "To City",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: busesC,
                decoration: const InputDecoration(
                  labelText: "No. of Buses",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: typeC, 
                decoration: const InputDecoration(
                  labelText: "Bus Type (Electric/Diesel)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceC, 
                decoration: const InputDecoration(
                  labelText: "Price (e.g., ₹500)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ratingC, 
                decoration: const InputDecoration(
                  labelText: "Rating (1-5)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
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
              // Validate Bus ID
              if (busIdC.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a Bus ID'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              // Check if Bus ID already exists
              final busId = busIdC.text.trim();
              final exists = await _isBusIdExists(busId);
              
              if (exists) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Bus ID "$busId" already exists! Please use a unique ID.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              if (fromC.text.isNotEmpty && toC.text.isNotEmpty && 
                  busesC.text.isNotEmpty && typeC.text.isNotEmpty &&
                  priceC.text.isNotEmpty && ratingC.text.isNotEmpty) {
                
                // Close dialog first
                Navigator.pop(context);
                
                // Show loading
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Adding bus route...'),
                    duration: Duration(seconds: 1),
                  ),
                );
                
                try {
                  // Parse values with proper types
                  final busData = {
                    "from": fromC.text.trim(),
                    "to": toC.text.trim(),
                    "buses": int.tryParse(busesC.text.trim()) ?? 0,
                    "type": typeC.text.trim(),
                    "price": priceC.text.trim(),
                    "rating": double.tryParse(ratingC.text.trim()) ?? 4.5,
                    "stops": 1,
                    "createdAt": FieldValue.serverTimestamp(),
                  };
                  
                  print('📝 Adding bus with ID: $busId');
                  print('📝 Bus data: $busData');
                  
                  // Add to Firestore with custom ID
                  await _firestore.collection('buses').doc(busId).set(busData);
                  
                  // Clear fields
                  _clearFields();
                  
                  // Reload data
                  await _loadBusesFromFirestore();
                  
                  // Show success message
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ Bus route "$busId" added successfully!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  print('❌ Error adding bus: $e');
                  if (mounted) {
                    _showError('Failed to add bus: $e');
                  }
                }
              } else {
                // Show error if fields are empty
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all fields'),
                    backgroundColor: Colors.red,
                  ),
                );
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
    busIdC.text = bus["id"] ?? ''; // Set the Bus ID (read-only for editing)
    fromC.text = bus["from"] ?? '';
    toC.text = bus["to"] ?? '';
    busesC.text = bus["buses"]?.toString() ?? '0';
    typeC.text = bus["type"] ?? '';
    priceC.text = bus["price"] ?? '';
    ratingC.text = bus["rating"]?.toString() ?? '4.5';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Edit Bus Details"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: busIdC,
                decoration: const InputDecoration(
                  labelText: "Bus ID",
                  border: OutlineInputBorder(),
                  hintText: "Bus ID cannot be changed",
                ),
                enabled: false, // Make Bus ID read-only during edit
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fromC, 
                decoration: const InputDecoration(
                  labelText: "From City",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: toC, 
                decoration: const InputDecoration(
                  labelText: "To City",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: busesC,
                decoration: const InputDecoration(
                  labelText: "No. of Buses",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: typeC, 
                decoration: const InputDecoration(
                  labelText: "Bus Type",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceC, 
                decoration: const InputDecoration(
                  labelText: "Price",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ratingC, 
                decoration: const InputDecoration(
                  labelText: "Rating (1-5)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
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
                // Close dialog
                Navigator.pop(context);
                
                // Show loading
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Updating bus route...'),
                    duration: Duration(seconds: 1),
                  ),
                );
                
                // Update in Firestore (using existing ID)
                await _firestore.collection('buses').doc(bus["id"]).update({
                  "from": fromC.text.trim(),
                  "to": toC.text.trim(),
                  "buses": int.tryParse(busesC.text) ?? 0,
                  "type": typeC.text.trim(),
                  "price": priceC.text.trim(),
                  "rating": double.tryParse(ratingC.text) ?? 4.5,
                  "updatedAt": FieldValue.serverTimestamp(),
                });

                // Clear fields
                _clearFields();
                
                // Reload data
                await _loadBusesFromFirestore();
                
                // Show success message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Bus details updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                print('❌ Error updating bus: $e');
                if (mounted) {
                  _showError('Failed to update bus: $e');
                }
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
        content: Text("Are you sure you want to delete ${bus['route']} (${bus['id']})?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Cancel")
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Close dialog
                Navigator.pop(context);
                
                // Show loading
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Deleting bus route...'),
                    duration: Duration(seconds: 1),
                  ),
                );
                
                // Delete from Firestore
                await _firestore.collection('buses').doc(bus["id"]).delete();
                
                // Reload data
                await _loadBusesFromFirestore();
                
                // Show success message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Bus route "${bus["id"]}" deleted successfully!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                print('❌ Error deleting bus: $e');
                if (mounted) {
                  _showError('Failed to delete bus: $e');
                }
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Clear all text fields
  void _clearFields() {
    busIdC.clear();
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
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Bus Details",
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)
        ),
        const SizedBox(height: 10),
        Text(
          "Manage bus routes, total buses, and bus types.",
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade700),
        ),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Bus details table
        Expanded(
          child: busList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_bus, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No bus routes found',
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Click "Add Bus Route" to create one',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    border: TableBorder.all(color: Colors.grey.shade300),
                    headingRowColor: MaterialStateProperty.all(Colors.blue.shade100),
                    columnSpacing: 16,
                    columns: const [
                      DataColumn(label: Text("Bus ID", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Route", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("From", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("To", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Buses", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Type", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Price", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Rating", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: busList.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> bus = entry.value;
                      return DataRow(cells: [
                        DataCell(Text(bus["id"] ?? '')),
                        DataCell(Text(bus["route"] ?? '')),
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
                              onPressed: () => _editBus(index),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteBus(index),
                              tooltip: 'Delete',
                            ),
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