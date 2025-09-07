import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_styles.dart';
// Ensure dotenv is loaded before using the API key
// Removed didChangeDependencies method as dotenv should be loaded in main.dart

class AIHealthBotScreen extends StatefulWidget {
  const AIHealthBotScreen({super.key});

  @override
  State<AIHealthBotScreen> createState() => _AIHealthBotScreenState();
}

class _AIHealthBotScreenState extends State<AIHealthBotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addBotMessage(
      "Hello! I'm your AI Health Assistant. How can I help you today?",
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addBotMessage(String message) {
    final formattedMessage = _formatBotMessage(message);
    setState(() {
      _messages.add(
        ChatMessage(
          message: formattedMessage,
          isBot: true,
          timestamp: DateTime.now(),
        ),
      );
    });
    _scrollToBottom();
  }

  void _addUserMessage(String message) {
    setState(() {
      _messages.add(
        ChatMessage(message: message, isBot: false, timestamp: DateTime.now()),
      );
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _addUserMessage(userMessage);
    _messageController.clear();

    setState(() {
      _isTyping = true;
    });

    try {
      final botReply = await _fetchGroqResponse(userMessage);
      setState(() {
        _isTyping = false;
      });
      _addBotMessage(botReply);
    } catch (e) {
      setState(() {
        _isTyping = false;
      });
      _addBotMessage(
        "Sorry, I'm having trouble connecting to the AI service. Please try again later.",
      );
    }
  }

  String _formatBotMessage(String message) {
    // Clean and format the message from LLM
    String formatted = message
        .replaceAll('**', '') // Remove bold markdown
        .replaceAll('*', '') // Remove italic markdown
        .replaceAll('###', '') // Remove header markdown
        .replaceAll('##', '') // Remove header markdown
        .replaceAll('#', '') // Remove header markdown
        .trim();

    // Check if the message contains a table (has | characters)
    if (formatted.contains('|')) {
      return _formatTableSimple(formatted);
    }

    // Split into lines and format as bullet points where appropriate
    List<String> lines = formatted.split('\n');
    List<String> formattedLines = [];

    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      // If line starts with -, make it a proper bullet point
      if (line.startsWith('-')) {
        formattedLines.add('• ${line.substring(1).trim()}');
      } else if (line.startsWith('•')) {
        formattedLines.add(line);
      } else {
        formattedLines.add(line);
      }
    }

    return formattedLines.join('\n');
  }

  String _formatTableSimple(String tableText) {
    List<String> lines = tableText.split('\n');
    List<String> formattedLines = [];
    bool inTable = false;

    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty) {
        if (inTable) {
          formattedLines.add('');
          inTable = false;
        }
        continue;
      }

      if (line.contains('|')) {
        inTable = true;
        // Clean up the table row
        List<String> cells = line
            .split('|')
            .map((cell) => cell.trim())
            .where((cell) => cell.isNotEmpty)
            .toList();

        if (cells.isNotEmpty) {
          // Format as a clean list with bullets
          String formattedRow = cells.join(' • ');
          formattedLines.add('▪ $formattedRow');
        }
      } else {
        if (inTable) {
          formattedLines.add('');
          inTable = false;
        }
        formattedLines.add(line);
      }
    }

    return formattedLines.join('\n');
  }

  Future<String> _fetchGroqResponse(String userMessage) async {
    final groqApiKey = dotenv.env['GROQ_API_KEY'];
    const groqApiUrl = 'https://api.groq.com/openai/v1/chat/completions';
    const model = 'llama-3.3-70b-versatile';

    if (groqApiKey == null || groqApiKey.isEmpty) {
      return "API key not found. Please check your .env configuration.";
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $groqApiKey',
    };

    final body = {
      'model': model,
      'messages': [
        {
          'role': 'system',
          'content':
              "You are an AI health assistant. Only answer questions that are strictly related to health, medicine, wellness, symptoms, diseases, treatments, or healthcare. If the user's question is not related to these topics, reply: 'I can only answer medical or health-related questions. Is there anything else?' Never answer non-medical questions.",
        },
        {'role': 'user', 'content': userMessage},
      ],
      'temperature': 1,
      'max_completion_tokens': 1024,
      'top_p': 1,
      'stream': false,
      'stop': null,
    };

    try {
      final uri = Uri.parse(groqApiUrl);
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'] as String?;
        return reply ?? "Sorry, I couldn't generate a response.";
      } else {
        return "Groq API error: ${response.statusCode}. Please try again later.";
      }
    } catch (e) {
      return "Network error: ${e.toString()}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Health Bot'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primaryBlue.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.smart_toy, color: AppColors.primaryBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI-powered health assistant for general guidance',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildChatBubble(_messages[index]);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isBot
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.isBot) ...[
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryBlue,
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isBot
                    ? AppColors.grey200
                    : AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: message.isBot
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                  bottomRight: message.isBot
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedText(text: message.message, isBot: message.isBot),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: AppTextStyles.caption.copyWith(
                      color: message.isBot ? AppColors.grey600 : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!message.isBot) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryGreen,
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryBlue,
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(
                16,
              ).copyWith(bottomLeft: const Radius.circular(4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('AI is typing', style: AppTextStyles.bodySmall),
                const SizedBox(width: 8),
                SizedBox(
                  width: 24,
                  height: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(3, (index) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 600 + (index * 200)),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.grey300),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText:
                      'Ask about your health... (Shift+Enter for new line)',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
                onChanged: (text) {
                  // Handle Shift+Enter vs Enter
                  if (text.endsWith('\n') && !text.endsWith('shift\n')) {
                    // This is a simple Enter, send message
                    _messageController.text = text.substring(
                      0,
                      text.length - 1,
                    );
                    _sendMessage();
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Health Bot'),
        content: const Text(
          'This AI assistant provides general health information and guidance. '
          'It should not be used as a substitute for professional medical advice, '
          'diagnosis, or treatment. Always consult your healthcare provider for '
          'medical concerns.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String message;
  final bool isBot;
  final DateTime timestamp;

  ChatMessage({
    required this.message,
    required this.isBot,
    required this.timestamp,
  });
}

class AnimatedText extends StatefulWidget {
  final String text;
  final bool isBot;

  const AnimatedText({super.key, required this.text, required this.isBot});

  @override
  State<AnimatedText> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _characterCount;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.text.length * 20), // Adjust speed
      vsync: this,
    );
    _characterCount = IntTween(
      begin: 0,
      end: widget.text.length,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    if (widget.isBot) {
      _controller.forward();
    } else {
      _characterCount = IntTween(
        begin: widget.text.length,
        end: widget.text.length,
      ).animate(_controller);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _characterCount,
      builder: (context, child) {
        String displayText = widget.text.substring(0, _characterCount.value);

        return Text(
          displayText,
          style: AppTextStyles.bodyMedium.copyWith(
            color: widget.isBot ? AppColors.grey800 : Colors.white,
          ),
        );
      },
    );
  }
}
