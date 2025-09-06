import 'package:flutter/material.dart';
import '../../../core/constants/app_styles.dart';

class GamificationScreen extends StatefulWidget {
  const GamificationScreen({super.key});

  @override
  State<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final int _currentLevel = 15;
  final int _currentXP = 2750;
  final int _nextLevelXP = 3000;
  final int _totalPoints = 18650;

  final List<Achievement> _achievements = [
    Achievement(
      id: '1',
      title: 'Health Warrior',
      description: 'Complete 30 days of health tracking',
      icon: Icons.shield,
      isUnlocked: true,
      xpReward: 500,
      unlockedDate: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Achievement(
      id: '2',
      title: 'Step Master',
      description: 'Walk 10,000 steps in a day',
      icon: Icons.directions_walk,
      isUnlocked: true,
      xpReward: 200,
      unlockedDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Achievement(
      id: '3',
      title: 'Early Bird',
      description: 'Log health data before 8 AM for 7 days',
      icon: Icons.wb_sunny,
      isUnlocked: false,
      xpReward: 300,
      progress: 4,
      maxProgress: 7,
    ),
    Achievement(
      id: '4',
      title: 'Vital Signs Expert',
      description: 'Track vitals consistently for 14 days',
      icon: Icons.favorite,
      isUnlocked: true,
      xpReward: 400,
      unlockedDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Achievement(
      id: '5',
      title: 'Social Helper',
      description: 'Help 5 people with health advice',
      icon: Icons.people,
      isUnlocked: false,
      xpReward: 250,
      progress: 2,
      maxProgress: 5,
    ),
    Achievement(
      id: '6',
      title: 'Medication Master',
      description: 'Take medications on time for 30 days',
      icon: Icons.medical_services,
      isUnlocked: false,
      xpReward: 600,
      progress: 12,
      maxProgress: 30,
    ),
  ];

  final List<Challenge> _dailyChallenges = [
    Challenge(
      id: '1',
      title: 'Daily Steps',
      description: 'Walk 8,000 steps today',
      icon: Icons.directions_walk,
      xpReward: 50,
      isCompleted: true,
      progress: 8247,
      maxProgress: 8000,
    ),
    Challenge(
      id: '2',
      title: 'Water Intake',
      description: 'Drink 8 glasses of water',
      icon: Icons.local_drink,
      xpReward: 30,
      isCompleted: false,
      progress: 5,
      maxProgress: 8,
    ),
    Challenge(
      id: '3',
      title: 'Health Check',
      description: 'Record your vitals',
      icon: Icons.monitor_heart,
      xpReward: 40,
      isCompleted: false,
      progress: 0,
      maxProgress: 1,
    ),
  ];

  final List<Reward> _availableRewards = [
    Reward(
      id: '1',
      title: 'Premium Theme',
      description: 'Unlock a special app theme',
      icon: Icons.palette,
      cost: 1000,
      isUnlocked: false,
    ),
    Reward(
      id: '2',
      title: 'Health Report',
      description: 'Get a detailed health report',
      icon: Icons.description,
      cost: 500,
      isUnlocked: true,
    ),
    Reward(
      id: '3',
      title: 'Virtual Consultation',
      description: 'Free 15-min consultation',
      icon: Icons.video_call,
      cost: 2000,
      isUnlocked: false,
    ),
    Reward(
      id: '4',
      title: 'Fitness Guide',
      description: 'Personalized fitness plan',
      icon: Icons.fitness_center,
      cost: 750,
      isUnlocked: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Gamification'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Achievements'),
            Tab(text: 'Rewards'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildAchievementsTab(),
          _buildRewardsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlayerStats(),
          const SizedBox(height: 24),
          _buildLevelProgress(),
          const SizedBox(height: 24),
          Text(
            'Daily Challenges',
            style: AppTextStyles.headline6.copyWith(color: AppColors.grey800),
          ),
          const SizedBox(height: 16),
          ..._dailyChallenges.map(
            (challenge) => _buildChallengeCard(challenge),
          ),
          const SizedBox(height: 24),
          _buildStreakCard(),
        ],
      ),
    );
  }

  Widget _buildPlayerStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40, color: AppColors.primaryGreen),
          ),
          const SizedBox(height: 12),
          Text(
            'Health Champion',
            style: AppTextStyles.headline6.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Level $_currentLevel',
            style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('XP', '$_currentXP'),
              _buildStatItem('Points', '$_totalPoints'),
              _buildStatItem('Rank', '#42'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headline5.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildLevelProgress() {
    final progress = _currentXP / _nextLevelXP;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level Progress',
                style: AppTextStyles.headline6.copyWith(
                  color: AppColors.grey800,
                ),
              ),
              Text(
                '${(_nextLevelXP - _currentXP)} XP to Level ${_currentLevel + 1}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.grey200,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            '$_currentXP / $_nextLevelXP XP',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(Challenge challenge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: challenge.isCompleted ? AppColors.success : AppColors.grey300,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: challenge.isCompleted
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.grey100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              challenge.icon,
              color: challenge.isCompleted
                  ? AppColors.success
                  : AppColors.grey600,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  challenge.description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: challenge.progress / challenge.maxProgress,
                  backgroundColor: AppColors.grey200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    challenge.isCompleted
                        ? AppColors.success
                        : AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              if (challenge.isCompleted)
                Icon(Icons.check_circle, color: AppColors.success)
              else
                Text(
                  '${challenge.progress}/${challenge.maxProgress}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              Text(
                '+${challenge.xpReward} XP',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryOrange, AppColors.primaryRed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.local_fire_department, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '7 Day Streak!',
                  style: AppTextStyles.headline6.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Keep logging daily for bonus XP',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+50 XP',
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab() {
    final unlockedAchievements = _achievements
        .where((a) => a.isUnlocked)
        .toList();
    final lockedAchievements = _achievements
        .where((a) => !a.isUnlocked)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Unlocked (${unlockedAchievements.length})',
            style: AppTextStyles.headline6.copyWith(color: AppColors.grey800),
          ),
          const SizedBox(height: 16),
          ...unlockedAchievements.map(
            (achievement) => _buildAchievementCard(achievement),
          ),
          const SizedBox(height: 24),
          Text(
            'Locked (${lockedAchievements.length})',
            style: AppTextStyles.headline6.copyWith(color: AppColors.grey800),
          ),
          const SizedBox(height: 16),
          ...lockedAchievements.map(
            (achievement) => _buildAchievementCard(achievement),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievement.isUnlocked
              ? AppColors.primaryGreen
              : AppColors.grey300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: achievement.isUnlocked
                  ? AppColors.primaryGreen.withOpacity(0.1)
                  : AppColors.grey100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement.icon,
              color: achievement.isUnlocked
                  ? AppColors.primaryGreen
                  : AppColors.grey400,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: achievement.isUnlocked
                        ? AppColors.grey800
                        : AppColors.grey600,
                  ),
                ),
                Text(
                  achievement.description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
                if (!achievement.isUnlocked &&
                    achievement.progress != null) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: achievement.progress! / achievement.maxProgress!,
                    backgroundColor: AppColors.grey200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${achievement.progress}/${achievement.maxProgress}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ],
                if (achievement.isUnlocked &&
                    achievement.unlockedDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Unlocked ${_formatDate(achievement.unlockedDate!)}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              if (achievement.isUnlocked)
                Icon(Icons.check_circle, color: AppColors.success)
              else
                Icon(Icons.lock, color: AppColors.grey400),
              const SizedBox(height: 4),
              Text(
                '+${achievement.xpReward} XP',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.stars, color: AppColors.primaryBlue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Points',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$_totalPoints points',
                        style: AppTextStyles.headline5.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Redeem Rewards',
            style: AppTextStyles.headline6.copyWith(color: AppColors.grey800),
          ),
          const SizedBox(height: 16),
          ..._availableRewards.map((reward) => _buildRewardCard(reward)),
        ],
      ),
    );
  }

  Widget _buildRewardCard(Reward reward) {
    final canAfford = _totalPoints >= reward.cost;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: reward.isUnlocked ? AppColors.success : AppColors.grey300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: !reward.isUnlocked && canAfford
              ? () {
                  _showRedeemDialog(reward);
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: reward.isUnlocked
                        ? AppColors.success.withOpacity(0.1)
                        : canAfford
                        ? AppColors.primaryBlue.withOpacity(0.1)
                        : AppColors.grey100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    reward.icon,
                    color: reward.isUnlocked
                        ? AppColors.success
                        : canAfford
                        ? AppColors.primaryBlue
                        : AppColors.grey400,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reward.title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: reward.isUnlocked
                              ? AppColors.grey800
                              : canAfford
                              ? AppColors.grey800
                              : AppColors.grey600,
                        ),
                      ),
                      Text(
                        reward.description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (reward.isUnlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Owned',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: canAfford
                              ? AppColors.primaryBlue
                              : AppColors.grey400,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${reward.cost} pts',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRedeemDialog(Reward reward) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Redeem ${reward.title}'),
        content: Text(
          'Are you sure you want to redeem "${reward.title}" for ${reward.cost} points?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Successfully redeemed ${reward.title}!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'today';
    } else if (difference == 1) {
      return 'yesterday';
    } else {
      return '$difference days ago';
    }
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final int xpReward;
  final DateTime? unlockedDate;
  final int? progress;
  final int? maxProgress;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.xpReward,
    this.unlockedDate,
    this.progress,
    this.maxProgress,
  });
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int xpReward;
  final bool isCompleted;
  final int progress;
  final int maxProgress;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.xpReward,
    required this.isCompleted,
    required this.progress,
    required this.maxProgress,
  });
}

class Reward {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int cost;
  final bool isUnlocked;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.cost,
    required this.isUnlocked,
  });
}
