import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/admin/PerformancePage.dart';
import 'package:flutter_application_1/admin/analytics_page.dart';
import 'package:flutter_application_1/admin/bus_transport.dart';
import 'package:flutter_application_1/admin/manage_routes.dart';
import 'package:flutter_application_1/admin/metro_details.dart';
import 'package:flutter_application_1/admin/settingsPage.dart';
import 'package:flutter_application_1/admin/ticket_manager.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;

  // Updated menu items to include User Management
  final List<String> menuItems = [
    "Dashboard",
    "Manage Routes",
    "Metro Details",
    "Bus Details",
    "Tickets",
    "Analytics",
    "Performance",
    "User Management",  // New
    "Settings"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Row(
        children: [
          // ================= SIDEBAR =================
          Container(
            width: 250,
            color: Colors.green.shade700,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Text(
                  "Smart Pune Commute",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                
                // Sidebar Menu Items
                for (int i = 0; i < menuItems.length; i++)
                  ListTile(
                    selected: selectedIndex == i,
                    selectedTileColor: Colors.green.shade400,
                    leading: Icon(
                      _getIconForMenu(menuItems[i]),
                      color: Colors.white,
                      size: 20,
                    ),
                    title: Text(
                      menuItems[i],
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: selectedIndex == i
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    onTap: () => setState(() => selectedIndex = i),
                  ),
                  
                const Spacer(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title: const Text("Logout", style: TextStyle(color: Colors.white)),
                  onTap: () {
                    // Add logout logic here
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // ================= MAIN CONTENT =================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: _buildPage(selectedIndex),
            ),
          ),
        ],
      ),
    );
  }

  // Icon Helper Function
  IconData _getIconForMenu(String title) {
    switch (title) {
      case "Dashboard": return Icons.dashboard;
      case "Manage Routes": return Icons.map;
      case "Metro Details": return Icons.train;
      case "Bus Details": return Icons.directions_bus;
      case "Analytics": return Icons.analytics;
      case "Performance": return Icons.speed;
      case "Settings": return Icons.settings;
      case "Tickets": return Icons.confirmation_number;
      case "User Management": return Icons.people; // New
      default: return Icons.circle;
    }
  }

  // Page Router Function
  Widget _buildPage(int index) {
    switch (index) {
      case 0: return _dashboardPage();
      case 1: return const ManageRoutesPage();
      case 2: return const MetroSearchScreen();
      case 3: return const BusDetailsPage();
      case 4: return const AdminTicketPage();
      case 5: return const AnalyticsPage();
      case 6: return const PerformancePage();
      case 7: return const UserManagementPage(); // New
      case 8: return const AdminSettingsPage();
      default: return const Center(child: Text("Page not found"));
    }
  }

  // ================= DASHBOARD FRAGMENT =================
  Widget _dashboardPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Admin Dashboard",
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            _infoCard("Total Buses", "120"),
            _infoCard("Total Trains", "18"),
            _infoCard("Active Routes", "45"),
            _infoCard("Delayed Services", "3"),
            _infoCard("Total Users", "1,234"), // Added user count
            _infoCard("New Users Today", "24"), // Added today's users
          ],
        ),

        const SizedBox(height: 40),
        Text(
          "Ridership & Mode Overview",
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),

        Expanded(
          child: Row(
            children: [
              // Line Chart
              Expanded(
                flex: 2,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: const FlTitlesData(show: true),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        spots: const [
                          FlSpot(0, 2), FlSpot(1, 3), FlSpot(2, 5),
                          FlSpot(3, 4), FlSpot(4, 7), FlSpot(5, 8),
                        ],
                        color: Colors.green,
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.greenAccent.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 30),
              // Pie Chart
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Text(
                      "Mode Usage Share",
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          centerSpaceRadius: 40,
                          sections: [
                            _buildPieSection(55, "Bus\n55%", Colors.green),
                            _buildPieSection(30, "Train\n30%", Colors.orange),
                            _buildPieSection(15, "Metro\n15%", Colors.blue),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  PieChartSectionData _buildPieSection(double value, String title, Color color) {
    return PieChartSectionData(
      color: color,
      value: value,
      title: title,
      radius: 70,
      titleStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600)),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

// ================= USER MANAGEMENT PAGE =================
class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterRole = 'all';
  int _totalUsers = 0;
  int _activeUsers = 0;
  int _newUsersToday = 0;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      final users = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
          'timestamp': (data['createdAt'] as Timestamp?)?.toDate(),
        };
      }).toList();

      // Calculate statistics
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      _totalUsers = users.length;
      _activeUsers = users.where((user) => user['status'] == 'active').length;
      _newUsersToday = users.where((user) {
        final createdAt = user['timestamp'];
        return createdAt != null && createdAt.isAfter(today);
      }).length;

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching users: $e");
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    var filtered = _users;
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        final email = user['email']?.toString().toLowerCase() ?? '';
        final name = user['name']?.toString().toLowerCase() ?? '';
        final phone = user['phone']?.toString().toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        
        return email.contains(query) || 
               name.contains(query) || 
               phone.contains(query);
      }).toList();
    }
    
    // Filter by role
    if (_filterRole != 'all') {
      filtered = filtered.where((user) {
        return user['role'] == _filterRole;
      }).toList();
    }
    
    // Sort by latest first
    filtered.sort((a, b) {
      final aTime = a['timestamp'] ?? DateTime(2000);
      final bTime = b['timestamp'] ?? DateTime(2000);
      return bTime.compareTo(aTime);
    });
    
    return filtered;
  }

  Future<void> _updateUserStatus(String userId, String status) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Update local state
      setState(() {
        final index = _users.indexWhere((user) => user['id'] == userId);
        if (index != -1) {
          _users[index]['status'] = status;
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User ${status == 'active' ? 'activated' : 'deactivated'}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteUser(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firestore.collection('users').doc(userId).delete();
        
        setState(() {
          _users.removeWhere((user) => user['id'] == userId);
          _totalUsers--;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'admin':
        return Colors.purple;
      case 'driver':
        return Colors.blue;
      case 'user':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    "User Management",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Manage all registered users and their accounts",
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Statistics Cards (in your style)
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      _buildStatCard("Total Users", _totalUsers.toString(), Icons.people, Colors.blue),
                      _buildStatCard("Active Users", _activeUsers.toString(), Icons.check_circle, Colors.green),
                      _buildStatCard("New Today", _newUsersToday.toString(), Icons.new_releases, Colors.orange),
                      _buildStatCard("Admins", _users.where((u) => u['role'] == 'admin').length.toString(), 
                          Icons.admin_panel_settings, Colors.purple),
                      _buildStatCard("Drivers", _users.where((u) => u['role'] == 'driver').length.toString(), 
                          Icons.drive_eta, Colors.blue),
                      _buildStatCard("Regular Users", _users.where((u) => u['role'] == 'user').length.toString(), 
                          Icons.person, Colors.green),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Search and Filter Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 2))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Filters",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search by email, name, or phone...',
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _filterRole,
                                  items: [
                                    DropdownMenuItem(
                                      value: 'all',
                                      child: Text('All Roles', style: GoogleFonts.poppins(color: Colors.grey.shade700)),
                                    ),
                                    DropdownMenuItem(
                                      value: 'admin',
                                      child: Row(
                                        children: [
                                          Icon(Icons.admin_panel_settings, size: 16, color: Colors.purple),
                                          const SizedBox(width: 8),
                                          Text('Admin', style: GoogleFonts.poppins()),
                                        ],
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'driver',
                                      child: Row(
                                        children: [
                                          Icon(Icons.drive_eta, size: 16, color: Colors.blue),
                                          const SizedBox(width: 8),
                                          Text('Driver', style: GoogleFonts.poppins()),
                                        ],
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'user',
                                      child: Row(
                                        children: [
                                          Icon(Icons.person, size: 16, color: Colors.green),
                                          const SizedBox(width: 8),
                                          Text('User', style: GoogleFonts.poppins()),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _filterRole = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Users Table
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 2))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Users (${_filteredUsers.length})",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: _fetchUsers,
                              tooltip: 'Refresh',
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        if (_filteredUsers.isEmpty)
                          Center(
                            child: Column(
                              children: [
                                Icon(Icons.people_outline, size: 60, color: Colors.grey.shade400),
                                const SizedBox(height: 10),
                                Text(
                                  'No users found',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 30,
                              columns: [
                                DataColumn(label: Text('User', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
                                DataColumn(label: Text('Email', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
                                DataColumn(label: Text('Role', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
                                DataColumn(label: Text('Phone', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
                                DataColumn(label: Text('Joined', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
                                DataColumn(label: Text('Status', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
                                DataColumn(label: Text('Actions', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
                              ],
                              rows: _filteredUsers.map((user) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: _getRoleColor(user['role']),
                                            child: Text(
                                              user['name']?.toString().substring(0, 1).toUpperCase() ?? 'U',
                                              style: const TextStyle(color: Colors.white),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                user['name']?.toString() ?? 'No Name',
                                                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                                              ),
                                              Text(
                                                'ID: ${user['id'].substring(0, 8)}...',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        user['email']?.toString() ?? 'N/A',
                                        style: GoogleFonts.poppins(),
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: _getRoleColor(user['role']).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: _getRoleColor(user['role']).withOpacity(0.3)),
                                        ),
                                        child: Text(
                                          user['role']?.toString().toUpperCase() ?? 'USER',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: _getRoleColor(user['role']),
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        user['phone']?.toString() ?? 'N/A',
                                        style: GoogleFonts.poppins(),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        user['timestamp'] != null
                                            ? DateFormat('MMM dd, yyyy').format(user['timestamp'])
                                            : 'N/A',
                                        style: GoogleFonts.poppins(),
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: user['status'] == 'active' 
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: user['status'] == 'active' 
                                                ? Colors.green.withOpacity(0.3)
                                                : Colors.red.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Text(
                                          user['status']?.toString().toUpperCase() ?? 'ACTIVE',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: user['status'] == 'active' ? Colors.green : Colors.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              user['status'] == 'active' 
                                                  ? Icons.block 
                                                  : Icons.check_circle,
                                              color: user['status'] == 'active' ? Colors.red : Colors.green,
                                              size: 20,
                                            ),
                                            onPressed: () => _updateUserStatus(
                                              user['id'],
                                              user['status'] == 'active' ? 'inactive' : 'active',
                                            ),
                                            tooltip: user['status'] == 'active' ? 'Deactivate' : 'Activate',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                            onPressed: () => _deleteUser(user['id']),
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}