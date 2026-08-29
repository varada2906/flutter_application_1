import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class MetroSearchScreen extends StatefulWidget {
  const MetroSearchScreen({super.key});

  @override
  State<MetroSearchScreen> createState() => _MetroSearchScreenState();
}

class _MetroSearchScreenState extends State<MetroSearchScreen> {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Local metro list
  List<Map<String, dynamic>> metroList = [];
  
  // Text controllers for add/edit
  final TextEditingController metroIdC = TextEditingController();
  final TextEditingController lineC = TextEditingController();
  final TextEditingController fromC = TextEditingController(); // New: Starting station
  final TextEditingController toC = TextEditingController(); // New: Ending station
  final TextEditingController trainsC = TextEditingController();
  final TextEditingController frequencyC = TextEditingController();
  final TextEditingController durationC = TextEditingController();
  final TextEditingController fareC = TextEditingController();
  final TextEditingController firstTrainC = TextEditingController();
  final TextEditingController lastTrainC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMetrosFromFirestore();
  }

  Future<void> _loadMetrosFromFirestore() async {
    try {
      final snapshot = await _firestore.collection('metros').get();
      print('📊 Loading ${snapshot.docs.length} metros from Firestore');
      
      setState(() {
        metroList = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            "id": doc.id,
            "metroId": data['metroId'] ?? '',
            "line": data['line'] ?? '',
            "from": data['from'] ?? '',
            "to": data['to'] ?? '',
            "stations": "${data['from'] ?? ''} → ${data['to'] ?? ''}", // Combined for display
            "trains": data['trains']?.toString() ?? '0',
            "frequency": data['frequency'] ?? 'Every 10-15 mins',
            "duration": data['duration'] ?? '30-45 mins',
            "fare": data['fare'] ?? '₹20-₹40',
            "firstTrain": data['firstTrain'] ?? '6:00 AM',
            "lastTrain": data['lastTrain'] ?? '10:00 PM',
          };
        }).toList();
      });
      
      print('✅ Loaded ${metroList.length} metros');
    } catch (e) {
      print('❌ Error loading metros: $e');
      _showError('Failed to load metros: $e');
    }
  }

  // Check if Metro ID already exists
  Future<bool> _isMetroIdExists(String metroId) async {
    try {
      final doc = await _firestore.collection('metros').doc(metroId).get();
      return doc.exists;
    } catch (e) {
      print('Error checking metro ID: $e');
      return false;
    }
  }

  void _addMetro() {
    _clearFields();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Add Metro Line"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: metroIdC,
                decoration: const InputDecoration(
                  labelText: "Metro ID (e.g., M001, M002)",
                  border: OutlineInputBorder(),
                  hintText: "Enter unique Metro ID",
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lineC, 
                decoration: const InputDecoration(
                  labelText: "Line Name",
                  hintText: "e.g., Purple Line",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fromC, 
                decoration: const InputDecoration(
                  labelText: "Starting Station",
                  hintText: "e.g., PCMC",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: toC, 
                decoration: const InputDecoration(
                  labelText: "Ending Station",
                  hintText: "e.g., Civil Court",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: trainsC,
                decoration: const InputDecoration(
                  labelText: "No. of Trains",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: frequencyC, 
                decoration: const InputDecoration(
                  labelText: "Frequency",
                  hintText: "e.g., Every 10-15 mins",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durationC, 
                decoration: const InputDecoration(
                  labelText: "Duration",
                  hintText: "e.g., 30-45 mins",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fareC, 
                decoration: const InputDecoration(
                  labelText: "Fare",
                  hintText: "e.g., ₹20-₹40",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: firstTrainC, 
                decoration: const InputDecoration(
                  labelText: "First Train",
                  hintText: "e.g., 6:00 AM",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lastTrainC, 
                decoration: const InputDecoration(
                  labelText: "Last Train",
                  hintText: "e.g., 10:00 PM",
                  border: OutlineInputBorder(),
                ),
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
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              // Validate Metro ID
              if (metroIdC.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a Metro ID'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              // Check if Metro ID already exists
              final metroId = metroIdC.text.trim();
              final exists = await _isMetroIdExists(metroId);
              
              if (exists) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Metro ID "$metroId" already exists! Please use a unique ID.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              if (lineC.text.isNotEmpty && fromC.text.isNotEmpty && toC.text.isNotEmpty && 
                  trainsC.text.isNotEmpty && frequencyC.text.isNotEmpty &&
                  durationC.text.isNotEmpty && fareC.text.isNotEmpty) {
                
                // Close dialog first
                Navigator.pop(context);
                
                // Show loading
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Adding metro line...'),
                    duration: Duration(seconds: 1),
                  ),
                );
                
                try {
                  final metroData = {
                    "metroId": metroId,
                    "line": lineC.text.trim(),
                    "from": fromC.text.trim(),
                    "to": toC.text.trim(),
                    "trains": int.tryParse(trainsC.text) ?? 0,
                    "frequency": frequencyC.text.trim(),
                    "duration": durationC.text.trim(),
                    "fare": fareC.text.trim(),
                    "firstTrain": firstTrainC.text.trim().isNotEmpty ? firstTrainC.text.trim() : '6:00 AM',
                    "lastTrain": lastTrainC.text.trim().isNotEmpty ? lastTrainC.text.trim() : '10:00 PM',
                    "createdAt": DateTime.now(),
                  };

                  print('📝 Adding metro with ID: $metroId');
                  print('📝 Metro data: $metroData');
                  
                  await _firestore.collection('metros').doc(metroId).set(metroData);

                  _clearFields();
                  await _loadMetrosFromFirestore();
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ Metro line "$metroId" added successfully!'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  print('❌ Error adding metro: $e');
                  if (mounted) {
                    _showError('Failed to add metro: $e');
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all required fields'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
            ),
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _editMetro(int index) {
    final metro = metroList[index];
    metroIdC.text = metro["metroId"] ?? '';
    lineC.text = metro["line"] ?? '';
    fromC.text = metro["from"] ?? '';
    toC.text = metro["to"] ?? '';
    trainsC.text = metro["trains"]?.toString() ?? '0';
    frequencyC.text = metro["frequency"] ?? 'Every 10-15 mins';
    durationC.text = metro["duration"] ?? '30-45 mins';
    fareC.text = metro["fare"] ?? '₹20-₹40';
    firstTrainC.text = metro["firstTrain"] ?? '6:00 AM';
    lastTrainC.text = metro["lastTrain"] ?? '10:00 PM';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Edit Metro Details"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: metroIdC,
                decoration: const InputDecoration(
                  labelText: "Metro ID",
                  border: OutlineInputBorder(),
                  hintText: "Metro ID cannot be changed",
                ),
                enabled: false, // Make Metro ID read-only during edit
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lineC, 
                decoration: const InputDecoration(
                  labelText: "Line Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fromC, 
                decoration: const InputDecoration(
                  labelText: "Starting Station",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: toC, 
                decoration: const InputDecoration(
                  labelText: "Ending Station",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: trainsC,
                decoration: const InputDecoration(
                  labelText: "No. of Trains",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: frequencyC, 
                decoration: const InputDecoration(
                  labelText: "Frequency",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durationC, 
                decoration: const InputDecoration(
                  labelText: "Duration",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fareC, 
                decoration: const InputDecoration(
                  labelText: "Fare",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: firstTrainC, 
                decoration: const InputDecoration(
                  labelText: "First Train",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lastTrainC, 
                decoration: const InputDecoration(
                  labelText: "Last Train",
                  border: OutlineInputBorder(),
                ),
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
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Close dialog
                Navigator.pop(context);
                
                // Show loading
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Updating metro details...'),
                    duration: Duration(seconds: 1),
                  ),
                );
                
                await _firestore.collection('metros').doc(metro["id"]).update({
                  "line": lineC.text.trim(),
                  "from": fromC.text.trim(),
                  "to": toC.text.trim(),
                  "trains": int.tryParse(trainsC.text) ?? 0,
                  "frequency": frequencyC.text.trim(),
                  "duration": durationC.text.trim(),
                  "fare": fareC.text.trim(),
                  "firstTrain": firstTrainC.text.trim(),
                  "lastTrain": lastTrainC.text.trim(),
                  "updatedAt": DateTime.now(),
                });

                _clearFields();
                await _loadMetrosFromFirestore();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Metro details updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                print('❌ Error updating metro: $e');
                if (mounted) {
                  _showError('Failed to update metro: $e');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text("Save Changes"),
          ),
        ],
      ),
    );
  }

  void _deleteMetro(int index) {
    final metro = metroList[index];
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Metro Line"),
        content: Text("Are you sure you want to delete ${metro['line']} (${metro['metroId']})?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Close dialog
                Navigator.pop(context);
                
                // Show loading
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Deleting metro line...'),
                    duration: Duration(seconds: 1),
                  ),
                );
                
                await _firestore.collection('metros').doc(metro["id"]).delete();
                await _loadMetrosFromFirestore();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Metro line "${metro["metroId"]}" deleted successfully!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                print('❌ Error deleting metro: $e');
                if (mounted) {
                  _showError('Failed to delete metro: $e');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _clearFields() {
    metroIdC.clear();
    lineC.clear();
    fromC.clear();
    toC.clear();
    trainsC.clear();
    frequencyC.clear();
    durationC.clear();
    fareC.clear();
    firstTrainC.clear();
    lastTrainC.clear();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _initializeSampleData() async {
    try {
      final snapshot = await _firestore.collection('metros').get();
      
      if (snapshot.docs.isNotEmpty) {
        bool shouldClear = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Clear Existing Data?"),
            content: const Text("Sample data already exists. Do you want to clear it and add new sample data?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text("Clear & Add"),
              ),
            ],
          ),
        ) ?? false;
        
        if (!shouldClear) return;
        
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }

      List<Map<String, dynamic>> sampleData = [
        {
          "metroId": "M001",
          "line": "Purple Line",
          "from": "PCMC",
          "to": "Civil Court",
          "trains": 12,
          "frequency": "Every 10-15 mins",
          "duration": "45 mins",
          "fare": "₹20-₹40",
          "firstTrain": "6:00 AM",
          "lastTrain": "10:00 PM",
          "createdAt": DateTime.now(),
        },
        {
          "metroId": "M002",
          "line": "Aqua Line",
          "from": "Vanaz",
          "to": "Ramwadi",
          "trains": 9,
          "frequency": "Every 12-18 mins",
          "duration": "40 mins",
          "fare": "₹15-₹35",
          "firstTrain": "6:30 AM",
          "lastTrain": "10:30 PM",
          "createdAt": DateTime.now(),
        },
        {
          "metroId": "M003",
          "line": "Hinjewadi Line",
          "from": "Hinjewadi",
          "to": "Shivajinagar",
          "trains": 8,
          "frequency": "Every 15-20 mins",
          "duration": "50 mins",
          "fare": "₹25-₹45",
          "firstTrain": "7:00 AM",
          "lastTrain": "10:00 PM",
          "createdAt": DateTime.now(),
        },
      ];

      for (var data in sampleData) {
        await _firestore.collection('metros').doc(data["metroId"]).set(data);
      }

      await _loadMetrosFromFirestore();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Sample metro data added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Error adding sample data: $e');
      _showError('Failed to add sample data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Metro Routes",
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)
        ),
        const SizedBox(height: 10),
        Text(
          "Manage metro lines, stations, train frequency, and timings.",
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 20),

        // Action buttons row
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _addMetro,
              icon: const Icon(Icons.add),
              label: const Text("Add Metro Route"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)
                ),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: _initializeSampleData,
              icon: const Icon(Icons.data_saver_on),
              label: const Text("Load Sample Data"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.purple.shade700,
                side: BorderSide(color: Colors.purple.shade700),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Metro details table
        Expanded(
          child: metroList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.train, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No metro routes found',
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Click "Add Metro Route" to create one or load sample data',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    border: TableBorder.all(color: Colors.grey.shade300),
                    headingRowColor: MaterialStateProperty.all(Colors.purple.shade100),
                    columnSpacing: 16,
                    columns: const [
                      DataColumn(label: Text("Metro ID", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Line Name", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("From", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("To", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Trains", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Frequency", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Duration", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Fare", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("First Train", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Last Train", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: metroList.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> metro = entry.value;
                      return DataRow(cells: [
                        DataCell(Text(metro["metroId"] ?? '')),
                        DataCell(Text(metro["line"] ?? '')),
                        DataCell(Text(metro["from"] ?? '')),
                        DataCell(Text(metro["to"] ?? '')),
                        DataCell(Text(metro["trains"]?.toString() ?? '0')),
                        DataCell(Text(metro["frequency"] ?? '')),
                        DataCell(Text(metro["duration"] ?? '')),
                        DataCell(Text(metro["fare"] ?? '')),
                        DataCell(Text(metro["firstTrain"] ?? '')),
                        DataCell(Text(metro["lastTrain"] ?? '')),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editMetro(index),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteMetro(index),
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