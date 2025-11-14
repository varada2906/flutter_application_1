import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/chatgpt_screen.dart';
import 'package:flutter_application_1/screens/chatgpt_service.dart' show ChatGPTService;


class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // Pune Commute-specific prompt suggestions
  final List<String> _commutePrompts = [
    "What is the fastest route from Hinjewadi to Koregaon Park right now?",
    "Are there any delays on the Pune Metro line today?",
    "How is the traffic near Deccan during peak hours?",
    "Suggest a good bus route from Kothrud to Swargate.",
    "Where can I find parking near the Shaniwar Wada?",
    "How will the monsoon rain affect travel times in the city?",
    "What are the best apps for real-time Pune traffic updates?",
  ];

  void _handleSend() async {
    String input = _controller.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(message: input, isUser: true));
      _isLoading = true;
    });

    _controller.clear();

    // Call Controller for AI response
    String botReply = await ChatGPTService.getAIResponse(input);

    setState(() {
      _isLoading = false;
      _messages.add(ChatMessage(message: botReply, isUser: false));
    });
  }

  void _usePrompt(String prompt) {
    _controller.text = prompt;
  }

  @override
  Widget build(BuildContext context) {
    // Setting a uniform background color for a clean look
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "🚌 Smart Pune Commute Expert", 
          style: TextStyle(color: Colors.white)
        ), 
        backgroundColor: Color(0xFF0D47A1), // Deep Blue
      ),
      body: Column(
        children: [
          // Commute prompt suggestions
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1))
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "Commute Questions to Try:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: Color(0xFF0D47A1), // Deep Blue
                      fontSize: 14
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _commutePrompts.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.0),
                        child: ActionChip(
                          label: Text(
                            _commutePrompts[index],
                            style: TextStyle(fontSize: 12),
                          ),
                          onPressed: () => _usePrompt(_commutePrompts[index]),
                          backgroundColor: Color(0xFFE3F2FD), // Light Blue Background
                          labelStyle: TextStyle(color: Color(0xFF0D47A1)), // Deep Blue Text
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: Color(0xFF90CAF9)),
                          )
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              reverse: true, // Show newest messages at the bottom
              padding: EdgeInsets.all(10),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == 0 && _isLoading) {
                  return _buildLoadingMessage();
                }
                final msg = _messages[_messages.length - 1 - index];
                return _buildMessageBubble(msg);
              },
            ),
          ),
          
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildLoadingMessage() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.symmetric(vertical: 5),
        constraints: BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Color(0xFF90CAF9), // Light Blue
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Calculating best Pune route...", // Updated text
              style: TextStyle(color: Colors.black87, fontSize: 14),
            ),
            SizedBox(width: 8),
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF0D47A1), // Deep Blue loading indicator
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.symmetric(vertical: 5),
        constraints: BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          // Blue theme for bubbles
          color: msg.isUser ? Color(0xFF1565C0) : Color(0xFF42A5F5), // Blue/Lighter Blue
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          msg.message, 
          style: TextStyle(color: Colors.white, fontSize: 14)
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: TextStyle(color: Colors.black87), // Ensure input text is readable
              decoration: InputDecoration(
                hintText: "Ask about Pune traffic, routes, or metro...", // Updated hint
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.grey[100], // Very light background
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: _handleSend,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0D47A1), // Deep Blue button
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text("Send", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}