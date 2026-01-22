import 'package:flutter/material.dart';
import 'package:flutter_application_1/admin/admin_dash.dart';
import 'package:flutter_application_1/admin/metro_details.dart';
import 'package:flutter_application_1/driver/driver_dashboard.dart';
import 'package:flutter_application_1/driver/end_trip_screen.dart';
import 'package:flutter_application_1/driver/live_location_screen.dart';
import 'package:flutter_application_1/driver/route_info_screen.dart';
import 'package:flutter_application_1/screens/accessiblity/accessibility_instruction_screen.dart';
import 'package:flutter_application_1/screens/accessiblity/accessibilty_mode_list_screen.dart';
import 'package:flutter_application_1/screens/chatgpt_controller.dart';
import 'package:flutter_application_1/screens/feedback/passenger_flow_prediction.dart';
import 'package:flutter_application_1/screens/feedback_screen.dart';
import 'package:flutter_application_1/screens/metrodetailsPage.dart';
import 'package:flutter_application_1/screens/payment_succesful.dart';
import 'package:flutter_application_1/screens/predictive_alerts.dart';
import 'package:flutter_application_1/screens/route_suggestion_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/auth/login_page.dart';
import '../screens/auth/signup_page.dart';
import '../screens/search_screen.dart';
import '../screens/profile_screen.dart';

import '../screens/feedback/feedback_screen.dart';

import '../screens/purchase_flow/purchase_screen.dart';
import '../screens/purchase_flow/instruction_screen.dart';


class SmartPuneCommuteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Pune Commute',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      home: SplashScreen(),
      routes: {
        '/welcome': (_) => WelcomeScreen(),
        '/login': (_) => LoginPage(),
        '/signup': (_) => SignUpPage(),
        '/search': (_) => SearchScreen(),
        '/routeSuggestions': (_) => RouteSuggestionsScreen(),
        '/profile': (_) => ProfileScreen(),
        '/predictiveAlerts': (_) => PredictiveAlertsScreen(),
        '/paymentSuccess': (_) => PaymentPage (),
        '/feedback': (_) => FeedbackScreen(),
        '/feedbackDetail': (_) => FeedbackDetailScreen(),
        '/passengerFlowPrediction': (_) => PassengerFlowPredictionScreen(),
        '/purchase': (_) => PurchaseScreen(),
        '/instruction': (_) => InstructionScreen(),
        '/accessibilityModeList': (_) => AccessibilityModeListScreen(),
        '/accessibilityInstruction': (_) => AccessibilityInstructionScreen(),
         '/chatbot': (context) => ChatScreen(),
         '/adminDashboard': (context) => AdminDashboard(),
         '/driverDashboard': (context) =>  DriverDashboard(),
         '/driver/routeInfo': (context) => const RouteInfoScreen(),
        '/driver/liveLocation': (context) => const LiveLocationScreen(),
        '/driver/endTrip': (context) => const EndTripScreen(),
       '/metro-search': (context) => MetroSearchScreen(), // Metro search for users
     '/metro-management': (context) => MetroDetailsPage(), // Admin metro management

     
      },
    );
  }
}