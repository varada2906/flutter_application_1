import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageRoutesPage extends StatefulWidget {
  const ManageRoutesPage({super.key});

  @override
  State<ManageRoutesPage> createState() => _ManageRoutesPageState();
}

class _ManageRoutesPageState extends State<ManageRoutesPage> {
  List<Map<String, String>> routes = [
    {"id": "R001", "from": "Swargate", "to": "Kothrud", "busNo": "PMPML-101"},
    {"id": "R002", "from": "Hadapsar", "to": "Hinjewadi", "busNo": "PMPML-202"},
    {"id": "R003", "from": "Shivaji Nagar", "to": "Akurdi", "busNo": "PMPML-303"},
  ];

  final TextEditingController fromC = TextEditingController();
  final TextEditingController toC = TextEditingController();
  final TextEditingController busNoC = TextEditingController();

  void _addRoute() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add New Route"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: fromC, decoration: const InputDecoration(labelText: "From")),
            TextField(controller: toC, decoration: const InputDecoration(labelText: "To")),
            TextField(controller: busNoC, decoration: const InputDecoration(labelText: "Bus No")),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (fromC.text.isNotEmpty && toC.text.isNotEmpty && busNoC.text.isNotEmpty) {
                setState(() {
                  routes.add({
                    "id": "R${(routes.length + 1).toString().padLeft(3, '0')}",
                    "from": fromC.text,
                    "to": toC.text,
                    "busNo": busNoC.text
                  });
                });
                fromC.clear();
                toC.clear();
                busNoC.clear();
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _editRoute(int index) {
    fromC.text = routes[index]["from"]!;
    toC.text = routes[index]["to"]!;
    busNoC.text = routes[index]["busNo"]!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Route"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: fromC, decoration: const InputDecoration(labelText: "From")),
            TextField(controller: toC, decoration: const InputDecoration(labelText: "To")),
            TextField(controller: busNoC, decoration: const InputDecoration(labelText: "Bus No")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                routes[index]["from"] = fromC.text;
                routes[index]["to"] = toC.text;
                routes[index]["busNo"] = busNoC.text;
              });
              fromC.clear();
              toC.clear();
              busNoC.clear();
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _deleteRoute(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Route"),
        content: const Text("Are you sure you want to delete this route?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() => routes.removeAt(index));
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
        Text("Manage Routes",
            style: GoogleFonts.poppins(
                fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text("Add, edit or delete transport routes easily.",
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade700)),
        const SizedBox(height: 20),

        // Add button
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton.icon(
            onPressed: _addRoute,
            icon: const Icon(Icons.add),
            label: const Text("Add Route"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Route list table
        Expanded(
          child: SingleChildScrollView(
            child: DataTable(
              border: TableBorder.all(color: Colors.grey.shade300),
              headingRowColor: WidgetStateProperty.all(Colors.green.shade100),
              columns: const [
                DataColumn(label: Text("Route ID")),
                DataColumn(label: Text("From")),
                DataColumn(label: Text("To")),
                DataColumn(label: Text("Bus No")),
                DataColumn(label: Text("Actions")),
              ],
              rows: routes.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, String> route = entry.value;
                return DataRow(cells: [
                  DataCell(Text(route["id"]!)),
                  DataCell(Text(route["from"]!)),
                  DataCell(Text(route["to"]!)),
                  DataCell(Text(route["busNo"]!)),
                  DataCell(Row(
                    children: [
                      IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editRoute(index)),
                      IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteRoute(index)),
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
