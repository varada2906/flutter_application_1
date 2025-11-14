import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BusDetailsPage extends StatefulWidget {
  const BusDetailsPage({super.key});

  @override
  State<BusDetailsPage> createState() => _BusDetailsPageState();
}

class _BusDetailsPageState extends State<BusDetailsPage> {
  List<Map<String, String>> busList = [
    {
      "id": "B001",
      "route": "Swargate → Katraj",
      "buses": "15",
      "type": "Electric"
    },
    {
      "id": "B002",
      "route": "PMC → Hinjewadi",
      "buses": "20",
      "type": "Diesel"
    },
  ];

  final TextEditingController routeC = TextEditingController();
  final TextEditingController busesC = TextEditingController();
  final TextEditingController typeC = TextEditingController();

  void _addBus() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Bus Route"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: routeC, decoration: const InputDecoration(labelText: "Route")),
            TextField(
              controller: busesC,
              decoration: const InputDecoration(labelText: "No. of Buses"),
              keyboardType: TextInputType.number,
            ),
            TextField(controller: typeC, decoration: const InputDecoration(labelText: "Bus Type (Electric/Diesel)")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (routeC.text.isNotEmpty && busesC.text.isNotEmpty && typeC.text.isNotEmpty) {
                setState(() {
                  busList.add({
                    "id": "B${(busList.length + 1).toString().padLeft(3, '0')}",
                    "route": routeC.text,
                    "buses": busesC.text,
                    "type": typeC.text,
                  });
                });
                routeC.clear();
                busesC.clear();
                typeC.clear();
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _editBus(int index) {
    routeC.text = busList[index]["route"]!;
    busesC.text = busList[index]["buses"]!;
    typeC.text = busList[index]["type"]!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Bus Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: routeC, decoration: const InputDecoration(labelText: "Route")),
            TextField(
              controller: busesC,
              decoration: const InputDecoration(labelText: "No. of Buses"),
              keyboardType: TextInputType.number,
            ),
            TextField(controller: typeC, decoration: const InputDecoration(labelText: "Bus Type")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                busList[index]["route"] = routeC.text;
                busList[index]["buses"] = busesC.text;
                busList[index]["type"] = typeC.text;
              });
              routeC.clear();
              busesC.clear();
              typeC.clear();
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _deleteBus(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Bus Route"),
        content: const Text("Are you sure you want to delete this route?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() => busList.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
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
              headingRowColor: WidgetStateProperty.all(Colors.blue.shade100),
              columns: const [
                DataColumn(label: Text("Bus ID")),
                DataColumn(label: Text("Route")),
                DataColumn(label: Text("No. of Buses")),
                DataColumn(label: Text("Type")),
                DataColumn(label: Text("Actions")),
              ],
              rows: busList.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, String> bus = entry.value;
                return DataRow(cells: [
                  DataCell(Text(bus["id"]!)),
                  DataCell(Text(bus["route"]!)),
                  DataCell(Text(bus["buses"]!)),
                  DataCell(Text(bus["type"]!)),
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
