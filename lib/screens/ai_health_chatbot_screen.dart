import 'package:flutter/material.dart';
import '../services/ai_health_bot_service.dart';

class AIHealthChatBotScreen extends StatefulWidget {
  const AIHealthChatBotScreen({super.key});

  @override
  State<AIHealthChatBotScreen> createState() => _AIHealthChatBotScreenState();
}

class _AIHealthChatBotScreenState extends State<AIHealthChatBotScreen>
    with SingleTickerProviderStateMixin {
  final AIHealthBotService _botService = AIHealthBotService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedLang = 'tamil';
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isLoading = true;
      _controller.clear();
    });
    _scrollToBottom();
    final response = await _botService.getAIResponse(
      text: text,
      lang: _selectedLang,
    );
    setState(() {
      _messages.add(
        _ChatMessage(text: '', isUser: false, animatedText: response),
      );
      _isLoading = false;
    });
    _scrollToBottom();
    _animationController.forward(from: 0);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
    });
  }

  // Removed new chat option as per request

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Health Chatbot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear Chat',
            onPressed: _clearChat,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text('Language:'),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedLang,
                  items: const [
                    DropdownMenuItem(value: 'tamil', child: Text('Tamil')),
                    DropdownMenuItem(value: 'english', child: Text('English')),
                    DropdownMenuItem(value: 'hindi', child: Text('Hindi')),
                    DropdownMenuItem(value: 'telugu', child: Text('Telugu')),
                    DropdownMenuItem(value: 'kannada', child: Text('Kannada')),
                    DropdownMenuItem(
                      value: 'malayalam',
                      child: Text('Malayalam'),
                    ),
                    DropdownMenuItem(value: 'marathi', child: Text('Marathi')),
                    DropdownMenuItem(
                      value: 'gujarati',
                      child: Text('Gujarati'),
                    ),
                    DropdownMenuItem(value: 'punjabi', child: Text('Punjabi')),
                    DropdownMenuItem(value: 'bengali', child: Text('Bengali')),
                    DropdownMenuItem(value: 'urdu', child: Text('Urdu')),
                    DropdownMenuItem(value: 'oriya', child: Text('Oriya')),
                    DropdownMenuItem(
                      value: 'assamese',
                      child: Text('Assamese'),
                    ),
                    DropdownMenuItem(
                      value: 'sanskrit',
                      child: Text('Sanskrit'),
                    ),
                    DropdownMenuItem(value: 'konkani', child: Text('Konkani')),
                    DropdownMenuItem(
                      value: 'manipuri',
                      child: Text('Manipuri'),
                    ),
                    DropdownMenuItem(value: 'sindhi', child: Text('Sindhi')),
                    DropdownMenuItem(value: 'dogri', child: Text('Dogri')),
                    DropdownMenuItem(value: 'bodo', child: Text('Bodo')),
                    DropdownMenuItem(
                      value: 'santhali',
                      child: Text('Santhali'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedLang = val);
                  },
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _messages.isNotEmpty ? _clearChat : null,
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                if (msg.isUser) {
                  return AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 500),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.blue[200],
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          msg.text,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return _AnimatedBotText(
                    text: msg.animatedText ?? msg.text,
                    message: msg,
                  );
                }
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type your health question...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedScale(
                  scale: _controller.text.isNotEmpty ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: FloatingActionButton(
                    onPressed: _isLoading ? null : _sendMessage,
                    child: const Icon(Icons.send),
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

class _ChatMessage {
  final String text;
  final bool isUser;
  final String? animatedText;
  bool isAnimated = false;
  _ChatMessage({required this.text, required this.isUser, this.animatedText});
}

class _AnimatedBotText extends StatefulWidget {
  final String text;
  final _ChatMessage message;
  const _AnimatedBotText({required this.text, required this.message});

  @override
  State<_AnimatedBotText> createState() => _AnimatedBotTextState();
}

class _AnimatedBotTextState extends State<_AnimatedBotText>
    with SingleTickerProviderStateMixin {
  String _displayed = '';
  int _charIndex = 0;

  @override
  void initState() {
    super.initState();
    if (!widget.message.isAnimated) {
      _animateText();
    } else {
      // If already animated, show full text immediately
      _displayed = widget.text;
      _charIndex = widget.text.length;
    }
  }

  void _animateText() async {
    while (_charIndex < widget.text.length) {
      await Future.delayed(const Duration(milliseconds: 18));
      if (mounted) {
        setState(() {
          _charIndex++;
          _displayed = widget.text.substring(0, _charIndex);
        });
      }
    }
    // Mark as animated when complete
    widget.message.isAnimated = true;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 500),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            _displayed,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
      ),
    );
  }
}
