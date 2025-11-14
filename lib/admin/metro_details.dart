import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MetroDetailsPage extends StatefulWidget {
  const MetroDetailsPage({super.key});

  @override
  State<MetroDetailsPage> createState() => _MetroDetailsPageState();
}

class _MetroDetailsPageState extends State<MetroDetailsPage> {
  List<Map<String, String>> metroList = [
    {
      "id": "M001",
      "line": "Purple Line",
      "stations": "PCMC → Civil Court",
      "trains": "12"
    },
    {
      "id": "M002",
      "line": "Aqua Line",
      "stations": "Vanaz → Ramwadi",
      "trains": "9"
    },
  ];

  final TextEditingController lineC = TextEditingController();
  final TextEditingController stationsC = TextEditingController();
  final TextEditingController trainsC = TextEditingController();

  void _addMetro() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Metro Line"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: lineC, decoration: const InputDecoration(labelText: "Line Name")),
            TextField(controller: stationsC, decoration: const InputDecoration(labelText: "Stations")),
            TextField(
                controller: trainsC,
                decoration: const InputDecoration(labelText: "No. of Trains"),
                keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (lineC.text.isNotEmpty && stationsC.text.isNotEmpty && trainsC.text.isNotEmpty) {
                setState(() {
                  metroList.add({
                    "id": "M${(metroList.length + 1).toString().padLeft(3, '0')}",
                    "line": lineC.text,
                    "stations": stationsC.text,
                    "trains": trainsC.text,
                  });
                });
                lineC.clear();
                stationsC.clear();
                trainsC.clear();
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _editMetro(int index) {
    lineC.text = metroList[index]["line"]!;
    stationsC.text = metroList[index]["stations"]!;
    trainsC.text = metroList[index]["trains"]!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Metro Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: lineC, decoration: const InputDecoration(labelText: "Line Name")),
            TextField(controller: stationsC, decoration: const InputDecoration(labelText: "Stations")),
            TextField(
                controller: trainsC,
                decoration: const InputDecoration(labelText: "No. of Trains"),
                keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                metroList[index]["line"] = lineC.text;
                metroList[index]["stations"] = stationsC.text;
                metroList[index]["trains"] = trainsC.text;
              });
              lineC.clear();
              stationsC.clear();
              trainsC.clear();
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _deleteMetro(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Metro Line"),
        content: const Text("Are you sure you want to delete this line?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() => metroList.removeAt(index));
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
        Text("Metro Details",
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text("Manage metro/train lines, stations, and train counts.",
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade700)),
        const SizedBox(height: 20),

        // Add button
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton.icon(
            onPressed: _addMetro,
            icon: const Icon(Icons.add),
            label: const Text("Add Metro Line"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Metro details table
        Expanded(
          child: SingleChildScrollView(
            child: DataTable(
              border: TableBorder.all(color: Colors.grey.shade300),
              headingRowColor: WidgetStateProperty.all(Colors.green.shade100),
              columns: const [
                DataColumn(label: Text("Metro ID")),
                DataColumn(label: Text("Line")),
                DataColumn(label: Text("Stations")),
                DataColumn(label: Text("Trains")),
                DataColumn(label: Text("Actions")),
              ],
              rows: metroList.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, String> metro = entry.value;
                return DataRow(cells: [
                  DataCell(Text(metro["id"]!)),
                  DataCell(Text(metro["line"]!)),
                  DataCell(Text(metro["stations"]!)),
                  DataCell(Text(metro["trains"]!)),
                  DataCell(Row(
                    children: [
                      IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editMetro(index)),
                      IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteMetro(index)),
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
