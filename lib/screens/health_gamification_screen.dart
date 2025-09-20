import 'package:flutter/material.dart';

class HealthGamificationScreen extends StatefulWidget {
  final Map<String, dynamic>? patientData;

  const HealthGamificationScreen({super.key, this.patientData});

  @override
  State<HealthGamificationScreen> createState() => _HealthGamificationScreenState();
}

class _HealthGamificationScreenState extends State<HealthGamificationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  final List<Map<String, dynamic>> _challenges = [];
  final List<Map<String, dynamic>> _achievements = [];
  final Map<String, int> _streaks = {
    'steps': 0,
    'water': 0,
    'meditation': 0,
    'sleep': 0,
  };
  
  int _totalPoints = 0;
  int _currentLevel = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSampleData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadSampleData() {
    // Sample challenges
    _challenges.addAll([
      {
        'id': '1',
        'title': 'Daily Walker',
        'description': 'Walk 10,000 steps today',
        'type': 'daily',
        'points': 50,
        'progress': 7500,
        'target': 10000,
        'isCompleted': false,
        'icon': Icons.directions_walk,
        'color': Colors.green,
      },
      {
        'id': '2',
        'title': 'Hydration Hero',
        'description': 'Drink 8 glasses of water',
        'type': 'daily',
        'points': 30,
        'progress': 6,
        'target': 8,
        'isCompleted': false,
        'icon': Icons.local_drink,
        'color': Colors.blue,
      },
      {
        'id': '3',
        'title': 'Meditation Master',
        'description': 'Meditate for 10 minutes',
        'type': 'daily',
        'points': 40,
        'progress': 0,
        'target': 10,
        'isCompleted': false,
        'icon': Icons.self_improvement,
        'color': Colors.purple,
      },
      {
        'id': '4',
        'title': 'Weekly Warrior',
        'description': 'Complete 5 workouts this week',
        'type': 'weekly',
        'points': 200,
        'progress': 3,
        'target': 5,
        'isCompleted': false,
        'icon': Icons.fitness_center,
        'color': Colors.orange,
      },
    ]);

    // Sample achievements
    _achievements.addAll([
      {
        'id': '1',
        'title': 'First Steps',
        'description': 'Completed your first challenge',
        'points': 100,
        'isUnlocked': true,
        'unlockedDate': '2024-01-15',
        'icon': Icons.star,
        'color': Colors.amber,
      },
      {
        'id': '2',
        'title': 'Streak Master',
        'description': 'Maintained a 7-day streak',
        'points': 250,
        'isUnlocked': false,
        'icon': Icons.local_fire_department,
        'color': Colors.red,
      },
      {
        'id': '3',
        'title': 'Point Collector',
        'description': 'Earned 1000 total points',
        'points': 500,
        'isUnlocked': false,
        'icon': Icons.emoji_events,
        'color': Colors.amber,
      },
    ]);

    _totalPoints = 450;
    _streaks['steps'] = 3;
    _streaks['water'] = 5;
    _streaks['meditation'] = 1;
    _streaks['sleep'] = 2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Gamification'),
        backgroundColor: Colors.purple.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.emoji_events), text: 'Overview'),
            Tab(icon: Icon(Icons.assignment), text: 'Challenges'),
            Tab(icon: Icon(Icons.stars), text: 'Achievements'),
            Tab(icon: Icon(Icons.leaderboard), text: 'Leaderboard'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade50, Colors.white],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildChallengesTab(),
            _buildAchievementsTab(),
            _buildLeaderboardTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLevelCard(),
          const SizedBox(height: 16),
          _buildStreaksCard(),
          const SizedBox(height: 16),
          _buildQuickStatsCard(),
          const SizedBox(height: 16),
          _buildDailyChallengesPreview(),
        ],
      ),
    );
  }

  Widget _buildLevelCard() {
    double progressPercentage = (_totalPoints % 100) / 100;
    
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade400, Colors.purple.shade600],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Level $_currentLevel',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$_totalPoints Total Points',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress to Level ${_currentLevel + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${(_totalPoints % 100)}/100',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progressPercentage,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreaksCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_fire_department, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Current Streaks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStreakItem('Steps', _streaks['steps']!, Icons.directions_walk, Colors.green)),
                Expanded(child: _buildStreakItem('Water', _streaks['water']!, Icons.local_drink, Colors.blue)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStreakItem('Meditation', _streaks['meditation']!, Icons.self_improvement, Colors.purple)),
                Expanded(child: _buildStreakItem('Sleep', _streaks['sleep']!, Icons.bedtime, Colors.indigo)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakItem(String title, int streak, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            '$streak',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Stats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Challenges Completed', '23', Colors.green),
                ),
                Expanded(
                  child: _buildStatItem('Achievements Unlocked', '1', Colors.amber),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('This Week Points', '180', Colors.purple),
                ),
                Expanded(
                  child: _buildStatItem('Best Streak', '7 days', Colors.orange),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChallengesPreview() {
    final dailyChallenges = _challenges.where((c) => c['type'] == 'daily').take(3).toList();
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Today\'s Challenges',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => _tabController.animateTo(1),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...dailyChallenges.map((challenge) => _buildChallengePreviewItem(challenge)),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengePreviewItem(Map<String, dynamic> challenge) {
    double progress = (challenge['progress'] / challenge['target']).clamp(0.0, 1.0);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: challenge['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(challenge['icon'], color: challenge['color']),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(challenge['color']),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${challenge['points']} pts',
            style: TextStyle(
              color: challenge['color'],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ..._challenges.map((challenge) => _buildChallengeCard(challenge)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(Map<String, dynamic> challenge) {
    double progress = (challenge['progress'] / challenge['target']).clamp(0.0, 1.0);
    bool isCompleted = challenge['isCompleted'];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: challenge['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    challenge['icon'],
                    color: challenge['color'],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        challenge['description'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: challenge['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${challenge['points']} pts',
                    style: TextStyle(
                      color: challenge['color'],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      '${challenge['progress']}/${challenge['target']} ${_getProgressUnit(challenge['title'])}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: challenge['color'],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(challenge['color']),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Chip(
                  label: Text(challenge['type']),
                  backgroundColor: challenge['color'].withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: challenge['color'],
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 4),
                        const Text(
                          'Completed',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getProgressUnit(String challengeTitle) {
    if (challengeTitle.contains('steps')) return 'steps';
    if (challengeTitle.contains('water')) return 'glasses';
    if (challengeTitle.contains('Meditation')) return 'minutes';
    if (challengeTitle.contains('workout')) return 'workouts';
    return '';
  }

  Widget _buildAchievementsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ..._achievements.map((achievement) => _buildAchievementCard(achievement)),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    bool isUnlocked = achievement['isUnlocked'];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isUnlocked ? null : Colors.grey.shade100,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUnlocked 
                    ? achievement['color'].withOpacity(0.1)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                achievement['icon'],
                color: isUnlocked ? achievement['color'] : Colors.grey.shade500,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? Colors.black : Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    achievement['description'],
                    style: TextStyle(
                      color: isUnlocked ? Colors.grey.shade600 : Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
                  if (isUnlocked && achievement['unlockedDate'] != null)
                    Text(
                      'Unlocked: ${achievement['unlockedDate']}',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isUnlocked 
                    ? achievement['color'].withOpacity(0.1)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${achievement['points']} pts',
                style: TextStyle(
                  color: isUnlocked ? achievement['color'] : Colors.grey.shade500,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    final leaderboardData = [
      {'name': 'You', 'points': _totalPoints, 'rank': 5, 'avatar': Icons.person},
      {'name': 'Sarah Johnson', 'points': 1250, 'rank': 1, 'avatar': Icons.person_2},
      {'name': 'Mike Chen', 'points': 1180, 'rank': 2, 'avatar': Icons.person_3},
      {'name': 'Emily Davis', 'points': 920, 'rank': 3, 'avatar': Icons.person_4},
      {'name': 'David Wilson', 'points': 680, 'rank': 4, 'avatar': Icons.person},
      {'name': 'Lisa Brown', 'points': 320, 'rank': 6, 'avatar': Icons.person_2},
      {'name': 'Tom Garcia', 'points': 280, 'rank': 7, 'avatar': Icons.person_3},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Leaderboard',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...leaderboardData.map((user) => _buildLeaderboardItem(user)),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> user) {
    bool isCurrentUser = user['name'] == 'You';
    Color rankColor = _getRankColor(user['rank']);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isCurrentUser ? 4 : 1,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isCurrentUser ? Colors.purple.shade50 : null,
          border: isCurrentUser ? Border.all(color: Colors.purple.shade300) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: rankColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  '#${user['rank']}',
                  style: TextStyle(
                    color: rankColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Icon(user['avatar'], color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                user['name'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            Text(
              '${user['points']} pts',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: rankColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber; // Gold
      case 2:
        return Colors.grey; // Silver
      case 3:
        return Colors.brown; // Bronze
      default:
        return Colors.purple;
    }
  }
}