const express = require('express');
const { body, query, validationResult } = require('express-validator');
const mongoose = require('mongoose');
const Patient = require('../models/Patient');
const Doctor = require('../models/Doctor');
const { authenticate, authenticatePatient, authenticateDoctor } = require('../middleware/auth');
const logger = require('../utils/logger');

const router = express.Router();

// Health Challenge Schema
const HealthChallengeSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true
  },
  description: String,
  category: {
    type: String,
    enum: ['fitness', 'nutrition', 'mental_health', 'medication_adherence', 'preventive_care', 'lifestyle'],
    required: true
  },
  type: {
    type: String,
    enum: ['daily', 'weekly', 'monthly', 'one_time'],
    default: 'daily'
  },
  difficulty: {
    type: String,
    enum: ['easy', 'medium', 'hard'],
    default: 'medium'
  },
  duration: {
    value: Number, // Duration in days
    unit: { type: String, default: 'days' }
  },
  target: {
    metric: String, // e.g., 'steps', 'water_glasses', 'sleep_hours'
    value: Number,
    unit: String
  },
  rewards: {
    points: { type: Number, default: 10 },
    badges: [String],
    achievements: [String]
  },
  isActive: {
    type: Boolean,
    default: true
  },
  startDate: Date,
  endDate: Date,
  createdBy: {
    userId: { type: mongoose.Types.ObjectId, refPath: 'createdBy.userType' },
    userType: { type: String, enum: ['Doctor', 'Admin'] },
    name: String
  }
}, {
  timestamps: true
});

// User Challenge Progress Schema
const ChallengeProgressSchema = new mongoose.Schema({
  user: {
    type: mongoose.Types.ObjectId,
    ref: 'Patient',
    required: true
  },
  challenge: {
    type: mongoose.Types.ObjectId,
    ref: 'HealthChallenge',
    required: true
  },
  status: {
    type: String,
    enum: ['enrolled', 'in_progress', 'completed', 'failed', 'abandoned'],
    default: 'enrolled'
  },
  startDate: {
    type: Date,
    default: Date.now
  },
  completionDate: Date,
  progress: {
    currentValue: { type: Number, default: 0 },
    targetValue: Number,
    percentage: { type: Number, default: 0 },
    streak: { type: Number, default: 0 },
    bestStreak: { type: Number, default: 0 }
  },
  dailyLogs: [{
    date: Date,
    value: Number,
    achieved: Boolean,
    notes: String,
    timestamp: { type: Date, default: Date.now }
  }],
  rewards: {
    pointsEarned: { type: Number, default: 0 },
    badgesEarned: [String],
    achievementsUnlocked: [String]
  },
  feedback: {
    rating: Number,
    comment: String,
    suggestions: String
  }
}, {
  timestamps: true
});

// User Profile & Gamification Schema
const UserGamificationSchema = new mongoose.Schema({
  user: {
    type: mongoose.Types.ObjectId,
    ref: 'Patient',
    required: true,
    unique: true
  },
  level: {
    current: { type: Number, default: 1 },
    xp: { type: Number, default: 0 },
    xpToNext: { type: Number, default: 100 }
  },
  points: {
    total: { type: Number, default: 0 },
    available: { type: Number, default: 0 },
    spent: { type: Number, default: 0 }
  },
  badges: [{
    badgeId: String,
    name: String,
    description: String,
    earnedDate: { type: Date, default: Date.now },
    category: String,
    rarity: { type: String, enum: ['common', 'rare', 'epic', 'legendary'], default: 'common' }
  }],
  achievements: [{
    achievementId: String,
    name: String,
    description: String,
    unlockedDate: { type: Date, default: Date.now },
    progress: {
      current: Number,
      target: Number,
      percentage: Number
    }
  }],
  statistics: {
    challengesCompleted: { type: Number, default: 0 },
    challengesFailed: { type: Number, default: 0 },
    totalDaysActive: { type: Number, default: 0 },
    currentStreak: { type: Number, default: 0 },
    bestStreak: { type: Number, default: 0 },
    averageRating: { type: Number, default: 0 }
  },
  preferences: {
    challengeTypes: [String],
    difficulty: { type: String, enum: ['easy', 'medium', 'hard'], default: 'medium' },
    notifications: {
      daily: { type: Boolean, default: true },
      weekly: { type: Boolean, default: true },
      achievements: { type: Boolean, default: true }
    }
  },
  socialFeatures: {
    friends: [{ type: mongoose.Types.ObjectId, ref: 'Patient' }],
    leaderboard: {
      visible: { type: Boolean, default: true },
      ranking: Number
    },
    sharing: {
      achievements: { type: Boolean, default: true },
      progress: { type: Boolean, default: false }
    }
  }
}, {
  timestamps: true
});

// Health Goal Schema
const HealthGoalSchema = new mongoose.Schema({
  user: {
    type: mongoose.Types.ObjectId,
    ref: 'Patient',
    required: true
  },
  title: {
    type: String,
    required: true
  },
  description: String,
  category: {
    type: String,
    enum: ['weight_management', 'fitness', 'nutrition', 'mental_health', 'medication', 'vitals', 'habits'],
    required: true
  },
  goalType: {
    type: String,
    enum: ['increase', 'decrease', 'maintain', 'achieve'],
    required: true
  },
  target: {
    metric: String,
    currentValue: Number,
    targetValue: Number,
    unit: String,
    deadline: Date
  },
  milestones: [{
    title: String,
    value: Number,
    achieved: { type: Boolean, default: false },
    achievedDate: Date,
    reward: {
      points: Number,
      badge: String
    }
  }],
  status: {
    type: String,
    enum: ['active', 'completed', 'paused', 'cancelled'],
    default: 'active'
  },
  progress: {
    currentValue: Number,
    percentage: { type: Number, default: 0 },
    lastUpdated: Date
  },
  reminders: [{
    type: String,
    frequency: String,
    time: String,
    enabled: { type: Boolean, default: true }
  }]
}, {
  timestamps: true
});

// Create models
const HealthChallenge = mongoose.model('HealthChallenge', HealthChallengeSchema);
const ChallengeProgress = mongoose.model('ChallengeProgress', ChallengeProgressSchema);
const UserGamification = mongoose.model('UserGamification', UserGamificationSchema);
const HealthGoal = mongoose.model('HealthGoal', HealthGoalSchema);

// @route   GET /api/v1/gamification/profile
// @desc    Get user's gamification profile
// @access  Private (Patient)
router.get('/profile', authenticatePatient, async (req, res) => {
  try {
    const userId = req.user.id;

    let profile = await UserGamification.findOne({ user: userId });

    if (!profile) {
      // Create initial profile
      profile = new UserGamification({
        user: userId,
        level: { current: 1, xp: 0, xpToNext: 100 },
        points: { total: 0, available: 0, spent: 0 },
        badges: [],
        achievements: [],
        statistics: {
          challengesCompleted: 0,
          challengesFailed: 0,
          totalDaysActive: 0,
          currentStreak: 0,
          bestStreak: 0,
          averageRating: 0
        }
      });
      await profile.save();
    }

    // Get recent activities
    const recentChallenges = await ChallengeProgress.find({ user: userId })
      .populate('challenge', 'title category type')
      .sort({ updatedAt: -1 })
      .limit(5);

    // Calculate next level requirements
    const nextLevelXP = profile.level.current * 100;
    const progressToNext = ((profile.level.xp % 100) / 100) * 100;

    res.json({
      status: 'success',
      data: {
        profile: {
          ...profile.toObject(),
          level: {
            ...profile.level,
            progressToNext: progressToNext.toFixed(1)
          }
        },
        recentActivities: recentChallenges
      }
    });

  } catch (error) {
    logger.error('Get gamification profile error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching gamification profile'
    });
  }
});

// @route   GET /api/v1/gamification/challenges
// @desc    Get available health challenges
// @access  Private (Patient)
router.get('/challenges', authenticatePatient, [
  query('category').optional().isIn(['fitness', 'nutrition', 'mental_health', 'medication_adherence', 'preventive_care', 'lifestyle']),
  query('difficulty').optional().isIn(['easy', 'medium', 'hard']),
  query('type').optional().isIn(['daily', 'weekly', 'monthly', 'one_time']),
  query('status').optional().isIn(['available', 'enrolled', 'completed'])
], async (req, res) => {
  try {
    const userId = req.user.id;
    
    // Get user's current challenges
    const userChallenges = await ChallengeProgress.find({ user: userId });
    const enrolledChallengeIds = userChallenges.map(uc => uc.challenge.toString());

    let query = { isActive: true };
    if (req.query.category) query.category = req.query.category;
    if (req.query.difficulty) query.difficulty = req.query.difficulty;
    if (req.query.type) query.type = req.query.type;

    const challenges = await HealthChallenge.find(query)
      .sort({ createdAt: -1 });

    // Add enrollment status to each challenge
    const challengesWithStatus = challenges.map(challenge => ({
      ...challenge.toObject(),
      enrollmentStatus: enrolledChallengeIds.includes(challenge._id.toString()) ? 'enrolled' : 'available',
      userProgress: userChallenges.find(uc => uc.challenge.toString() === challenge._id.toString())
    }));

    // Filter by status if requested
    let filteredChallenges = challengesWithStatus;
    if (req.query.status) {
      if (req.query.status === 'available') {
        filteredChallenges = challengesWithStatus.filter(c => c.enrollmentStatus === 'available');
      } else if (req.query.status === 'enrolled') {
        filteredChallenges = challengesWithStatus.filter(c => c.enrollmentStatus === 'enrolled');
      } else if (req.query.status === 'completed') {
        filteredChallenges = challengesWithStatus.filter(c => 
          c.userProgress && c.userProgress.status === 'completed'
        );
      }
    }

    res.json({
      status: 'success',
      data: {
        challenges: filteredChallenges,
        total: filteredChallenges.length,
        filters: {
          category: req.query.category,
          difficulty: req.query.difficulty,
          type: req.query.type,
          status: req.query.status
        }
      }
    });

  } catch (error) {
    logger.error('Get health challenges error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching health challenges'
    });
  }
});

// @route   POST /api/v1/gamification/challenges/:challengeId/enroll
// @desc    Enroll in a health challenge
// @access  Private (Patient)
router.post('/challenges/:challengeId/enroll', authenticatePatient, async (req, res) => {
  try {
    const { challengeId } = req.params;
    const userId = req.user.id;

    const challenge = await HealthChallenge.findById(challengeId);
    if (!challenge || !challenge.isActive) {
      return res.status(404).json({
        status: 'error',
        message: 'Challenge not found or inactive'
      });
    }

    // Check if already enrolled
    const existingProgress = await ChallengeProgress.findOne({
      user: userId,
      challenge: challengeId,
      status: { $in: ['enrolled', 'in_progress'] }
    });

    if (existingProgress) {
      return res.status(400).json({
        status: 'error',
        message: 'Already enrolled in this challenge'
      });
    }

    // Create challenge progress
    const progress = new ChallengeProgress({
      user: userId,
      challenge: challengeId,
      status: 'enrolled',
      progress: {
        currentValue: 0,
        targetValue: challenge.target.value,
        percentage: 0,
        streak: 0,
        bestStreak: 0
      }
    });

    await progress.save();

    // Award enrollment points
    await awardPoints(userId, 5, 'Challenge enrollment');

    logger.info(`User enrolled in challenge: ${userId}`, {
      challengeId,
      challengeTitle: challenge.title
    });

    res.status(201).json({
      status: 'success',
      message: 'Successfully enrolled in challenge',
      data: { progress }
    });

  } catch (error) {
    logger.error('Enroll in challenge error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error enrolling in challenge'
    });
  }
});

// @route   POST /api/v1/gamification/challenges/:challengeId/log
// @desc    Log progress for a challenge
// @access  Private (Patient)
router.post('/challenges/:challengeId/log', authenticatePatient, [
  body('value').isNumeric().withMessage('Value must be a number'),
  body('date').optional().isISO8601(),
  body('notes').optional().isString()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { challengeId } = req.params;
    const { value, date, notes } = req.body;
    const userId = req.user.id;

    const progress = await ChallengeProgress.findOne({
      user: userId,
      challenge: challengeId,
      status: { $in: ['enrolled', 'in_progress'] }
    }).populate('challenge');

    if (!progress) {
      return res.status(404).json({
        status: 'error',
        message: 'Challenge progress not found or not active'
      });
    }

    const logDate = date ? new Date(date) : new Date();
    const achieved = value >= progress.challenge.target.value;

    // Add daily log
    progress.dailyLogs.push({
      date: logDate,
      value,
      achieved,
      notes
    });

    // Update progress
    progress.progress.currentValue = value;
    progress.progress.percentage = Math.min((value / progress.progress.targetValue) * 100, 100);
    
    if (achieved) {
      progress.progress.streak += 1;
      progress.progress.bestStreak = Math.max(progress.progress.bestStreak, progress.progress.streak);
    } else {
      progress.progress.streak = 0;
    }

    // Check for completion
    if (progress.progress.percentage >= 100) {
      progress.status = 'completed';
      progress.completionDate = new Date();
      
      // Award completion rewards
      await awardPoints(userId, progress.challenge.rewards.points, `Completed challenge: ${progress.challenge.title}`);
      await awardBadges(userId, progress.challenge.rewards.badges);
      await updateStatistics(userId, 'challengesCompleted', 1);
    } else {
      progress.status = 'in_progress';
    }

    await progress.save();

    // Award daily participation points
    if (achieved) {
      await awardPoints(userId, 2, 'Daily challenge achievement');
    } else {
      await awardPoints(userId, 1, 'Challenge participation');
    }

    logger.info(`Challenge progress logged: ${userId}`, {
      challengeId,
      value,
      achieved,
      status: progress.status
    });

    res.json({
      status: 'success',
      message: 'Progress logged successfully',
      data: { 
        progress,
        achieved,
        pointsEarned: achieved ? 2 : 1
      }
    });

  } catch (error) {
    logger.error('Log challenge progress error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error logging challenge progress'
    });
  }
});

// @route   GET /api/v1/gamification/progress
// @desc    Get user's challenge progress
// @access  Private (Patient)
router.get('/progress', authenticatePatient, [
  query('status').optional().isIn(['enrolled', 'in_progress', 'completed', 'failed', 'abandoned'])
], async (req, res) => {
  try {
    const userId = req.user.id;
    
    let query = { user: userId };
    if (req.query.status) {
      query.status = req.query.status;
    }

    const progressList = await ChallengeProgress.find(query)
      .populate('challenge', 'title description category type difficulty target rewards')
      .sort({ updatedAt: -1 });

    // Calculate summary statistics
    const summary = {
      totalChallenges: progressList.length,
      active: progressList.filter(p => ['enrolled', 'in_progress'].includes(p.status)).length,
      completed: progressList.filter(p => p.status === 'completed').length,
      failed: progressList.filter(p => p.status === 'failed').length,
      totalPointsEarned: progressList.reduce((sum, p) => sum + p.rewards.pointsEarned, 0),
      averageCompletion: progressList.length > 0 ? 
        progressList.reduce((sum, p) => sum + p.progress.percentage, 0) / progressList.length : 0
    };

    res.json({
      status: 'success',
      data: {
        progress: progressList,
        summary
      }
    });

  } catch (error) {
    logger.error('Get challenge progress error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching challenge progress'
    });
  }
});

// @route   POST /api/v1/gamification/goals
// @desc    Create a new health goal
// @access  Private (Patient)
router.post('/goals', authenticatePatient, [
  body('title').notEmpty().withMessage('Goal title is required'),
  body('category').isIn(['weight_management', 'fitness', 'nutrition', 'mental_health', 'medication', 'vitals', 'habits']),
  body('goalType').isIn(['increase', 'decrease', 'maintain', 'achieve']),
  body('target.targetValue').isNumeric().withMessage('Target value must be a number'),
  body('target.deadline').isISO8601().withMessage('Valid deadline is required')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const userId = req.user.id;
    const goalData = {
      ...req.body,
      user: userId,
      progress: {
        currentValue: req.body.target.currentValue || 0,
        percentage: 0,
        lastUpdated: new Date()
      }
    };

    const goal = new HealthGoal(goalData);
    await goal.save();

    // Award points for goal setting
    await awardPoints(userId, 10, 'Created new health goal');

    logger.info(`New health goal created: ${userId}`, {
      goalId: goal._id,
      title: goal.title,
      category: goal.category
    });

    res.status(201).json({
      status: 'success',
      message: 'Health goal created successfully',
      data: { goal }
    });

  } catch (error) {
    logger.error('Create health goal error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error creating health goal'
    });
  }
});

// @route   GET /api/v1/gamification/goals
// @desc    Get user's health goals
// @access  Private (Patient)
router.get('/goals', authenticatePatient, [
  query('category').optional().isIn(['weight_management', 'fitness', 'nutrition', 'mental_health', 'medication', 'vitals', 'habits']),
  query('status').optional().isIn(['active', 'completed', 'paused', 'cancelled'])
], async (req, res) => {
  try {
    const userId = req.user.id;
    
    let query = { user: userId };
    if (req.query.category) query.category = req.query.category;
    if (req.query.status) query.status = req.query.status;

    const goals = await HealthGoal.find(query)
      .sort({ createdAt: -1 });

    // Calculate goal statistics
    const stats = {
      totalGoals: goals.length,
      activeGoals: goals.filter(g => g.status === 'active').length,
      completedGoals: goals.filter(g => g.status === 'completed').length,
      averageProgress: goals.length > 0 ? 
        goals.reduce((sum, g) => sum + g.progress.percentage, 0) / goals.length : 0
    };

    res.json({
      status: 'success',
      data: {
        goals,
        statistics: stats
      }
    });

  } catch (error) {
    logger.error('Get health goals error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching health goals'
    });
  }
});

// @route   POST /api/v1/gamification/goals/:goalId/update
// @desc    Update progress on a health goal
// @access  Private (Patient)
router.post('/goals/:goalId/update', authenticatePatient, [
  body('currentValue').isNumeric().withMessage('Current value must be a number'),
  body('notes').optional().isString()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { goalId } = req.params;
    const { currentValue, notes } = req.body;
    const userId = req.user.id;

    const goal = await HealthGoal.findOne({
      _id: goalId,
      user: userId
    });

    if (!goal) {
      return res.status(404).json({
        status: 'error',
        message: 'Health goal not found'
      });
    }

    // Update progress
    goal.progress.currentValue = currentValue;
    goal.progress.lastUpdated = new Date();

    // Calculate percentage based on goal type
    let percentage = 0;
    if (goal.goalType === 'increase') {
      percentage = Math.min((currentValue / goal.target.targetValue) * 100, 100);
    } else if (goal.goalType === 'decrease') {
      const initialValue = goal.target.currentValue || goal.target.targetValue * 2;
      percentage = Math.max(((initialValue - currentValue) / (initialValue - goal.target.targetValue)) * 100, 0);
    } else if (goal.goalType === 'maintain') {
      const tolerance = goal.target.targetValue * 0.1; // 10% tolerance
      percentage = Math.abs(currentValue - goal.target.targetValue) <= tolerance ? 100 : 0;
    } else if (goal.goalType === 'achieve') {
      percentage = currentValue >= goal.target.targetValue ? 100 : 0;
    }

    goal.progress.percentage = Math.min(percentage, 100);

    // Check for completion
    if (goal.progress.percentage >= 100 && goal.status === 'active') {
      goal.status = 'completed';
      await awardPoints(userId, 25, `Completed goal: ${goal.title}`);
      await awardBadge(userId, 'goal_achiever', 'Goal Achiever', 'Completed a health goal');
    }

    // Check milestones
    for (let milestone of goal.milestones) {
      if (!milestone.achieved && currentValue >= milestone.value) {
        milestone.achieved = true;
        milestone.achievedDate = new Date();
        if (milestone.reward.points) {
          await awardPoints(userId, milestone.reward.points, `Milestone: ${milestone.title}`);
        }
        if (milestone.reward.badge) {
          await awardBadge(userId, milestone.reward.badge, milestone.title, `Achieved milestone: ${milestone.title}`);
        }
      }
    }

    await goal.save();

    // Award progress points
    await awardPoints(userId, 3, 'Goal progress update');

    logger.info(`Health goal updated: ${userId}`, {
      goalId,
      currentValue,
      percentage: goal.progress.percentage,
      status: goal.status
    });

    res.json({
      status: 'success',
      message: 'Goal progress updated successfully',
      data: { goal }
    });

  } catch (error) {
    logger.error('Update health goal error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error updating health goal'
    });
  }
});

// @route   GET /api/v1/gamification/leaderboard
// @desc    Get leaderboard rankings
// @access  Private (Patient)
router.get('/leaderboard', authenticatePatient, [
  query('type').optional().isIn(['points', 'challenges', 'streak']),
  query('period').optional().isIn(['weekly', 'monthly', 'all_time']),
  query('limit').optional().isInt({ min: 1, max: 100 })
], async (req, res) => {
  try {
    const type = req.query.type || 'points';
    const period = req.query.period || 'all_time';
    const limit = parseInt(req.query.limit) || 50;

    let sortField = 'points.total';
    if (type === 'challenges') sortField = 'statistics.challengesCompleted';
    if (type === 'streak') sortField = 'statistics.bestStreak';

    // Get leaderboard data
    const leaderboard = await UserGamification.find()
      .populate('user', 'personalInfo.name personalInfo.city')
      .sort({ [sortField]: -1 })
      .limit(limit)
      .select(`user level.current ${sortField} badges statistics`);

    // Add rankings
    const rankedLeaderboard = leaderboard.map((entry, index) => ({
      rank: index + 1,
      user: {
        id: entry.user._id,
        name: entry.user.personalInfo?.name || 'Anonymous',
        city: entry.user.personalInfo?.city || 'Unknown'
      },
      level: entry.level.current,
      points: entry.points.total,
      challengesCompleted: entry.statistics.challengesCompleted,
      bestStreak: entry.statistics.bestStreak,
      badges: entry.badges.length,
      score: type === 'points' ? entry.points.total : 
             type === 'challenges' ? entry.statistics.challengesCompleted :
             entry.statistics.bestStreak
    }));

    // Find current user's rank
    const userId = req.user.id;
    const userRank = rankedLeaderboard.findIndex(entry => entry.user.id.toString() === userId) + 1;

    res.json({
      status: 'success',
      data: {
        leaderboard: rankedLeaderboard,
        userRank: userRank || null,
        filters: {
          type,
          period,
          limit
        }
      }
    });

  } catch (error) {
    logger.error('Get leaderboard error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching leaderboard'
    });
  }
});

// @route   GET /api/v1/gamification/badges
// @desc    Get available and earned badges
// @access  Private (Patient)
router.get('/badges', authenticatePatient, async (req, res) => {
  try {
    const userId = req.user.id;

    const userProfile = await UserGamification.findOne({ user: userId });
    const earnedBadges = userProfile ? userProfile.badges : [];

    // Define available badges (in real app, would be from database)
    const availableBadges = [
      {
        badgeId: 'first_challenge',
        name: 'First Steps',
        description: 'Complete your first challenge',
        category: 'milestone',
        rarity: 'common',
        requirements: 'Complete 1 challenge'
      },
      {
        badgeId: 'challenge_master',
        name: 'Challenge Master',
        description: 'Complete 10 challenges',
        category: 'achievement',
        rarity: 'rare',
        requirements: 'Complete 10 challenges'
      },
      {
        badgeId: 'streak_warrior',
        name: 'Streak Warrior',
        description: 'Maintain a 7-day streak',
        category: 'consistency',
        rarity: 'epic',
        requirements: 'Maintain 7-day streak'
      },
      {
        badgeId: 'goal_achiever',
        name: 'Goal Achiever',
        description: 'Complete a health goal',
        category: 'milestone',
        rarity: 'common',
        requirements: 'Complete 1 health goal'
      },
      {
        badgeId: 'fitness_fanatic',
        name: 'Fitness Fanatic',
        description: 'Complete 5 fitness challenges',
        category: 'specialist',
        rarity: 'rare',
        requirements: 'Complete 5 fitness challenges'
      }
    ];

    // Mark earned badges
    const badgesWithStatus = availableBadges.map(badge => ({
      ...badge,
      earned: earnedBadges.some(eb => eb.badgeId === badge.badgeId),
      earnedDate: earnedBadges.find(eb => eb.badgeId === badge.badgeId)?.earnedDate
    }));

    res.json({
      status: 'success',
      data: {
        badges: badgesWithStatus,
        earnedCount: earnedBadges.length,
        totalAvailable: availableBadges.length,
        completionPercentage: (earnedBadges.length / availableBadges.length) * 100
      }
    });

  } catch (error) {
    logger.error('Get badges error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching badges'
    });
  }
});

// Helper functions
async function awardPoints(userId, points, reason) {
  try {
    const profile = await UserGamification.findOne({ user: userId });
    if (profile) {
      profile.points.total += points;
      profile.points.available += points;
      
      // Check for level up
      const newXP = profile.level.xp + points;
      const currentLevel = profile.level.current;
      const newLevel = Math.floor(newXP / 100) + 1;
      
      if (newLevel > currentLevel) {
        profile.level.current = newLevel;
        profile.level.xpToNext = (newLevel * 100) - newXP;
        // Award level up badge
        await awardBadge(userId, `level_${newLevel}`, `Level ${newLevel}`, `Reached level ${newLevel}`);
      }
      
      profile.level.xp = newXP;
      await profile.save();
      
      logger.info(`Points awarded: ${userId}`, { points, reason, newTotal: profile.points.total });
    }
  } catch (error) {
    logger.error('Award points error:', error);
  }
}

async function awardBadge(userId, badgeId, name, description) {
  try {
    const profile = await UserGamification.findOne({ user: userId });
    if (profile && !profile.badges.some(b => b.badgeId === badgeId)) {
      profile.badges.push({
        badgeId,
        name,
        description,
        earnedDate: new Date(),
        category: 'achievement',
        rarity: 'common'
      });
      await profile.save();
      logger.info(`Badge awarded: ${userId}`, { badgeId, name });
    }
  } catch (error) {
    logger.error('Award badge error:', error);
  }
}

async function awardBadges(userId, badgeIds) {
  for (const badgeId of badgeIds) {
    await awardBadge(userId, badgeId, badgeId.replace('_', ' '), `Earned ${badgeId} badge`);
  }
}

async function updateStatistics(userId, statistic, increment) {
  try {
    const profile = await UserGamification.findOne({ user: userId });
    if (profile) {
      profile.statistics[statistic] += increment;
      await profile.save();
    }
  } catch (error) {
    logger.error('Update statistics error:', error);
  }
}

module.exports = router;
