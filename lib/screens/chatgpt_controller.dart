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
    return Scaffold(
      // This ensures the screen resizes when the keyboard opens
      resizeToAvoidBottomInset: true, 
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "🚌 Smart Pune Commute Expert", 
          style: TextStyle(color: Colors.white, fontSize: 18)
        ), 
        backgroundColor: Color(0xFF0D47A1), // Deep Blue
        elevation: 2,
      ),
      body: Column(
        children: [
          // 1. Commute prompt suggestions (Top Bar)
          _buildSuggestionBar(),
          
          // 2. Chat Messages Area (Expanded to fill space)
          Expanded(
            child: ListView.builder(
              reverse: true, // Newest messages at the bottom
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
          
          // 3. Fixed Input Area (Always visible)
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildSuggestionBar() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 12, top: 8),
            child: Text(
              "Commute Questions to Try:",
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: Color(0xFF0D47A1), 
                fontSize: 13
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 8),
              itemCount: _commutePrompts.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                  child: ActionChip(
                    label: Text(
                      _commutePrompts[index],
                      style: TextStyle(fontSize: 11),
                    ),
                    onPressed: () => _usePrompt(_commutePrompts[index]),
                    backgroundColor: Color(0xFFE3F2FD),
                    labelStyle: TextStyle(color: Color(0xFF0D47A1)),
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
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    bool isUser = msg.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.symmetric(vertical: 6),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? Color(0xFF0D47A1) : Color(0xFFF1F1F1),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomLeft: isUser ? Radius.circular(15) : Radius.circular(0),
            bottomRight: isUser ? Radius.circular(0) : Radius.circular(15),
          ),
        ),
        child: Text(
          msg.message, 
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87, 
            fontSize: 14
          )
        ),
      ),
    );
  }

  Widget _buildLoadingMessage() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Calculating best route...", style: TextStyle(fontSize: 13)),
            SizedBox(width: 10),
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0D47A1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: "Ask about Pune traffic or metro...",
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
              SizedBox(width: 8),
              GestureDetector(
                onTap: _handleSend,
                child: CircleAvatar(
                  backgroundColor: Color(0xFF0D47A1),
                  radius: 22,
                  child: Icon(Icons.send, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}