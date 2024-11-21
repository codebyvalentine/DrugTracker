import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class ZiraAIScreen extends StatefulWidget {
  const ZiraAIScreen({super.key});

  @override
  _ZiraAIState createState() => _ZiraAIState();
}

class _ZiraAIState extends State<ZiraAIScreen> {
  final TextEditingController _inputController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  final FocusNode _focusNode =
      FocusNode(); // FocusNode for smooth input handling

  final List<String> preChatSuggestions = [
    "Ask me about any drug",
    "Tell me about side effects",
    "What’s the dosage for paracetamol?",
  ];

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': message});
      _isLoading = true;
    });

    _inputController.clear(); // Clear input field immediately

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${dotenv.env['OPENAI_API_KEY']}',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are Zira AI, a drug information assistant.'
            },
            ..._messages.map((msg) => {
                  'role': msg['role'],
                  'content': msg['content'],
                }),
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'];
        setState(() {
          _messages.add({'role': 'assistant', 'content': reply});
        });
      } else {
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content': 'Something went wrong. Please try again.',
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': 'Failed to connect. Please try again later.',
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: isUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      if (!isUser)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Image.asset(
                            'assets/images/logo/zira_ai.png',
                            width: 30,
                            height: 30,
                          ),
                        ),
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                isUser ? Colors.green[100] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            message['content']!,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Pre-chat suggestions (always visible just above the input field)
          if (_messages.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              color: Colors.grey[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Hi there! I’m Zira AI, your drug assistant. Ask me anything about drugs!",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: preChatSuggestions.map((suggestion) {
                      return GestureDetector(
                        onTap: () {
                          _sendMessage(suggestion);
                        },
                        child: Chip(
                          label: Text(
                            suggestion,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

          // Input Box
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    focusNode: _focusNode, // Attach the focus node
                    onSubmitted: (value) {
                      _sendMessage(value);
                      _focusNode
                          .requestFocus(); // Keep the focus in the text field
                    },
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
                  onPressed: () {
                    final message = _inputController.text;
                    _inputController.clear();
                    _sendMessage(message);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
