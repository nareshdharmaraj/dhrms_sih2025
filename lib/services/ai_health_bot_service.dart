import 'dart:convert';
import 'package:http/http.dart' as http;

class AIHealthBotService {
  static const String _baseUrl =
      'https://postilioned-ungainfully-noah.ngrok-free.app/medqa';

  Future<String> getAIResponse({
    required String text,
    required String lang,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text, 'lang': lang}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Use the correct field from the LLM output
        if (data['success'] == true &&
            data['answer'] != null &&
            data['answer'].toString().trim().isNotEmpty) {
          return data['answer'];
        }
        return 'No response from AI.';
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      return 'Failed to connect to AI service.';
    }
  }
}
