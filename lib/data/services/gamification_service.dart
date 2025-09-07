import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/storage_helper.dart';

class GamificationService {
  static const String baseUrl = ApiConstants.baseUrl;

  // Get user's gamification profile
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl${ApiConstants.gamificationProfile}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to get profile');
      }
    } catch (e) {
      throw Exception('Error getting profile: $e');
    }
  }

  // Get available health challenges
  static Future<Map<String, dynamic>> getChallenges({
    String? category,
    String? difficulty,
    String? type,
    String? status,
  }) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final queryParams = <String, String>{};
      if (category != null) queryParams['category'] = category;
      if (difficulty != null) queryParams['difficulty'] = difficulty;
      if (type != null) queryParams['type'] = type;
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse('$baseUrl${ApiConstants.gamificationChallenges}').replace(
        queryParameters: queryParams.isEmpty ? null : queryParams,
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
        throw Exception(errorBody['message'] ?? 'Failed to get challenges');
      }
    } catch (e) {
      throw Exception('Error getting challenges: $e');
    }
  }

  // Enroll in a health challenge
  static Future<Map<String, dynamic>> enrollInChallenge(String challengeId) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.gamificationChallenges}/$challengeId/enroll'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to enroll in challenge');
      }
    } catch (e) {
      throw Exception('Error enrolling in challenge: $e');
    }
  }

  // Log progress for a challenge
  static Future<Map<String, dynamic>> logChallengeProgress({
    required String challengeId,
    required double value,
    String? date,
    String? notes,
  }) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.gamificationChallenges}/$challengeId/log'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'value': value,
          if (date != null) 'date': date,
          if (notes != null) 'notes': notes,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to log progress');
      }
    } catch (e) {
      throw Exception('Error logging progress: $e');
    }
  }

  // Get challenge progress
  static Future<Map<String, dynamic>> getProgress({String? status}) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse('$baseUrl${ApiConstants.gamificationProgress}').replace(
        queryParameters: queryParams.isEmpty ? null : queryParams,
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
        throw Exception(errorBody['message'] ?? 'Failed to get progress');
      }
    } catch (e) {
      throw Exception('Error getting progress: $e');
    }
  }

  // Create a new health goal
  static Future<Map<String, dynamic>> createGoal({
    required String title,
    required String category,
    required String goalType,
    required Map<String, dynamic> target,
    String? description,
    List<Map<String, dynamic>>? milestones,
    List<Map<String, dynamic>>? reminders,
  }) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.gamificationGoals}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'category': category,
          'goalType': goalType,
          'target': target,
          if (description != null) 'description': description,
          if (milestones != null) 'milestones': milestones,
          if (reminders != null) 'reminders': reminders,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to create goal');
      }
    } catch (e) {
      throw Exception('Error creating goal: $e');
    }
  }

  // Get health goals
  static Future<Map<String, dynamic>> getGoals({
    String? category,
    String? status,
  }) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final queryParams = <String, String>{};
      if (category != null) queryParams['category'] = category;
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse('$baseUrl${ApiConstants.gamificationGoals}').replace(
        queryParameters: queryParams.isEmpty ? null : queryParams,
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
        throw Exception(errorBody['message'] ?? 'Failed to get goals');
      }
    } catch (e) {
      throw Exception('Error getting goals: $e');
    }
  }

  // Update goal progress
  static Future<Map<String, dynamic>> updateGoalProgress({
    required String goalId,
    required double currentValue,
    String? notes,
  }) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.gamificationGoals}/$goalId/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentValue': currentValue,
          if (notes != null) 'notes': notes,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to update goal progress');
      }
    } catch (e) {
      throw Exception('Error updating goal progress: $e');
    }
  }

  // Get leaderboard
  static Future<Map<String, dynamic>> getLeaderboard({
    String? type,
    String? period,
    int? limit,
  }) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final queryParams = <String, String>{};
      if (type != null) queryParams['type'] = type;
      if (period != null) queryParams['period'] = period;
      if (limit != null) queryParams['limit'] = limit.toString();

      final uri = Uri.parse('$baseUrl${ApiConstants.gamificationLeaderboard}').replace(
        queryParameters: queryParams.isEmpty ? null : queryParams,
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
        throw Exception(errorBody['message'] ?? 'Failed to get leaderboard');
      }
    } catch (e) {
      throw Exception('Error getting leaderboard: $e');
    }
  }

  // Get badges
  static Future<Map<String, dynamic>> getBadges() async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl${ApiConstants.gamificationBadges}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to get badges');
      }
    } catch (e) {
      throw Exception('Error getting badges: $e');
    }
  }
}

// Gamification Profile Model
class GamificationProfile {
  final UserLevel level;
  final UserPoints points;
  final List<Badge> badges;
  final List<Achievement> achievements;
  final UserStatistics statistics;
  final UserPreferences preferences;

  GamificationProfile({
    required this.level,
    required this.points,
    required this.badges,
    required this.achievements,
    required this.statistics,
    required this.preferences,
  });

  factory GamificationProfile.fromJson(Map<String, dynamic> json) {
    return GamificationProfile(
      level: UserLevel.fromJson(json['level'] ?? {}),
      points: UserPoints.fromJson(json['points'] ?? {}),
      badges: (json['badges'] as List?)?.map((b) => Badge.fromJson(b)).toList() ?? [],
      achievements: (json['achievements'] as List?)?.map((a) => Achievement.fromJson(a)).toList() ?? [],
      statistics: UserStatistics.fromJson(json['statistics'] ?? {}),
      preferences: UserPreferences.fromJson(json['preferences'] ?? {}),
    );
  }
}

// User Level Model
class UserLevel {
  final int current;
  final int xp;
  final int xpToNext;
  final double? progressToNext;

  UserLevel({
    required this.current,
    required this.xp,
    required this.xpToNext,
    this.progressToNext,
  });

  factory UserLevel.fromJson(Map<String, dynamic> json) {
    return UserLevel(
      current: json['current'] ?? 1,
      xp: json['xp'] ?? 0,
      xpToNext: json['xpToNext'] ?? 100,
      progressToNext: (json['progressToNext'] ?? 0).toDouble(),
    );
  }
}

// User Points Model
class UserPoints {
  final int total;
  final int available;
  final int spent;

  UserPoints({
    required this.total,
    required this.available,
    required this.spent,
  });

  factory UserPoints.fromJson(Map<String, dynamic> json) {
    return UserPoints(
      total: json['total'] ?? 0,
      available: json['available'] ?? 0,
      spent: json['spent'] ?? 0,
    );
  }
}

// Badge Model
class Badge {
  final String badgeId;
  final String name;
  final String description;
  final DateTime earnedDate;
  final String category;
  final String rarity;

  Badge({
    required this.badgeId,
    required this.name,
    required this.description,
    required this.earnedDate,
    required this.category,
    required this.rarity,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      badgeId: json['badgeId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      earnedDate: DateTime.parse(json['earnedDate']),
      category: json['category'] ?? '',
      rarity: json['rarity'] ?? 'common',
    );
  }
}

// Achievement Model
class Achievement {
  final String achievementId;
  final String name;
  final String description;
  final DateTime unlockedDate;
  final AchievementProgress progress;

  Achievement({
    required this.achievementId,
    required this.name,
    required this.description,
    required this.unlockedDate,
    required this.progress,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      achievementId: json['achievementId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      unlockedDate: DateTime.parse(json['unlockedDate']),
      progress: AchievementProgress.fromJson(json['progress'] ?? {}),
    );
  }
}

// Achievement Progress Model
class AchievementProgress {
  final int current;
  final int target;
  final double percentage;

  AchievementProgress({
    required this.current,
    required this.target,
    required this.percentage,
  });

  factory AchievementProgress.fromJson(Map<String, dynamic> json) {
    return AchievementProgress(
      current: json['current'] ?? 0,
      target: json['target'] ?? 1,
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}

// User Statistics Model
class UserStatistics {
  final int challengesCompleted;
  final int challengesFailed;
  final int totalDaysActive;
  final int currentStreak;
  final int bestStreak;
  final double averageRating;

  UserStatistics({
    required this.challengesCompleted,
    required this.challengesFailed,
    required this.totalDaysActive,
    required this.currentStreak,
    required this.bestStreak,
    required this.averageRating,
  });

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      challengesCompleted: json['challengesCompleted'] ?? 0,
      challengesFailed: json['challengesFailed'] ?? 0,
      totalDaysActive: json['totalDaysActive'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      bestStreak: json['bestStreak'] ?? 0,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
    );
  }
}

// User Preferences Model
class UserPreferences {
  final List<String> challengeTypes;
  final String difficulty;
  final NotificationPreferences notifications;

  UserPreferences({
    required this.challengeTypes,
    required this.difficulty,
    required this.notifications,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      challengeTypes: (json['challengeTypes'] as List?)?.cast<String>() ?? [],
      difficulty: json['difficulty'] ?? 'medium',
      notifications: NotificationPreferences.fromJson(json['notifications'] ?? {}),
    );
  }
}

// Notification Preferences Model
class NotificationPreferences {
  final bool daily;
  final bool weekly;
  final bool achievements;

  NotificationPreferences({
    required this.daily,
    required this.weekly,
    required this.achievements,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      daily: json['daily'] ?? true,
      weekly: json['weekly'] ?? true,
      achievements: json['achievements'] ?? true,
    );
  }
}

// Health Challenge Model
class HealthChallenge {
  final String id;
  final String title;
  final String description;
  final String category;
  final String type;
  final String difficulty;
  final ChallengeDuration duration;
  final ChallengeTarget target;
  final ChallengeRewards rewards;
  final bool isActive;
  final String? enrollmentStatus;
  final ChallengeProgress? userProgress;

  HealthChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.difficulty,
    required this.duration,
    required this.target,
    required this.rewards,
    required this.isActive,
    this.enrollmentStatus,
    this.userProgress,
  });

  factory HealthChallenge.fromJson(Map<String, dynamic> json) {
    return HealthChallenge(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      type: json['type'] ?? '',
      difficulty: json['difficulty'] ?? '',
      duration: ChallengeDuration.fromJson(json['duration'] ?? {}),
      target: ChallengeTarget.fromJson(json['target'] ?? {}),
      rewards: ChallengeRewards.fromJson(json['rewards'] ?? {}),
      isActive: json['isActive'] ?? false,
      enrollmentStatus: json['enrollmentStatus'],
      userProgress: json['userProgress'] != null ? ChallengeProgress.fromJson(json['userProgress']) : null,
    );
  }
}

// Challenge Duration Model
class ChallengeDuration {
  final int value;
  final String unit;

  ChallengeDuration({
    required this.value,
    required this.unit,
  });

  factory ChallengeDuration.fromJson(Map<String, dynamic> json) {
    return ChallengeDuration(
      value: json['value'] ?? 1,
      unit: json['unit'] ?? 'days',
    );
  }
}

// Challenge Target Model
class ChallengeTarget {
  final String metric;
  final double value;
  final String unit;

  ChallengeTarget({
    required this.metric,
    required this.value,
    required this.unit,
  });

  factory ChallengeTarget.fromJson(Map<String, dynamic> json) {
    return ChallengeTarget(
      metric: json['metric'] ?? '',
      value: (json['value'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
    );
  }
}

// Challenge Rewards Model
class ChallengeRewards {
  final int points;
  final List<String> badges;
  final List<String> achievements;

  ChallengeRewards({
    required this.points,
    required this.badges,
    required this.achievements,
  });

  factory ChallengeRewards.fromJson(Map<String, dynamic> json) {
    return ChallengeRewards(
      points: json['points'] ?? 0,
      badges: (json['badges'] as List?)?.cast<String>() ?? [],
      achievements: (json['achievements'] as List?)?.cast<String>() ?? [],
    );
  }
}

// Challenge Progress Model
class ChallengeProgress {
  final String id;
  final String status;
  final DateTime startDate;
  final DateTime? completionDate;
  final ProgressData progress;
  final List<DailyLog> dailyLogs;
  final ProgressRewards rewards;

  ChallengeProgress({
    required this.id,
    required this.status,
    required this.startDate,
    this.completionDate,
    required this.progress,
    required this.dailyLogs,
    required this.rewards,
  });

  factory ChallengeProgress.fromJson(Map<String, dynamic> json) {
    return ChallengeProgress(
      id: json['_id'] ?? '',
      status: json['status'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      completionDate: json['completionDate'] != null ? DateTime.parse(json['completionDate']) : null,
      progress: ProgressData.fromJson(json['progress'] ?? {}),
      dailyLogs: (json['dailyLogs'] as List?)?.map((log) => DailyLog.fromJson(log)).toList() ?? [],
      rewards: ProgressRewards.fromJson(json['rewards'] ?? {}),
    );
  }
}

// Progress Data Model
class ProgressData {
  final double currentValue;
  final double targetValue;
  final double percentage;
  final int streak;
  final int bestStreak;

  ProgressData({
    required this.currentValue,
    required this.targetValue,
    required this.percentage,
    required this.streak,
    required this.bestStreak,
  });

  factory ProgressData.fromJson(Map<String, dynamic> json) {
    return ProgressData(
      currentValue: (json['currentValue'] ?? 0).toDouble(),
      targetValue: (json['targetValue'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
      streak: json['streak'] ?? 0,
      bestStreak: json['bestStreak'] ?? 0,
    );
  }
}

// Daily Log Model
class DailyLog {
  final DateTime date;
  final double value;
  final bool achieved;
  final String? notes;
  final DateTime timestamp;

  DailyLog({
    required this.date,
    required this.value,
    required this.achieved,
    this.notes,
    required this.timestamp,
  });

  factory DailyLog.fromJson(Map<String, dynamic> json) {
    return DailyLog(
      date: DateTime.parse(json['date']),
      value: (json['value'] ?? 0).toDouble(),
      achieved: json['achieved'] ?? false,
      notes: json['notes'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

// Progress Rewards Model
class ProgressRewards {
  final int pointsEarned;
  final List<String> badgesEarned;
  final List<String> achievementsUnlocked;

  ProgressRewards({
    required this.pointsEarned,
    required this.badgesEarned,
    required this.achievementsUnlocked,
  });

  factory ProgressRewards.fromJson(Map<String, dynamic> json) {
    return ProgressRewards(
      pointsEarned: json['pointsEarned'] ?? 0,
      badgesEarned: (json['badgesEarned'] as List?)?.cast<String>() ?? [],
      achievementsUnlocked: (json['achievementsUnlocked'] as List?)?.cast<String>() ?? [],
    );
  }
}

// Health Goal Model
class HealthGoal {
  final String id;
  final String title;
  final String description;
  final String category;
  final String goalType;
  final GoalTarget target;
  final List<Milestone> milestones;
  final String status;
  final GoalProgress progress;
  final List<Reminder> reminders;

  HealthGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.goalType,
    required this.target,
    required this.milestones,
    required this.status,
    required this.progress,
    required this.reminders,
  });

  factory HealthGoal.fromJson(Map<String, dynamic> json) {
    return HealthGoal(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      goalType: json['goalType'] ?? '',
      target: GoalTarget.fromJson(json['target'] ?? {}),
      milestones: (json['milestones'] as List?)?.map((m) => Milestone.fromJson(m)).toList() ?? [],
      status: json['status'] ?? '',
      progress: GoalProgress.fromJson(json['progress'] ?? {}),
      reminders: (json['reminders'] as List?)?.map((r) => Reminder.fromJson(r)).toList() ?? [],
    );
  }
}

// Goal Target Model
class GoalTarget {
  final String metric;
  final double currentValue;
  final double targetValue;
  final String unit;
  final DateTime deadline;

  GoalTarget({
    required this.metric,
    required this.currentValue,
    required this.targetValue,
    required this.unit,
    required this.deadline,
  });

  factory GoalTarget.fromJson(Map<String, dynamic> json) {
    return GoalTarget(
      metric: json['metric'] ?? '',
      currentValue: (json['currentValue'] ?? 0).toDouble(),
      targetValue: (json['targetValue'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      deadline: DateTime.parse(json['deadline']),
    );
  }
}

// Milestone Model
class Milestone {
  final String title;
  final double value;
  final bool achieved;
  final DateTime? achievedDate;
  final MilestoneReward reward;

  Milestone({
    required this.title,
    required this.value,
    required this.achieved,
    this.achievedDate,
    required this.reward,
  });

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      title: json['title'] ?? '',
      value: (json['value'] ?? 0).toDouble(),
      achieved: json['achieved'] ?? false,
      achievedDate: json['achievedDate'] != null ? DateTime.parse(json['achievedDate']) : null,
      reward: MilestoneReward.fromJson(json['reward'] ?? {}),
    );
  }
}

// Milestone Reward Model
class MilestoneReward {
  final int? points;
  final String? badge;

  MilestoneReward({
    this.points,
    this.badge,
  });

  factory MilestoneReward.fromJson(Map<String, dynamic> json) {
    return MilestoneReward(
      points: json['points'],
      badge: json['badge'],
    );
  }
}

// Goal Progress Model
class GoalProgress {
  final double currentValue;
  final double percentage;
  final DateTime lastUpdated;

  GoalProgress({
    required this.currentValue,
    required this.percentage,
    required this.lastUpdated,
  });

  factory GoalProgress.fromJson(Map<String, dynamic> json) {
    return GoalProgress(
      currentValue: (json['currentValue'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}

// Reminder Model
class Reminder {
  final String type;
  final String frequency;
  final String time;
  final bool enabled;

  Reminder({
    required this.type,
    required this.frequency,
    required this.time,
    required this.enabled,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      type: json['type'] ?? '',
      frequency: json['frequency'] ?? '',
      time: json['time'] ?? '',
      enabled: json['enabled'] ?? false,
    );
  }
}

// Leaderboard Entry Model
class LeaderboardEntry {
  final int rank;
  final LeaderboardUser user;
  final int level;
  final int points;
  final int challengesCompleted;
  final int bestStreak;
  final int badges;
  final int score;

  LeaderboardEntry({
    required this.rank,
    required this.user,
    required this.level,
    required this.points,
    required this.challengesCompleted,
    required this.bestStreak,
    required this.badges,
    required this.score,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] ?? 0,
      user: LeaderboardUser.fromJson(json['user'] ?? {}),
      level: json['level'] ?? 1,
      points: json['points'] ?? 0,
      challengesCompleted: json['challengesCompleted'] ?? 0,
      bestStreak: json['bestStreak'] ?? 0,
      badges: json['badges'] ?? 0,
      score: json['score'] ?? 0,
    );
  }
}

// Leaderboard User Model
class LeaderboardUser {
  final String id;
  final String name;
  final String city;

  LeaderboardUser({
    required this.id,
    required this.name,
    required this.city,
  });

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Anonymous',
      city: json['city'] ?? 'Unknown',
    );
  }
}
