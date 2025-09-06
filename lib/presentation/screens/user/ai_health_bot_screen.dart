import 'package:flutter/material.dart';
import '../../../core/constants/app_styles.dart';

class AIHealthBotScreen extends StatefulWidget {
  const AIHealthBotScreen({super.key});

  @override
  State<AIHealthBotScreen> createState() => _AIHealthBotScreenState();
}

class _AIHealthBotScreenState extends State<AIHealthBotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
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
    setState(() {
      _messages.add(
        ChatMessage(message: message, isBot: true, timestamp: DateTime.now()),
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

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _addUserMessage(userMessage);
    _messageController.clear();

    setState(() {
      _isTyping = true;
    });

    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isTyping = false;
      });
      _addBotMessage(_generateBotResponse(userMessage));
    });
  }

  String _generateBotResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('headache') || message.contains('head')) {
      return "I understand you're experiencing headaches. This could be due to various factors like stress, dehydration, or lack of sleep. I recommend:\n\n• Stay hydrated\n• Get adequate rest\n• Practice relaxation techniques\n• If symptoms persist, consult a doctor";
    } else if (message.contains('fever') || message.contains('temperature')) {
      return "Fever can indicate your body is fighting an infection. Here's what you can do:\n\n• Rest and stay hydrated\n• Monitor your temperature\n• Take fever reducers if needed\n• Seek medical attention if fever exceeds 103°F (39.4°C)";
    } else if (message.contains('cough') || message.contains('cold')) {
      return "For cough and cold symptoms, try these remedies:\n\n• Stay hydrated with warm fluids\n• Use a humidifier\n• Get plenty of rest\n• Gargle with salt water\n• If symptoms worsen or persist beyond a week, see a doctor";
    } else if (message.contains('exercise') || message.contains('workout')) {
      return "Regular exercise is great for your health! Here are some tips:\n\n• Start with 30 minutes of moderate activity daily\n• Include both cardio and strength training\n• Stay hydrated during workouts\n• Listen to your body and rest when needed";
    } else if (message.contains('diet') || message.contains('nutrition')) {
      return "A balanced diet is essential for good health:\n\n• Include fruits and vegetables in every meal\n• Choose whole grains over refined ones\n• Limit processed foods and sugar\n• Stay hydrated with plenty of water\n• Consider consulting a nutritionist for personalized advice";
    } else if (message.contains('stress') || message.contains('anxiety')) {
      return "Managing stress is important for overall health:\n\n• Practice deep breathing exercises\n• Try meditation or mindfulness\n• Maintain a regular sleep schedule\n• Stay physically active\n• Consider talking to a mental health professional";
    } else {
      return "Thank you for your question. While I can provide general health information, I recommend consulting with a healthcare professional for personalized medical advice. Is there anything specific about your health you'd like to know more about?";
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
                  Text(
                    message.message,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: message.isBot ? AppColors.grey800 : Colors.white,
                    ),
                  ),
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
                  hintText: 'Ask about your health...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
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
