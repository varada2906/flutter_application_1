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
  final TextEditingController lineC = TextEditingController();
  final TextEditingController stationsC = TextEditingController();
  final TextEditingController trainsC = TextEditingController();
  final TextEditingController frequencyC = TextEditingController();
  final TextEditingController durationC = TextEditingController();
  final TextEditingController fareC = TextEditingController();
  final TextEditingController firstTrainC = TextEditingController();
  final TextEditingController lastTrainC = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load metros from Firestore
    _loadMetrosFromFirestore();
  }

  // Load metros from Firestore
  Future<void> _loadMetrosFromFirestore() async {
    try {
      final snapshot = await _firestore.collection('metros').get();
      setState(() {
        metroList = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            "id": doc.id,
            "metroId": data['metroId'] ?? '',
            "line": data['line'] ?? '',
            "stations": data['stations'] ?? '',
            "trains": data['trains']?.toString() ?? '0',
            "frequency": data['frequency'] ?? 'Every 10-15 mins',
            "duration": data['duration'] ?? '30-45 mins',
            "fare": data['fare'] ?? '₹20-₹40',
            "firstTrain": data['firstTrain'] ?? '6:00 AM',
            "lastTrain": data['lastTrain'] ?? '10:00 PM',
          };
        }).toList();
      });
    } catch (e) {
      print('Error loading metros: $e');
    }
  }

  // Add metro to Firestore
  void _addMetro() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Metro Line"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: lineC, 
              decoration: const InputDecoration(labelText: "Line Name (e.g., Purple Line)")
            ),
            TextField(
              controller: stationsC, 
              decoration: const InputDecoration(labelText: "Stations (Format: Start → End)")
            ),
            TextField(
              controller: trainsC,
              decoration: const InputDecoration(labelText: "No. of Trains"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: frequencyC, 
              decoration: const InputDecoration(labelText: "Frequency (e.g., Every 10-15 mins)")
            ),
            TextField(
              controller: durationC, 
              decoration: const InputDecoration(labelText: "Duration (e.g., 30-45 mins)")
            ),
            TextField(
              controller: fareC, 
              decoration: const InputDecoration(labelText: "Fare (e.g., ₹20-₹40)")
            ),
            TextField(
              controller: firstTrainC, 
              decoration: const InputDecoration(labelText: "First Train (e.g., 6:00 AM)")
            ),
            TextField(
              controller: lastTrainC, 
              decoration: const InputDecoration(labelText: "Last Train (e.g., 10:00 PM)")
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
              if (lineC.text.isNotEmpty && stationsC.text.isNotEmpty && 
                  trainsC.text.isNotEmpty && frequencyC.text.isNotEmpty &&
                  durationC.text.isNotEmpty && fareC.text.isNotEmpty) {
                try {
                  // Generate metro ID
                  final metroId = "M${(metroList.length + 1).toString().padLeft(3, '0')}";
                  
                  await _firestore.collection('metros').doc(metroId).set({
                    "metroId": metroId,
                    "line": lineC.text.trim(),
                    "stations": stationsC.text.trim(),
                    "trains": int.tryParse(trainsC.text) ?? 0,
                    "frequency": frequencyC.text.trim(),
                    "duration": durationC.text.trim(),
                    "fare": fareC.text.trim(),
                    "firstTrain": firstTrainC.text.trim().isNotEmpty ? firstTrainC.text.trim() : '6:00 AM',
                    "lastTrain": lastTrainC.text.trim().isNotEmpty ? lastTrainC.text.trim() : '10:00 PM',
                    "createdAt": DateTime.now(),
                  });

                  // Clear fields and refresh
                  _clearFields();
                  await _loadMetrosFromFirestore();
                  Navigator.pop(context);
                  
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Metro line added to database!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  print('Error adding metro: $e');
                  _showError('Failed to add metro: $e');
                }
              } else {
                _showError('Please fill all required fields');
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // Edit metro in Firestore
  void _editMetro(int index) {
    final metro = metroList[index];
    lineC.text = metro["line"] ?? '';
    stationsC.text = metro["stations"] ?? '';
    trainsC.text = metro["trains"]?.toString() ?? '0';
    frequencyC.text = metro["frequency"] ?? 'Every 10-15 mins';
    durationC.text = metro["duration"] ?? '30-45 mins';
    fareC.text = metro["fare"] ?? '₹20-₹40';
    firstTrainC.text = metro["firstTrain"] ?? '6:00 AM';
    lastTrainC.text = metro["lastTrain"] ?? '10:00 PM';
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Metro Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: lineC, 
              decoration: const InputDecoration(labelText: "Line Name")
            ),
            TextField(
              controller: stationsC, 
              decoration: const InputDecoration(labelText: "Stations")
            ),
            TextField(
              controller: trainsC,
              decoration: const InputDecoration(labelText: "No. of Trains"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: frequencyC, 
              decoration: const InputDecoration(labelText: "Frequency")
            ),
            TextField(
              controller: durationC, 
              decoration: const InputDecoration(labelText: "Duration")
            ),
            TextField(
              controller: fareC, 
              decoration: const InputDecoration(labelText: "Fare")
            ),
            TextField(
              controller: firstTrainC, 
              decoration: const InputDecoration(labelText: "First Train")
            ),
            TextField(
              controller: lastTrainC, 
              decoration: const InputDecoration(labelText: "Last Train")
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
                await _firestore.collection('metros').doc(metro["id"]).update({
                  "line": lineC.text.trim(),
                  "stations": stationsC.text.trim(),
                  "trains": int.tryParse(trainsC.text) ?? 0,
                  "frequency": frequencyC.text.trim(),
                  "duration": durationC.text.trim(),
                  "fare": fareC.text.trim(),
                  "firstTrain": firstTrainC.text.trim(),
                  "lastTrain": lastTrainC.text.trim(),
                  "updatedAt": DateTime.now(),
                });

                // Clear fields and refresh
                _clearFields();
                await _loadMetrosFromFirestore();
                Navigator.pop(context);
                
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Metro details updated in database!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                print('Error updating metro: $e');
                _showError('Failed to update metro: $e');
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // Delete metro from Firestore
  void _deleteMetro(int index) {
    final metro = metroList[index];
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Metro Line"),
        content: const Text("Are you sure you want to delete this metro line?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Cancel")
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Delete from Firestore
                await _firestore.collection('metros').doc(metro["id"]).delete();
                
                // Refresh data
                await _loadMetrosFromFirestore();
                Navigator.pop(context);
                
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Metro line deleted from database!'),
                    backgroundColor: Colors.red,
                  ),
                );
              } catch (e) {
                print('Error deleting metro: $e');
                _showError('Failed to delete metro: $e');
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
    lineC.clear();
    stationsC.clear();
    trainsC.clear();
    frequencyC.clear();
    durationC.clear();
    fareC.clear();
    firstTrainC.clear();
    lastTrainC.clear();
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

  // Initialize sample data
  Future<void> _initializeSampleData() async {
    try {
      // First, check if we have data and clear it if needed
      final snapshot = await _firestore.collection('metros').get();
      
      if (snapshot.docs.isNotEmpty) {
        // Ask user if they want to clear existing data
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
        
        // Clear existing data
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }

      // Define sample data
      List<Map<String, dynamic>> sampleData = [
        {
          "metroId": "M001",
          "line": "Purple Line",
          "stations": "PCMC → Civil Court",
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
          "stations": "Vanaz → Ramwadi",
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
          "stations": "Hinjewadi → Shivajinagar",
          "trains": 8,
          "frequency": "Every 15-20 mins",
          "duration": "50 mins",
          "fare": "₹25-₹45",
          "firstTrain": "7:00 AM",
          "lastTrain": "10:00 PM",
          "createdAt": DateTime.now(),
        },
      ];

      // Add sample data using add() instead of set() with document ID
      for (var data in sampleData) {
        await _firestore.collection('metros').add(data);
      }

      // Reload data
      await _loadMetrosFromFirestore();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sample metro data added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error adding sample data: $e');
      _showError('Failed to add sample data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Metro Routes",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "View and manage all metro routes",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Action buttons row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // Add Metro Line button
                ElevatedButton.icon(
                  onPressed: _addMetro,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Metro Route"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                
                const SizedBox(width: 10),
                
                // Initialize Sample Data button
                OutlinedButton.icon(
                  onPressed: _initializeSampleData,
                  icon: const Icon(Icons.data_saver_on),
                  label: const Text("Load Sample Data"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.purple.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Divider(height: 1),

          // Metro List Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Row(
              children: [
                Text(
                  "All Metro Routes",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${metroList.length} routes",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.purple.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Metro details table or loading/empty state
          Expanded(
            child: metroList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.train_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "No Metro Routes Found",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Add a new metro route or load sample data to get started",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _initializeSampleData,
                          icon: const Icon(Icons.download),
                          label: const Text("Load Sample Data"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade700,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SingleChildScrollView(
                      child: DataTable(
                        border: TableBorder.all(color: Colors.grey.shade300),
                        headingRowColor: MaterialStateProperty.all(Colors.purple.shade100),
                        columns: const [
                          DataColumn(label: Text("Metro ID")),
                          DataColumn(label: Text("Line")),
                          DataColumn(label: Text("Stations")),
                          DataColumn(label: Text("Trains")),
                          DataColumn(label: Text("Frequency")),
                          DataColumn(label: Text("Duration")),
                          DataColumn(label: Text("Fare")),
                          DataColumn(label: Text("First Train")),
                          DataColumn(label: Text("Last Train")),
                          DataColumn(label: Text("Actions")),
                        ],
                        rows: metroList.asMap().entries.map((entry) {
                          int index = entry.key;
                          Map<String, dynamic> metro = entry.value;
                          return DataRow(
                            color: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                                return index % 2 == 0
                                    ? Colors.grey.shade50
                                    : Colors.white;
                              },
                            ),
                            cells: [
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.purple.shade100),
                                  ),
                                  child: Text(
                                    metro["metroId"] ?? 'N/A',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple.shade700,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  metro["line"] ?? 'N/A',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              DataCell(
                                Text(
                                  metro["stations"] ?? 'N/A',
                                  style: const TextStyle(color: Color.fromARGB(255, 84, 83, 83)),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.orange.shade200),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.train,
                                        size: 14,
                                        color: Colors.orange.shade700,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        metro["trains"]?.toString() ?? '0',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              DataCell(Text(metro["frequency"] ?? 'N/A')),
                              DataCell(Text(metro["duration"] ?? 'N/A')),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.green.shade200),
                                  ),
                                  child: Text(
                                    metro["fare"] ?? 'N/A',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(Text(metro["firstTrain"] ?? 'N/A')),
                              DataCell(Text(metro["lastTrain"] ?? 'N/A')),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      color: Colors.blue.shade600,
                                      onPressed: () => _editMetro(index),
                                      tooltip: 'Edit',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20),
                                      color: Colors.red.shade600,
                                      onPressed: () => _deleteMetro(index),
                                      tooltip: 'Delete',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}