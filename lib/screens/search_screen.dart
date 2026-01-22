import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_application_1/models/route_suggstion_args.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Enum to represent the different transport modes
enum TransportMode { bus, train }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const double _navHeight = 75.0;
  final TextEditingController fromController =
      TextEditingController(text: "Pune");
  final TextEditingController toController =
      TextEditingController(text: "Mumbai");
  DateTime selectedDateTime = DateTime.now();

  int _page = 1;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  TransportMode _selectedMode = TransportMode.bus;
  int _notificationCount = 0;
  List<Map<String, String>> _notifications = [];

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Store buses from Firestore
  List<Map<String, dynamic>> _firestoreBuses = [];

  @override
  void initState() {
    super.initState();
    // Load data from Firestore
    _loadBusesFromFirestore();
  }

  // Load buses from Firestore
  Future<void> _loadBusesFromFirestore() async {
    try {
      final snapshot = await _firestore.collection('buses').get();
      setState(() {
        _firestoreBuses = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'route': data['route'] ?? '',
            'buses': data['buses']?.toString() ?? '0',
            'type': data['type'] ?? 'Electric',
            'price': data['price'] ?? '₹500',
            'from': data['from'] ?? 'Pune',
            'to': data['to'] ?? 'Mumbai',
            'rating': data['rating']?.toDouble() ?? 4.5,
            'stops': data['stops'] ?? 1,
          };
        }).toList();
      });
    } catch (e) {
      print('Error loading buses: $e');
    }
  }

  // Book ticket and save to Firestore
  Future<void> _bookTicket(String from, String to, String price) async {
    try {
      // Add to tickets collection
      await _firestore.collection('tickets').add({
        'from': from,
        'to': to,
        'date': selectedDateTime,
        'price': price,
        'bookingDate': DateTime.now(),
        'status': 'confirmed',
        'userId': 'user123', // You can replace with actual user ID
      });

      // Add notification
      _addNewTicketNotification(from, to);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ticket booked successfully! $from → $to'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error booking ticket: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to book ticket. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addNewTicketNotification(String from, String to) {
    setState(() {
      _notificationCount++;
      _notifications.add({
        'title': 'New Ticket Booked!',
        'message': 'Your ticket from $from to $to has been successfully booked.',
        'type': 'ticket',
        'time': 'Just now',
      });
    });
  }

  void _addNewDestinationBusNotification(String from, String to) {
    setState(() {
      _notificationCount++;
      _notifications.add({
        'title': 'New Route Available!',
        'message': 'Express bus service from $from to $to is now available with new passes!',
        'type': 'bus_route',
        'time': '5 min ago',
      });
    });
  }

  void _onNotificationTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationScreen(
          notifications: _notifications,
        ),
      ),
    ).then((_) {
      setState(() {
        _notificationCount = 0;
      });
    });
  }

  Future<void> pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
    );
    if (pickedTime == null) return;

    setState(() {
      selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  String getFormattedDateTime() {
    final month = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][selectedDateTime.month - 1];
    return "${selectedDateTime.day} $month, ${selectedDateTime.year}";
  }

  Widget routeOptionItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.15),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }

  void handleNavTap(int index) {
    setState(() => _page = index);

    if (index == 0) {
      Navigator.pushNamed(context, '/profile');
    } else if (index == 1) {
      // Stay here (Search Page)
    } else if (index == 2) {
      Navigator.pushNamed(context, '/accessibilityModeList');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/chatbot');
    }
  }

  (String, IconData) _getModeDetails() {
    switch (_selectedMode) {
      case TransportMode.bus:
        return ("Search Buses", Icons.directions_bus);
      case TransportMode.train:
        return ("Search Trains", Icons.train);
    }
  }

  Widget _buildTransportButton(
      TransportMode mode, String label, IconData icon) {
    final isSelected = _selectedMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMode = mode;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade600, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
    final (buttonText, buttonIcon) = _getModeDetails();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              buttonText,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 12),

            // From/To Fields
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "From",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.circle, size: 10, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              fromController.text,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz, color: Colors.grey),
                  onPressed: () {
                    String temp = fromController.text;
                    fromController.text = toController.text;
                    toController.text = temp;
                    setState(() {});
                  },
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "To",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, size: 18, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(
                              toController.text,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),

            // Date Picker Row
            InkWell(
              onTap: pickDateTime,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getFormattedDateTime(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const Text("Date", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Search Button
            ElevatedButton.icon(
              onPressed: () {
                // Add notifications
                _addNewTicketNotification(fromController.text, toController.text);
                _addNewDestinationBusNotification(fromController.text, toController.text);

                // Navigate
                Navigator.pushNamed(
                  context,
                  '/routeSuggestions',
                  arguments:
                      RouteSuggestionArgs(fromController.text, toController.text),
                );
              },
              icon: Icon(buttonIcon, size: 24),
              label: Text(
                buttonText,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularRoutes() {
    // UPDATED: Show both Firestore data and hardcoded routes
    final List<Map<String, dynamic>> allRoutes = [
      // Hardcoded routes (always shown)
      {
        'city1': "Pune",
        'city2': "Mumbai",
        'rating': 4.8,
        'price': "₹450",
        'stops': 1,
        'isFirestore': false,
      },
      {
        'city1': "Pune",
        'city2': "Nashik",
        'rating': 4.6,
        'price': "₹350",
        'stops': 0,
        'isFirestore': false,
      },
      {
        'city1': "Pune",
        'city2': "Goa",
        'rating': 4.7,
        'price': "₹900",
        'stops': 3,
        'isFirestore': false,
      },
      {
        'city1': "Pune",
        'city2': "Bangalore",
        'rating': 4.5,
        'price': "₹1200",
        'stops': 2,
        'isFirestore': false,
      },
      // Add Firestore routes (if available)
      ..._firestoreBuses.take(4).map((bus) {
        return {
          'city1': bus['from'] ?? 'Pune',
          'city2': bus['to'] ?? 'Destination',
          'rating': bus['rating'] ?? 4.5,
          'price': bus['price'] ?? '₹500',
          'stops': bus['stops'] ?? 1,
          'isFirestore': true,
        };
      }).toList(),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Popular Routes from Pune",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
              child: const Text("View All",
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // FIXED: Using SingleChildScrollView for horizontal scrolling
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: allRoutes.take(8).map((route) {
              return Container(
                width: 150,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: route['isFirestore'] ? Colors.blue.shade50 : null,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.yellow.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.orange, size: 14),
                                  const SizedBox(width: 4),
                                  Text(route['rating'].toStringAsFixed(1), 
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            if (route['isFirestore'])
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  "Live",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text("${route['city1']} - ${route['city2']}",
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text("${route['stops']} stops", 
                            style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 8),
                        Text(route['price'],
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialOffers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Special Offers",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.orange.shade700, Colors.deepOrange.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "20% OFF",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900),
                    ),
                    Text(
                      "Limited Offer - Book Now!",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
                Icon(Icons.local_offer, color: Colors.white, size: 40),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // UPDATED WIDGET: Build the dynamic recommended destinations list for Pune
  Widget _buildRecommendedRoutes() {
    late String titleText;
    late List<Map<String, dynamic>> routeData;
    late IconData modeIcon;
    late Color iconColor;

    // Define different sets of recommendations based on the selected mode
    switch (_selectedMode) {
      case TransportMode.bus:
        titleText = "Top Bus Routes from Pune 🚌";
        modeIcon = Icons.directions_bus;
        iconColor = Colors.green.shade700;
        
        // Combine hardcoded routes with Firestore routes
        final hardcodedRoutes = [
          {"title": "Pune to Shirdi", "subtitle": "Pilgrimage special buses", "isFirestore": false},
          {"title": "Pune to Kolhapur", "subtitle": "Frequent state transport", "isFirestore": false},
          {"title": "Pune to Hyderabad", "subtitle": "Overnight sleeper service", "isFirestore": false},
        ];
        
        // Get Firestore routes
        final firestoreRoutes = _firestoreBuses.take(3).map((bus) {
          return {
            "title": "${bus['from']} to ${bus['to']}",
            "subtitle": "${bus['type']} - ${bus['price']}",
            "isFirestore": true,
          };
        }).toList();
        
        // Combine routes (Firestore first, then hardcoded)
        routeData = [...firestoreRoutes, ...hardcodedRoutes].take(3).toList();
        break;
        
      case TransportMode.train:
        titleText = "Top Train Routes from Pune 🚆";
        modeIcon = Icons.train;
        iconColor = Colors.blue.shade700;
        routeData = [
          {"title": "Pune to Nagpur", "subtitle": "Maharastra Express available", "isFirestore": false},
          {"title": "Pune to Delhi", "subtitle": "High-speed Rajdhani", "isFirestore": false},
          {"title": "Pune to Chennai", "subtitle": "South India connectivity", "isFirestore": false},
        ];
        break;
    }

    // Build the list of routeOptionItem widgets
    List<Widget> routeItems = routeData.map((data) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        color: data['isFirestore'] == true ? Colors.blue.shade50 : null,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.15),
            child: Icon(modeIcon, color: iconColor),
          ),
          title: Row(
            children: [
              Text(
                data['title']!,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              if (data['isFirestore'] == true)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "Live",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Text(data['subtitle']!),
          onTap: () {
            final parts = data['title']!.split(' to ');
            if (parts.length == 2) {
              Navigator.pushNamed(
                context,
                '/routeSuggestions',
                arguments: RouteSuggestionArgs(parts[0], parts[1]),
              );
            }
          },
        ),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titleText,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        ...routeItems, // Spread the list of widgets here
        const SizedBox(height: 20),
      ],
    );
  }

  // --- MAIN BUILD METHOD (FIXED VERSION) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      
       bottomNavigationBar: SafeArea(
  top: false,
  child: CurvedNavigationBar(
    key: _bottomNavigationKey,
    index: 1,
    height: 70, 
    backgroundColor: Colors.transparent,
    color: Colors.blue.shade600,
    buttonBackgroundColor: Colors.blue.shade800,
    items: const [
      Icon(Icons.person, size: 30, color: Colors.white),
      Icon(Icons.search, size: 30, color: Colors.white),
      Icon(Icons.accessibility_new, size: 30, color: Colors.white),
      Icon(Icons.chat_bubble_outline, size: 30, color: Colors.white),
    ],
    onTap: handleNavTap,
  ),
),

      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 16,
            right: 16,
            bottom: 0
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Welcome Header
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back! 👋',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Ready for your next adventure?',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _onNotificationTap,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.blue.shade100,
                            child: const Icon(Icons.notifications_none,
                                color: Colors.blue),
                          ),
                          if (_notificationCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  _notificationCount.toString(),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 10),
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTransportButton(
                          TransportMode.bus, "Bus", Icons.directions_bus),
                      const SizedBox(width: 8),
                      _buildTransportButton(
                          TransportMode.train, "Train", Icons.train),
                    ],
                  ),
                ),

                _buildSearchCard(),
                _buildPopularRoutes(),
                const SizedBox(height: 16),
                _buildSpecialOffers(),
                _buildRecommendedRoutes(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ⭐️ NEW: Notification Screen Widget for displaying notifications
class NotificationScreen extends StatelessWidget {
  final List<Map<String, String>> notifications;

  const NotificationScreen({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    'No new notifications.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Icon(
                      notification['type'] == 'ticket'
                          ? Icons.airplane_ticket
                          : Icons.location_city,
                      color: notification['type'] == 'ticket'
                          ? Colors.green
                          : Colors.orange,
                    ),
                    title: Text(
                      notification['title']!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(notification['message']!),
                    trailing: Text(
                      notification['time']!,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                );
              },
            ),
    );
  }
}