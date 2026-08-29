import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatGPTService {
  // तुझी API key
  static const String apiKey = "AIzaSyBySse3NjatONwk1EoYGwYqDNKdFeG6NUw";
  static const int timeoutSeconds = 30;
  
  // ✅ फक्त एक model (हे try कर)
  static const String modelName = "gemini-2.5-flash";

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

  // ✅ साधा आणि सोपा function
  static Future<String> getCommuteResponse(String userInput) async {
    try {
      // v1 API endpoint
      final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1/models/$modelName:generateContent?key=$apiKey",
      );
      
      print("📤 Sending request...");
      
      final body = jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": "$commuteSystemInstruction\n\nUser: $userInput"}
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.5,
          "maxOutputTokens": 1024,
        }
      });

      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: body,
          )
          .timeout(const Duration(seconds: timeoutSeconds));

      print("📥 Status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String text = data['candidates'][0]['content']['parts'][0]['text'];
        return text.startsWith('🟦') ? text : '🟦 $text';
      } else {
        print("❌ Error: ${response.body}");
        
        // सोपे error messages
        if (response.statusCode == 404) {
          return "🟦 Model सध्या उपलब्ध नाही. कृपया नंतर प्रयत्न करा.";
        } else if (response.statusCode == 403) {
          return "🟦 API key चा प्रॉब्लेम आहे. नवीन key बनवा.";
        } else {
          return "🟦 सेवा उपलब्ध नाही. (${response.statusCode})";
        }
      }
    } catch (e) {
      print("⚠️ Exception: $e");
      return "🟦 इंटरनेट कनेक्शन तपासा.";
    }
  }

  // ✅ Public function
  static Future<String> getAIResponse(String userInput) async {
    return getCommuteResponse(userInput);
  }
}