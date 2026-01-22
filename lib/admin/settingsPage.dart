import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  bool _maintenanceMode = false;
  bool _pushSystemAlerts = true;
  String _selectedRegion = "All Pune";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          "System Administration",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.indigo.shade800,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAdminHeader(),
          const SizedBox(height: 24),

          // ================= SYSTEM CONTROL =================
          _buildSectionHeader("System Control"),
          _buildAdminCard([
            _buildSwitchTile(
              Icons.tune,
              "Maintenance Mode",
              "Restrict user access during updates",
              _maintenanceMode,
              (v) => setState(() => _maintenanceMode = v),
              Colors.orange,
            ),
            _buildDivider(),
            _buildActionTile(
              Icons.notification_important,
              "Broadcast Emergency Alert",
              "Send push notification to all Pune users",
              () => _showBroadcastDialog(),
              Colors.red,
            ),
          ]),

          const SizedBox(height: 24),

          // ================= DATA & USER MANAGEMENT =================
          _buildSectionHeader("Data & User Management"),
          _buildAdminCard([
            _buildActionTile(
              Icons.people_alt,
              "User Moderation",
              "Manage 12,400+ active commuters",
              () {},
              Colors.blue,
            ),
            _buildDivider(),
            _buildActionTile(
              Icons.analytics_outlined,
              "Export System Logs",
              "Download CSV of weekly performance",
              () {},
              Colors.green,
            ),
            _buildDivider(),
            _buildActionTile(
              Icons.map_outlined,
              "Route Configuration",
              "Update PMPML & Metro stop coordinates",
              () {},
              Colors.purple,
            ),
          ]),

          const SizedBox(height: 24),

          // ================= CONFIGURATION =================
          _buildSectionHeader("Global Configuration"),
          _buildAdminCard([
            _buildDropdownTile(
              Icons.location_city,
              "Primary Region",
              _selectedRegion,
              ["All Pune", "PMC Area", "PCMC Area", "Hinjewadi IT Park"],
              (val) => setState(() => _selectedRegion = val!),
            ),
            _buildDivider(),
            _buildSwitchTile(
              Icons.speed,
              "Auto-Update GTFS Data",
              "Sync real-time transit feeds every 5 min",
              _pushSystemAlerts,
              (v) => setState(() => _pushSystemAlerts = v),
              Colors.indigo,
            ),
          ]),

          const SizedBox(height: 40),
          
          Center(
            child: Text(
              "Smart Pune Commute Admin • v2.4.0-Enterprise",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ================= UI COMPONENTS =================

  Widget _buildAdminHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.indigo.shade800, Colors.indigo.shade500]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 35),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Admin Console", 
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              Text("Last login: Today, 10:45 AM", 
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.indigo)),
    );
  }

  Widget _buildActionTile(IconData icon, String title, String sub, VoidCallback onTap, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(sub, style: GoogleFonts.poppins(fontSize: 11)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, String sub, bool val, Function(bool) onChanged, Color color) {
    return SwitchListTile.adaptive(
      secondary: Icon(icon, color: color),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(sub, style: GoogleFonts.poppins(fontSize: 11)),
      value: val,
      onChanged: onChanged,
      activeColor: color,
    );
  }

  Widget _buildDropdownTile(IconData icon, String title, String value, List<String> items, Function(String?) onChanged) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDivider() => Divider(height: 1, indent: 50, color: Colors.grey.shade200);

  void _showBroadcastDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Broadcast Alert"),
        content: const TextField(
          decoration: InputDecoration(hintText: "Enter emergency message for Pune commuters..."),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context),
            child: const Text("Send Now"),
          ),
        ],
      ),
    );
  }
}