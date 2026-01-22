import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MetroDetailsPage extends StatefulWidget {
  const MetroDetailsPage({super.key});

  @override
  State<MetroDetailsPage> createState() => _MetroDetailsPageState();
}

class _MetroDetailsPageState extends State<MetroDetailsPage> {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Metro data from Firestore
  List<Map<String, dynamic>> _metroList = [];
  
  // Loading state
  bool _isLoading = true;
  
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
    // Load metro data from Firestore
    _loadMetroData();
  }

  // Load metro data from Firestore
  Future<void> _loadMetroData() async {
    try {
      final snapshot = await _firestore.collection('metros').get();
      setState(() {
        _metroList = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'metroId': data['metroId'] ?? '',
            'line': data['line'] ?? '',
            'stations': data['stations'] ?? '',
            'trains': data['trains']?.toString() ?? '0',
            'frequency': data['frequency'] ?? 'Every 10-15 mins',
            'duration': data['duration'] ?? '30-45 mins',
            'fare': data['fare'] ?? '₹20-₹40',
            'firstTrain': data['firstTrain'] ?? '6:00 AM',
            'lastTrain': data['lastTrain'] ?? '10:00 PM',
            'createdAt': data['createdAt'] ?? DateTime.now(),
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading metro data: $e');
      setState(() {
        _isLoading = false;
      });
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load metro data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Initialize sample data
  Future<void> _initializeSampleMetroData() async {
    try {
      // Check if data already exists
      final snapshot = await _firestore.collection('metros').get();
      if (snapshot.docs.isNotEmpty) {
        // Ask for confirmation to clear existing data
        bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Data Already Exists"),
            content: const Text("Do you want to clear existing data and add sample data?"),
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

        if (!confirm) return;

        // Clear existing data
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }

      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adding sample metro data...'),
          backgroundColor: Colors.blue,
        ),
      );

      // Sample metro data
      final List<Map<String, dynamic>> sampleMetros = [
        {
          'metroId': 'M001',
          'line': 'Purple Line',
          'stations': 'PCMC → Civil Court',
          'trains': 12,
          'frequency': 'Every 10-15 mins',
          'duration': '45 mins',
          'fare': '₹20-₹40',
          'firstTrain': '6:00 AM',
          'lastTrain': '10:00 PM',
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'metroId': 'M002',
          'line': 'Aqua Line',
          'stations': 'Vanaz → Ramwadi',
          'trains': 9,
          'frequency': 'Every 12-18 mins',
          'duration': '40 mins',
          'fare': '₹15-₹35',
          'firstTrain': '6:30 AM',
          'lastTrain': '10:30 PM',
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'metroId': 'M003',
          'line': 'Hinjewadi Line',
          'stations': 'Hinjewadi → Shivajinagar',
          'trains': 8,
          'frequency': 'Every 15-20 mins',
          'duration': '50 mins',
          'fare': '₹25-₹45',
          'firstTrain': '7:00 AM',
          'lastTrain': '10:00 PM',
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
      ];

      // Add each sample metro to Firestore
      for (var metro in sampleMetros) {
        await _firestore.collection('metros').add(metro);
      }

      // Reload data
      await _loadMetroData();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sample metro data added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      print('Sample metro data added successfully!');
    } catch (e) {
      print('Error adding sample data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add sample data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Add new metro line to Firestore
  Future<void> _addMetro() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Metro Line"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: lineC,
              decoration: const InputDecoration(labelText: "Line Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: stationsC,
              decoration: const InputDecoration(labelText: "Stations (Format: Start → End)"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: trainsC,
              decoration: const InputDecoration(labelText: "No. of Trains"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: frequencyC,
              decoration: const InputDecoration(labelText: "Frequency (e.g., Every 10-15 mins)"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: durationC,
              decoration: const InputDecoration(labelText: "Duration (e.g., 30-45 mins)"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: fareC,
              decoration: const InputDecoration(labelText: "Fare (e.g., ₹20-₹40)"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: firstTrainC,
              decoration: const InputDecoration(labelText: "First Train (e.g., 6:00 AM)"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: lastTrainC,
              decoration: const InputDecoration(labelText: "Last Train (e.g., 10:00 PM)"),
            ),
          ],
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
              if (lineC.text.isNotEmpty && stationsC.text.isNotEmpty && trainsC.text.isNotEmpty) {
                try {
                  // Generate metro ID
                  String metroId = "M${(_metroList.length + 1).toString().padLeft(3, '0')}";
                  
                  // Add to Firestore
                  await _firestore.collection('metros').add({
                    'metroId': metroId,
                    'line': lineC.text,
                    'stations': stationsC.text,
                    'trains': int.tryParse(trainsC.text) ?? 0,
                    'frequency': frequencyC.text.isNotEmpty ? frequencyC.text : 'Every 10-15 mins',
                    'duration': durationC.text.isNotEmpty ? durationC.text : '30-45 mins',
                    'fare': fareC.text.isNotEmpty ? fareC.text : '₹20-₹40',
                    'firstTrain': firstTrainC.text.isNotEmpty ? firstTrainC.text : '6:00 AM',
                    'lastTrain': lastTrainC.text.isNotEmpty ? lastTrainC.text : '10:00 PM',
                    'createdAt': DateTime.now(),
                    'updatedAt': DateTime.now(),
                  });

                  // Clear controllers
                  _clearFields();

                  // Close dialog and reload data
                  Navigator.pop(context);
                  await _loadMetroData();

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Metro line "$metroId" added successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  print('Error adding metro: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to add metro line: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill required fields (Line, Stations, Trains)'),
                    backgroundColor: Colors.orange,
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

  // Edit existing metro line in Firestore
  void _editMetro(int index) {
    final metro = _metroList[index];
    lineC.text = metro['line'];
    stationsC.text = metro['stations'];
    trainsC.text = metro['trains'].toString();
    frequencyC.text = metro['frequency'] ?? '';
    durationC.text = metro['duration'] ?? '';
    fareC.text = metro['fare'] ?? '';
    firstTrainC.text = metro['firstTrain'] ?? '';
    lastTrainC.text = metro['lastTrain'] ?? '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Metro Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: lineC,
              decoration: const InputDecoration(labelText: "Line Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: stationsC,
              decoration: const InputDecoration(labelText: "Stations"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: trainsC,
              decoration: const InputDecoration(labelText: "No. of Trains"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: frequencyC,
              decoration: const InputDecoration(labelText: "Frequency"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: durationC,
              decoration: const InputDecoration(labelText: "Duration"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: fareC,
              decoration: const InputDecoration(labelText: "Fare"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: firstTrainC,
              decoration: const InputDecoration(labelText: "First Train"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: lastTrainC,
              decoration: const InputDecoration(labelText: "Last Train"),
            ),
          ],
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
              if (lineC.text.isNotEmpty && stationsC.text.isNotEmpty && trainsC.text.isNotEmpty) {
                try {
                  // Update in Firestore
                  await _firestore.collection('metros').doc(metro['id']).update({
                    'line': lineC.text,
                    'stations': stationsC.text,
                    'trains': int.tryParse(trainsC.text) ?? 0,
                    'frequency': frequencyC.text.isNotEmpty ? frequencyC.text : 'Every 10-15 mins',
                    'duration': durationC.text.isNotEmpty ? durationC.text : '30-45 mins',
                    'fare': fareC.text.isNotEmpty ? fareC.text : '₹20-₹40',
                    'firstTrain': firstTrainC.text.isNotEmpty ? firstTrainC.text : '6:00 AM',
                    'lastTrain': lastTrainC.text.isNotEmpty ? lastTrainC.text : '10:00 PM',
                    'updatedAt': DateTime.now(),
                  });

                  // Clear controllers
                  _clearFields();

                  // Close dialog and reload data
                  Navigator.pop(context);
                  await _loadMetroData();

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Metro line "${metro['metroId']}" updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  print('Error updating metro: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update metro line: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // Delete metro line from Firestore
  void _deleteMetro(int index) {
    final metro = _metroList[index];

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
                // Delete from Firestore
                await _firestore.collection('metros').doc(metro['id']).delete();

                // Close dialog and reload data
                Navigator.pop(context);
                await _loadMetroData();

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Metro line "${metro['metroId']}" deleted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                print('Error deleting metro: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete metro line: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
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
                  "Metro Management",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Manage metro lines, stations, and train counts",
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
                  label: const Text("Add Metro Line"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                
                const SizedBox(width: 10),
                
                // Initialize Sample Data button (for testing)
                OutlinedButton.icon(
                  onPressed: _initializeSampleMetroData,
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
                  "Metro Lines",
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
                    "${_metroList.length} lines",
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
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          "Loading metro data...",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : _metroList.isEmpty
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
                              "No Metro Lines Found",
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Add a new metro line or load sample data to get started",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _initializeSampleMetroData,
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
                            border: TableBorder.all(color: Colors.grey.shade200),
                            headingRowColor: MaterialStateProperty.all(Colors.purple.shade100),
                            columns: const [
                              DataColumn(
                                label: Text(
                                  "Metro ID",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Line Name",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Stations",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Trains",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Frequency",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Duration",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Fare",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "First Train",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Last Train",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Actions",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            rows: _metroList.asMap().entries.map((entry) {
                              int index = entry.key;
                              Map<String, dynamic> metro = entry.value;
                              return DataRow(
                                color: MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) {
                                    return index % 2 == 0
                                        ? Colors.grey.shade50
                                        : Colors.white;
                              }),
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
                                        metro['metroId'] ?? 'N/A',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.purple,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      metro['line'] ?? 'N/A',
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      metro['stations'] ?? 'N/A',
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
                                            metro['trains'].toString(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange.shade800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(metro['frequency'] ?? 'N/A')),
                                  DataCell(Text(metro['duration'] ?? 'N/A')),
                                  DataCell(Text(metro['fare'] ?? 'N/A')),
                                  DataCell(Text(metro['firstTrain'] ?? 'N/A')),
                                  DataCell(Text(metro['lastTrain'] ?? 'N/A')),
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