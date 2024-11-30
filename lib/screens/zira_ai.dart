import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';
import '../utils/theme.dart';

enum ConversationState { idle, user_talking, ai_talking, user_typing }

class ZiraAIScreen extends StatefulWidget {
  const ZiraAIScreen({super.key});

  @override
  _ZiraAIState createState() => _ZiraAIState();
}

class _ZiraAIState extends State<ZiraAIScreen> {
  final TextEditingController _inputController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;

  ConversationState _conversationState = ConversationState.idle;
  bool _shouldSpeak = true; // Toggle for AI speech
  bool _isLoading = false;
  bool _isVoiceMode = false; // false = text mode, true = voice mode
  bool get _isListening => _conversationState == ConversationState.user_talking;
  bool get _isSpeaking => _conversationState == ConversationState.ai_talking;



  @override
  void initState() {
    super.initState();

    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();

    // Handle TTS completion
    _flutterTts.setCompletionHandler(() {
      _onAIComplete();
    });
  }

  @override
  void dispose() {
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }

  void _logState(String action) {
    debugPrint('[$action] Current State: $_conversationState');
  }

  Future<void> _startListening() async {
    if (_conversationState != ConversationState.idle) return;

    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _conversationState = ConversationState.user_talking;
      });
      _logState('Start Listening');
      _speech.listen(
        onResult: (result) {
          _inputController.text = result.recognizedWords;

          if (result.finalResult) {
            _logState('User Finished Speaking');
            _speech.stop();
            _sendMessage(_inputController.text.trim());
          }
        },
        listenFor: const Duration(minutes: 1),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
      );
    } else {
      debugPrint('Speech recognition not available');
    }
  }

  Future<void> _speak(String message) async {
    // Disable AI speaking if not in voice mode
    if (!_isVoiceMode) {
      debugPrint("AI speaking is disabled because the app is in text mode.");
      return;
    }
    if (!_shouldSpeak || _conversationState != ConversationState.idle) return;

    setState(() {
      _conversationState = ConversationState.ai_talking;
    });
    _logState('AI Starts Speaking');

    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(message);
  }

  void _onAIComplete() {
    if (_conversationState == ConversationState.ai_talking || _conversationState == ConversationState.user_talking) {
      setState(() {
        _conversationState = ConversationState.idle;
      });
      _logState('AI Finished Speaking');

      // Delay before listening again
      Future.delayed(const Duration(seconds: 1), _startListening);
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.isEmpty || _conversationState !=  ConversationState.idle || _conversationState == ConversationState.user_typing) {
      setState(() {
        _conversationState = ConversationState.idle;
        _messages.add({'role': 'user', 'content': message});
        _inputController.clear();
        _isLoading = true;
      });
      _logState('User Message Sent');
    }
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
            {'role': 'system', 'content': 'You are Zira AI, a drug assistant.'},
            ..._messages.map((msg) => {'role': msg['role'], 'content': msg['content']}),
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'];
        setState(() {
          _messages.add({'role': 'assistant', 'content': reply});
        });

        _logState('AI Response Received');
        _speak(reply);
      } else {
        debugPrint('Error: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _conversationState = ConversationState.idle;
    });
    _logState('Listening Stopped');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: false,
        title: Row(
          children: [
            const FaIcon(FontAwesomeIcons.robot, size: 24, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              "Zira AI",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isVoiceMode = false;
                            _conversationState = ConversationState.idle;
                            _inputController.clear();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: !_isVoiceMode ? AppTheme.darkGreen : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.text_fields,
                                size: 14,
                                color: !_isVoiceMode ? Colors.white : Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Text",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: !_isVoiceMode ? Colors.white : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isVoiceMode = true;
                            _conversationState = ConversationState.idle;
                            _inputController.clear();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isVoiceMode ? AppTheme.darkGreen : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.mic,
                                size: 14,
                                color: _isVoiceMode ? Colors.white : Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Voice",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _isVoiceMode ? Colors.white : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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
      ),
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
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.2),
                            child: const FaIcon(FontAwesomeIcons.robot,
                                color: Colors.green, size: 18),
                          ),
                        ),
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Theme.of(context).primaryColor.withOpacity(0.1)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
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

          // Conditional Input/Voice UI
          if (!_isVoiceMode)
          // Text Mode UI
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        debugPrint("Send button pressed. ConversationState: $_conversationState");
                        debugPrint("InputController Text: ${_inputController.text.trim()}");
                        _conversationState = ConversationState.user_typing;
                        if (_inputController.text.trim().isNotEmpty &&
                            _conversationState == ConversationState.idle || _conversationState == ConversationState.user_typing) {
                          debugPrint("Send after button pressed. ConversationState: $_conversationState");
                          _sendMessage(_inputController.text.trim());
                        } else {
                          debugPrint("Send button disabled: Either text is empty or AI/user is busy.");
                        }
                      },
                    ),
                  ),
                ],
              ),
            )
          else
          // Voice Mode UI
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    _conversationState == ConversationState.ai_talking
                        ? Icons.smart_toy
                        : Icons.mic,
                    size: 30,
                    color: _conversationState == ConversationState.ai_talking
                        ? Colors.green
                        : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _conversationState == ConversationState.user_talking
                        ? "Recording... Tap mic to stop"
                        : _conversationState == ConversationState.ai_talking
                        ? "AI is talking"
                        : "Tap the mic icon to start",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: IconButton(
                      icon: Icon(
                        _conversationState == ConversationState.ai_talking
                            ? Icons.smart_toy
                            : _isListening
                            ? Icons.mic_off
                            : Icons.mic,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (_conversationState == ConversationState.user_talking && _isListening) {
                          _stopListening();
                        } else if (_conversationState == ConversationState.idle) {
                          _startListening();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}