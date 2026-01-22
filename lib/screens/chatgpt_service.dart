import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatGPTService { // Class name is ChatGPTService
  // ⚠️ NOTE: Replace with your actual, secure API Key
  static const String apiKey = "AIzaSyBOz1313X3SPz3oyWg_0tW6PxBUYiTYOrI";
  static const String modelName = "gemini-2.0-flash";
  static const int timeoutSeconds = 30;

  // Smart Pune Commute-only rules
  static const String commuteSystemInstruction = """
You are a Smart Pune Commute Expert. Your knowledge is STRICTLY limited to commute, traffic, and public transport topics related to Pune, Maharashtra, India.

ALLOWED TOPICS (Focusing on Pune/PCMC Area):
- Real-time traffic conditions and delays (simulated advice if real data isn't available).
- Public transport routes (PMPML buses, Metro lines, suburban rail).
- Optimal travel modes (bus, metro, auto, cab, personal vehicle).
- Estimated commute times between two locations in Pune.
- Parking availability advice in key Pune areas (e.g., Deccan, FC Road, Hinjewadi).
- Tolls, traffic rules, and road conditions in Pune.
- Weather impact on Pune travel.

STRICTLY PROHIBITED TOPICS:
- Politics, religion, or sensitive topics.
- Medical, health, or fitness advice.
- Financial or investment advice.
- Food, recipes, or cooking.
- Fashion or clothing advice.
- Any non-commute or non-Pune related topics.

RESPONSE RULES:
1. Theme/Style & Formatting: Your response must use a polite, helpful, and "smart city" tone. Start the response with a blue square emoji (🟦). DO NOT use any markdown formatting, including bolding (**), italics (*), or numbered/bulleted lists. Provide plain text only.
2. If the question is about Pune commute/travel: Provide concise and helpful advice.
3. If not about Pune commute/travel: Say "🟦 I specialize only in Pune and PCMC commute information. How can I help you with your journey today?"
""";

  static Future<String> getCommuteResponse(String userInput) async {
    try {
      final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey",
      );

      final body = jsonEncode({
        "contents": [
          {
            "role": "user",
            "parts": [
              {"text": "$commuteSystemInstruction\n\nUser: $userInput"}
            ]
          }
        ],
        "generationConfig": { // CORRECTED: This is the correct parameter name for the Gemini API
          "temperature": 0.5, 
          "topK": 40,
          "topP": 0.95,
          "maxOutputTokens": 1024
        }
      });

      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json; charset=UTF-8"},
            body: body,
          )
          .timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('candidates') &&
            data['candidates'] != null &&
            data['candidates'].isNotEmpty) {
          final text =
              data['candidates'][0]['content']['parts'][0]['text'].trim();
          return text.isNotEmpty
              ? text
              : "🟦 Oops! The Commute AI couldn't formulate a route for that. Try a specific landmark or area in Pune.";
        } else {
          // Handle cases where AI response is blocked/empty
          return "🟦 The Smart Commute assistant didn't return any response. Please try again later.";
        }
      } else {
        print("❌ HTTP Error: ${response.statusCode}");
        print(response.body);
        return "🟦 The Pune Commute service is currently unavailable. Please check your network connection.";
      }
    } catch (e) {
      print("⚠ Exception: $e");
      return "🟦 I'm having trouble connecting to the traffic server right now. Please try again with your commute question.";
    }
  }

  // Exposed function for the app to use
  static Future<String> getAIResponse(String userInput) async {
    // This is the function called by the public interface
    return getCommuteResponse(userInput);
  }
}