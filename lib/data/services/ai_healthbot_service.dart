import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/storage_helper.dart';

class AIHealthBotService {
  static const String baseUrl = ApiConstants.baseUrl;

  // Send message to AI health bot
  static Future<Map<String, dynamic>> sendMessage({
    required String message,
    String? sessionId,
    Map<String, dynamic>? context,
  }) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/ai/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'message': message,
          if (sessionId != null) 'sessionId': sessionId,
          if (context != null) 'context': context,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to send message');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  // Get chat history for a session
  static Future<Map<String, dynamic>> getChatHistory(String sessionId) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/ai/chat-history/$sessionId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to get chat history');
      }
    } catch (e) {
      throw Exception('Error getting chat history: $e');
    }
  }

  // Get all chat sessions
  static Future<Map<String, dynamic>> getChatSessions({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null) 'status': status,
      };

      final uri = Uri.parse('$baseUrl/ai/sessions').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to get chat sessions');
      }
    } catch (e) {
      throw Exception('Error getting chat sessions: $e');
    }
  }

  // Get AI health analysis
  static Future<Map<String, dynamic>> getHealthAnalysis({
    List<String>? symptoms,
    String? duration,
    int? severity,
    String? additionalInfo,
  }) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final requestBody = <String, dynamic>{};
      if (symptoms != null) requestBody['symptoms'] = symptoms;
      if (duration != null) requestBody['duration'] = duration;
      if (severity != null) requestBody['severity'] = severity;
      if (additionalInfo != null) requestBody['additionalInfo'] = additionalInfo;

      final response = await http.post(
        Uri.parse('$baseUrl/ai/health-analysis'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to get health analysis');
      }
    } catch (e) {
      throw Exception('Error getting health analysis: $e');
    }
  }

  // Get AI recommendations
  static Future<Map<String, dynamic>> getRecommendations({
    String? type,
    String? priority,
    String? status,
  }) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final queryParams = <String, String>{};
      if (type != null) queryParams['type'] = type;
      if (priority != null) queryParams['priority'] = priority;
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse('$baseUrl/ai/recommendations').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to get recommendations');
      }
    } catch (e) {
      throw Exception('Error getting recommendations: $e');
    }
  }

  // Submit feedback for AI response
  static Future<Map<String, dynamic>> submitFeedback({
    required String sessionId,
    required String messageId,
    required int rating,
    required bool helpful,
    String? feedback,
  }) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/ai/feedback'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'sessionId': sessionId,
          'messageId': messageId,
          'rating': rating,
          'helpful': helpful,
          if (feedback != null) 'feedback': feedback,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to submit feedback');
      }
    } catch (e) {
      throw Exception('Error submitting feedback: $e');
    }
  }
}

// AI Chat Message Model
class AIChatMessage {
  final String id;
  final String content;
  final bool isBot;
  final DateTime timestamp;
  final String? intent;
  final double? confidence;
  final List<String>? suggestions;
  final bool? isEmergency;

  AIChatMessage({
    required this.id,
    required this.content,
    required this.isBot,
    required this.timestamp,
    this.intent,
    this.confidence,
    this.suggestions,
    this.isEmergency,
  });

  factory AIChatMessage.fromJson(Map<String, dynamic> json) {
    return AIChatMessage(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      isBot: json['type'] == 'bot',
      timestamp: DateTime.parse(json['timestamp']),
      intent: json['metadata']?['intent'],
      confidence: json['metadata']?['confidence']?.toDouble(),
      suggestions: json['metadata']?['suggestions']?.cast<String>(),
      isEmergency: json['isEmergency'],
    );
  }
}

// AI Session Model
class AISession {
  final String sessionId;
  final String status;
  final int messageCount;
  final List<String> topicsDiscussed;
  final String? lastMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  AISession({
    required this.sessionId,
    required this.status,
    required this.messageCount,
    required this.topicsDiscussed,
    this.lastMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AISession.fromJson(Map<String, dynamic> json) {
    return AISession(
      sessionId: json['sessionId'] ?? '',
      status: json['status'] ?? '',
      messageCount: json['messageCount'] ?? 0,
      topicsDiscussed: (json['topicsDiscussed'] as List?)?.cast<String>() ?? [],
      lastMessage: json['lastMessage'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

// AI Health Analysis Model
class AIHealthAnalysis {
  final String analysisId;
  final Map<String, dynamic> patientInfo;
  final List<String> symptoms;
  final AnalysisResult analysis;
  final NextSteps nextSteps;
  final String disclaimer;

  AIHealthAnalysis({
    required this.analysisId,
    required this.patientInfo,
    required this.symptoms,
    required this.analysis,
    required this.nextSteps,
    required this.disclaimer,
  });

  factory AIHealthAnalysis.fromJson(Map<String, dynamic> json) {
    return AIHealthAnalysis(
      analysisId: json['analysisId'] ?? '',
      patientInfo: Map<String, dynamic>.from(json['patientInfo'] ?? {}),
      symptoms: (json['symptoms'] as List?)?.cast<String>() ?? [],
      analysis: AnalysisResult.fromJson(json['analysis'] ?? {}),
      nextSteps: NextSteps.fromJson(json['nextSteps'] ?? {}),
      disclaimer: json['disclaimer'] ?? '',
    );
  }
}

class AnalysisResult {
  final String riskLevel;
  final List<String> possibleConditions;
  final List<String> recommendations;
  final List<String> redFlags;
  final double confidence;

  AnalysisResult({
    required this.riskLevel,
    required this.possibleConditions,
    required this.recommendations,
    required this.redFlags,
    required this.confidence,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      riskLevel: json['riskLevel'] ?? '',
      possibleConditions: (json['possibleConditions'] as List?)?.cast<String>() ?? [],
      recommendations: (json['recommendations'] as List?)?.cast<String>() ?? [],
      redFlags: (json['redFlags'] as List?)?.cast<String>() ?? [],
      confidence: (json['confidence'] ?? 0).toDouble(),
    );
  }
}

class NextSteps {
  final List<String> immediate;
  final List<String> followUp;
  final List<String> monitoring;

  NextSteps({
    required this.immediate,
    required this.followUp,
    required this.monitoring,
  });

  factory NextSteps.fromJson(Map<String, dynamic> json) {
    return NextSteps(
      immediate: (json['immediate'] as List?)?.cast<String>() ?? [],
      followUp: (json['followUp'] as List?)?.cast<String>() ?? [],
      monitoring: (json['monitoring'] as List?)?.cast<String>() ?? [],
    );
  }
}

// AI Recommendation Model
class AIRecommendation {
  final String type;
  final String title;
  final String description;
  final String priority;
  final AIAnalysis aiAnalysis;
  final List<RecommendationAction> actions;
  final String status;
  final DateTime? expiresAt;

  AIRecommendation({
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
    required this.aiAnalysis,
    required this.actions,
    required this.status,
    this.expiresAt,
  });

  factory AIRecommendation.fromJson(Map<String, dynamic> json) {
    return AIRecommendation(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? '',
      aiAnalysis: AIAnalysis.fromJson(json['aiAnalysis'] ?? {}),
      actions: (json['actions'] as List?)
              ?.map((a) => RecommendationAction.fromJson(a))
              .toList() ??
          [],
      status: json['status'] ?? '',
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    );
  }
}

class AIAnalysis {
  final double confidence;
  final List<String> basedOn;
  final String reasoning;
  final List<String> riskFactors;

  AIAnalysis({
    required this.confidence,
    required this.basedOn,
    required this.reasoning,
    required this.riskFactors,
  });

  factory AIAnalysis.fromJson(Map<String, dynamic> json) {
    return AIAnalysis(
      confidence: (json['confidence'] ?? 0).toDouble(),
      basedOn: (json['basedOn'] as List?)?.cast<String>() ?? [],
      reasoning: json['reasoning'] ?? '',
      riskFactors: (json['riskFactors'] as List?)?.cast<String>() ?? [],
    );
  }
}

class RecommendationAction {
  final String action;
  final String timeframe;
  final bool completed;

  RecommendationAction({
    required this.action,
    required this.timeframe,
    required this.completed,
  });

  factory RecommendationAction.fromJson(Map<String, dynamic> json) {
    return RecommendationAction(
      action: json['action'] ?? '',
      timeframe: json['timeframe'] ?? '',
      completed: json['completed'] ?? false,
    );
  }
}
