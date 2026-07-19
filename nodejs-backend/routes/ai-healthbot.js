const express = require('express');
const { body, query, validationResult } = require('express-validator');
const mongoose = require('mongoose');
const Patient = require('../models/Patient');
const { authenticate, authenticatePatient } = require('../middleware/auth');
const logger = require('../utils/logger');

const router = express.Router();

// AI Health Bot Conversation Schema (would be a separate model in real app)
const ConversationSchema = new mongoose.Schema({
  patient: {
    type: mongoose.Types.ObjectId,
    ref: 'Patient',
    required: true
  },
  sessionId: {
    type: String,
    required: true,
    unique: true
  },
  messages: [{
    type: {
      type: String,
      enum: ['user', 'bot'],
      required: true
    },
    content: {
      type: String,
      required: true
    },
    timestamp: {
      type: Date,
      default: Date.now
    },
    messageId: String,
    metadata: {
      intent: String,
      confidence: Number,
      entities: [String],
      suggestions: [String]
    }
  }],
  context: {
    currentTopic: String,
    userPreferences: {
      language: { type: String, default: 'en' },
      responseStyle: { type: String, enum: ['brief', 'detailed'], default: 'detailed' }
    },
    healthContext: {
      recentSymptoms: [String],
      currentMedications: [String],
      chronicConditions: [String],
      allergies: [String]
    }
  },
  analytics: {
    sessionDuration: Number,
    messageCount: Number,
    topicsDiscussed: [String],
    satisfactionScore: Number,
    helpfulnessRating: Number
  },
  status: {
    type: String,
    enum: ['active', 'ended', 'escalated'],
    default: 'active'
  }
}, {
  timestamps: true
});

// Create model (in real app, this would be in separate file)
const Conversation = mongoose.model('AIConversation', ConversationSchema);

// AI Health Recommendations Schema
const RecommendationSchema = new mongoose.Schema({
  patient: {
    type: mongoose.Types.ObjectId,
    ref: 'Patient',
    required: true
  },
  type: {
    type: String,
    enum: ['medication', 'lifestyle', 'diet', 'exercise', 'checkup', 'emergency'],
    required: true
  },
  title: String,
  description: String,
  priority: {
    type: String,
    enum: ['low', 'medium', 'high', 'critical'],
    default: 'medium'
  },
  aiAnalysis: {
    confidence: Number,
    basedOn: [String],
    reasoning: String,
    riskFactors: [String]
  },
  actions: [{
    action: String,
    timeframe: String,
    completed: { type: Boolean, default: false }
  }],
  status: {
    type: String,
    enum: ['active', 'completed', 'dismissed', 'escalated'],
    default: 'active'
  },
  expiresAt: Date
}, {
  timestamps: true
});

const Recommendation = mongoose.model('AIRecommendation', RecommendationSchema);

// AI Response Generation (Mock implementation - in real app would use actual AI service)
function generateAIResponse(userMessage, context) {
  const message = userMessage.toLowerCase();
  
  // Simple keyword-based responses (in real app, would use NLP/ML)
  const responses = {
    // Greeting patterns
    greeting: {
      patterns: ['hello', 'hi', 'hey', 'good morning', 'good evening'],
      responses: [
        "Hello! I'm your AI Health Assistant. How can I help you with your health today?",
        "Hi there! I'm here to help with your health questions and provide personalized advice.",
        "Welcome! I can help you track symptoms, understand medications, and provide health guidance."
      ]
    },
    
    // Symptom checking
    symptoms: {
      patterns: ['pain', 'headache', 'fever', 'cough', 'tired', 'nausea', 'dizzy'],
      responses: [
        "I understand you're experiencing {symptom}. Can you tell me more about when it started and how severe it is on a scale of 1-10?",
        "Let me help you assess your {symptom}. Have you noticed any other symptoms along with this?",
        "I'm noting your {symptom}. Based on your medical history, I can provide some guidance. How long have you been experiencing this?"
      ]
    },
    
    // Medication questions
    medication: {
      patterns: ['medication', 'medicine', 'drug', 'pill', 'prescription', 'dosage'],
      responses: [
        "I can help with medication information. What specific medication are you asking about?",
        "For medication queries, I can provide general information. Always consult your doctor for specific dosage changes.",
        "I see you're asking about medications. Based on your current prescriptions, I can provide relevant information."
      ]
    },
    
    // Lifestyle advice
    lifestyle: {
      patterns: ['diet', 'exercise', 'sleep', 'stress', 'weight', 'nutrition'],
      responses: [
        "Great question about {topic}! Based on your health profile, I can suggest personalized recommendations.",
        "I'd be happy to help with {topic} advice. Let me consider your current health status and provide tailored suggestions.",
        "For {topic}, I can offer evidence-based recommendations that align with your health goals."
      ]
    },
    
    // Emergency situations
    emergency: {
      patterns: ['emergency', 'urgent', 'chest pain', 'breathing', 'unconscious', 'severe'],
      responses: [
        "⚠️ This sounds urgent. If you're experiencing a medical emergency, please call emergency services immediately (112/108).",
        "🚨 For severe symptoms, please seek immediate medical attention. Would you like me to help you find the nearest hospital?",
        "This requires immediate medical care. Please contact emergency services or go to the nearest emergency room."
      ]
    }
  };
  
  // Find matching pattern
  let bestMatch = null;
  let matchedKeyword = '';
  
  for (const [category, data] of Object.entries(responses)) {
    for (const pattern of data.patterns) {
      if (message.includes(pattern)) {
        bestMatch = data;
        matchedKeyword = pattern;
        break;
      }
    }
    if (bestMatch) break;
  }
  
  if (bestMatch) {
    const randomResponse = bestMatch.responses[Math.floor(Math.random() * bestMatch.responses.length)];
    return {
      content: randomResponse.replace('{symptom}', matchedKeyword).replace('{topic}', matchedKeyword),
      intent: Object.keys(responses).find(key => responses[key] === bestMatch),
      confidence: 0.85,
      suggestions: getSuggestions(matchedKeyword, context)
    };
  }
  
  // Default response
  return {
    content: "I understand you're asking about your health. Can you provide more specific details so I can better assist you? I can help with symptoms, medications, lifestyle advice, and general health questions.",
    intent: 'general',
    confidence: 0.6,
    suggestions: ['Tell me about symptoms', 'Ask about medications', 'Get lifestyle advice', 'Emergency help']
  };
}

function getSuggestions(keyword, context) {
  const suggestionMap = {
    'pain': ['Rate your pain 1-10', 'When did it start?', 'Any other symptoms?', 'Need emergency help?'],
    'headache': ['Type of headache?', 'Frequency?', 'Triggers?', 'Current medications?'],
    'fever': ['Temperature reading?', 'Other symptoms?', 'Duration?', 'Age group?'],
    'medication': ['Dosage question?', 'Side effects?', 'Interactions?', 'Timing?'],
    'diet': ['Weight goals?', 'Dietary restrictions?', 'Meal planning?', 'Nutrition facts?'],
    'exercise': ['Fitness level?', 'Health conditions?', 'Time available?', 'Workout type?']
  };
  
  return suggestionMap[keyword] || ['Tell me more', 'Any other questions?', 'Need specific help?', 'Emergency?'];
}

// @route   POST /api/v1/ai/chat
// @desc    Send message to AI health bot
// @access  Private (Patient)
router.post('/chat', authenticatePatient, [
  body('message').notEmpty().withMessage('Message is required'),
  body('sessionId').optional().isString(),
  body('context').optional().isObject()
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

    const { message, sessionId: providedSessionId, context } = req.body;
    const patientId = req.user.id;

    // Get or create session
    let sessionId = providedSessionId || `session_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    let conversation = await Conversation.findOne({
      patient: patientId,
      sessionId,
      status: 'active'
    });

    if (!conversation) {
      // Get patient context for AI
      const patient = await Patient.findById(patientId).select('medicalHistory currentHealth personalInfo');
      
      conversation = new Conversation({
        patient: patientId,
        sessionId,
        messages: [],
        context: {
          currentTopic: 'general',
          userPreferences: context?.userPreferences || {},
          healthContext: {
            recentSymptoms: [],
            currentMedications: patient?.medicalHistory?.currentMedications || [],
            chronicConditions: patient?.medicalHistory?.chronicConditions?.map(c => c.condition) || [],
            allergies: patient?.medicalHistory?.allergies?.map(a => a.allergen) || []
          }
        },
        analytics: {
          sessionDuration: 0,
          messageCount: 0,
          topicsDiscussed: [],
          satisfactionScore: 0,
          helpfulnessRating: 0
        }
      });
    }

    // Add user message
    const userMessageId = `msg_${Date.now()}_user`;
    conversation.messages.push({
      type: 'user',
      content: message,
      messageId: userMessageId,
      timestamp: new Date()
    });

    // Generate AI response
    const aiResponse = generateAIResponse(message, conversation.context);
    
    const botMessageId = `msg_${Date.now()}_bot`;
    conversation.messages.push({
      type: 'bot',
      content: aiResponse.content,
      messageId: botMessageId,
      timestamp: new Date(),
      metadata: {
        intent: aiResponse.intent,
        confidence: aiResponse.confidence,
        entities: [],
        suggestions: aiResponse.suggestions
      }
    });

    // Update analytics
    conversation.analytics.messageCount = conversation.messages.length;
    conversation.analytics.topicsDiscussed = [...new Set([...conversation.analytics.topicsDiscussed, aiResponse.intent])];

    // Check for emergency keywords
    const emergencyKeywords = ['emergency', 'urgent', 'chest pain', 'breathing problem', 'unconscious'];
    const isEmergency = emergencyKeywords.some(keyword => message.toLowerCase().includes(keyword));
    
    if (isEmergency) {
      conversation.status = 'escalated';
      // In real app, would trigger emergency protocols
    }

    await conversation.save();

    logger.info(`AI chat message processed for patient: ${patientId}`, {
      sessionId,
      intent: aiResponse.intent,
      isEmergency
    });

    res.json({
      status: 'success',
      data: {
        sessionId,
        userMessage: {
          id: userMessageId,
          content: message,
          timestamp: new Date()
        },
        botResponse: {
          id: botMessageId,
          content: aiResponse.content,
          timestamp: new Date(),
          intent: aiResponse.intent,
          confidence: aiResponse.confidence,
          suggestions: aiResponse.suggestions
        },
        isEmergency,
        conversationStatus: conversation.status
      }
    });

  } catch (error) {
    logger.error('AI chat error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error processing AI chat'
    });
  }
});

// @route   GET /api/v1/ai/chat-history/:sessionId
// @desc    Get chat history for session
// @access  Private (Patient)
router.get('/chat-history/:sessionId', authenticatePatient, async (req, res) => {
  try {
    const { sessionId } = req.params;
    const patientId = req.user.id;

    const conversation = await Conversation.findOne({
      patient: patientId,
      sessionId
    });

    if (!conversation) {
      return res.status(404).json({
        status: 'error',
        message: 'Conversation not found'
      });
    }

    res.json({
      status: 'success',
      data: {
        sessionId,
        messages: conversation.messages,
        context: conversation.context,
        analytics: conversation.analytics,
        status: conversation.status,
        createdAt: conversation.createdAt,
        updatedAt: conversation.updatedAt
      }
    });

  } catch (error) {
    logger.error('Get chat history error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching chat history'
    });
  }
});

// @route   GET /api/v1/ai/sessions
// @desc    Get all chat sessions for patient
// @access  Private (Patient)
router.get('/sessions', authenticatePatient, [
  query('page').optional().isInt({ min: 1 }),
  query('limit').optional().isInt({ min: 1, max: 50 }),
  query('status').optional().isIn(['active', 'ended', 'escalated'])
], async (req, res) => {
  try {
    const patientId = req.user.id;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    let query = { patient: patientId };
    if (req.query.status) {
      query.status = req.query.status;
    }

    const [sessions, total] = await Promise.all([
      Conversation.find(query)
        .sort({ updatedAt: -1 })
        .skip(skip)
        .limit(limit)
        .select('sessionId status analytics createdAt updatedAt messages'),
      Conversation.countDocuments(query)
    ]);

    const sessionsData = sessions.map(session => ({
      sessionId: session.sessionId,
      status: session.status,
      messageCount: session.analytics.messageCount,
      topicsDiscussed: session.analytics.topicsDiscussed,
      lastMessage: session.messages[session.messages.length - 1]?.content?.substring(0, 100) + '...',
      createdAt: session.createdAt,
      updatedAt: session.updatedAt
    }));

    res.json({
      status: 'success',
      data: {
        sessions: sessionsData,
        pagination: {
          currentPage: page,
          totalPages: Math.ceil(total / limit),
          totalSessions: total,
          hasNext: page < Math.ceil(total / limit),
          hasPrev: page > 1
        }
      }
    });

  } catch (error) {
    logger.error('Get AI sessions error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching AI sessions'
    });
  }
});

// @route   POST /api/v1/ai/health-analysis
// @desc    Get AI health analysis for patient
// @access  Private (Patient)
router.post('/health-analysis', authenticatePatient, [
  body('symptoms').optional().isArray(),
  body('duration').optional().isString(),
  body('severity').optional().isInt({ min: 1, max: 10 }),
  body('additionalInfo').optional().isString()
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

    const patientId = req.user.id;
    const { symptoms = [], duration, severity, additionalInfo } = req.body;

    // Get patient data
    const patient = await Patient.findById(patientId).select('medicalHistory currentHealth personalInfo');

    if (!patient) {
      return res.status(404).json({
        status: 'error',
        message: 'Patient not found'
      });
    }

    // Generate AI analysis (mock implementation)
    const analysis = {
      analysisId: `analysis_${Date.now()}`,
      patientInfo: {
        age: new Date().getFullYear() - new Date(patient.personalInfo.dateOfBirth).getFullYear(),
        gender: patient.personalInfo.gender,
        existingConditions: patient.medicalHistory?.chronicConditions?.map(c => c.condition) || [],
        allergies: patient.medicalHistory?.allergies?.map(a => a.allergen) || []
      },
      symptoms: symptoms,
      analysis: {
        riskLevel: severity > 7 ? 'high' : severity > 4 ? 'medium' : 'low',
        possibleConditions: generatePossibleConditions(symptoms),
        recommendations: generateRecommendations(symptoms, severity, patient.medicalHistory),
        redFlags: checkRedFlags(symptoms, severity),
        confidence: 0.75
      },
      nextSteps: {
        immediate: generateImmediateActions(symptoms, severity),
        followUp: generateFollowUpActions(symptoms, patient.medicalHistory),
        monitoring: generateMonitoringPlan(symptoms)
      },
      disclaimer: "This is an AI-generated analysis and should not replace professional medical advice. Please consult with a healthcare provider for proper diagnosis and treatment."
    };

    // Save analysis for future reference
    const analysisRecord = {
      patient: patientId,
      analysisData: analysis,
      timestamp: new Date()
    };

    logger.info(`AI health analysis generated for patient: ${patientId}`, {
      analysisId: analysis.analysisId,
      riskLevel: analysis.analysis.riskLevel,
      symptomsCount: symptoms.length
    });

    res.json({
      status: 'success',
      data: analysis
    });

  } catch (error) {
    logger.error('AI health analysis error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error generating health analysis'
    });
  }
});

// @route   GET /api/v1/ai/recommendations
// @desc    Get AI health recommendations for patient
// @access  Private (Patient)
router.get('/recommendations', authenticatePatient, [
  query('type').optional().isIn(['medication', 'lifestyle', 'diet', 'exercise', 'checkup', 'emergency']),
  query('priority').optional().isIn(['low', 'medium', 'high', 'critical']),
  query('status').optional().isIn(['active', 'completed', 'dismissed', 'escalated'])
], async (req, res) => {
  try {
    const patientId = req.user.id;
    
    let query = { patient: patientId };
    if (req.query.type) query.type = req.query.type;
    if (req.query.priority) query.priority = req.query.priority;
    if (req.query.status) query.status = req.query.status;

    const recommendations = await Recommendation.find(query)
      .sort({ priority: -1, createdAt: -1 })
      .limit(20);

    // If no existing recommendations, generate some based on patient data
    if (recommendations.length === 0) {
      const patient = await Patient.findById(patientId).select('medicalHistory currentHealth');
      const generatedRecs = await generatePatientRecommendations(patientId, patient);
      
      res.json({
        status: 'success',
        data: {
          recommendations: generatedRecs,
          total: generatedRecs.length,
          generated: true
        }
      });
    } else {
      res.json({
        status: 'success',
        data: {
          recommendations,
          total: recommendations.length,
          generated: false
        }
      });
    }

  } catch (error) {
    logger.error('Get AI recommendations error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching recommendations'
    });
  }
});

// @route   POST /api/v1/ai/feedback
// @desc    Submit feedback for AI response
// @access  Private (Patient)
router.post('/feedback', authenticatePatient, [
  body('sessionId').notEmpty().withMessage('Session ID is required'),
  body('messageId').notEmpty().withMessage('Message ID is required'),
  body('rating').isInt({ min: 1, max: 5 }).withMessage('Rating must be between 1 and 5'),
  body('feedback').optional().isString(),
  body('helpful').isBoolean()
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

    const { sessionId, messageId, rating, feedback, helpful } = req.body;
    const patientId = req.user.id;

    const conversation = await Conversation.findOne({
      patient: patientId,
      sessionId
    });

    if (!conversation) {
      return res.status(404).json({
        status: 'error',
        message: 'Conversation not found'
      });
    }

    // Update conversation with feedback
    conversation.analytics.satisfactionScore = rating;
    conversation.analytics.helpfulnessRating = helpful ? 5 : 2;
    
    // Add feedback to message metadata
    const message = conversation.messages.find(m => m.messageId === messageId);
    if (message) {
      message.metadata.feedback = {
        rating,
        feedback,
        helpful,
        timestamp: new Date()
      };
    }

    await conversation.save();

    logger.info(`AI feedback received from patient: ${patientId}`, {
      sessionId,
      messageId,
      rating,
      helpful
    });

    res.json({
      status: 'success',
      message: 'Feedback submitted successfully',
      data: {
        sessionId,
        messageId,
        rating,
        helpful
      }
    });

  } catch (error) {
    logger.error('AI feedback error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error submitting feedback'
    });
  }
});

// Helper functions (mock implementations)
function generatePossibleConditions(symptoms) {
  const conditionMap = {
    'headache': ['Tension headache', 'Migraine', 'Cluster headache', 'Sinus headache'],
    'fever': ['Viral infection', 'Bacterial infection', 'Flu', 'Common cold'],
    'cough': ['Upper respiratory infection', 'Bronchitis', 'Pneumonia', 'Allergies'],
    'fatigue': ['Viral infection', 'Anemia', 'Thyroid disorder', 'Depression'],
    'nausea': ['Gastroenteritis', 'Food poisoning', 'Migraine', 'Anxiety']
  };

  let conditions = [];
  symptoms.forEach(symptom => {
    if (conditionMap[symptom.toLowerCase()]) {
      conditions = [...conditions, ...conditionMap[symptom.toLowerCase()]];
    }
  });

  return [...new Set(conditions)].slice(0, 5); // Return top 5 unique conditions
}

function generateRecommendations(symptoms, severity, medicalHistory) {
  const recommendations = [];
  
  if (severity >= 8) {
    recommendations.push("Seek immediate medical attention");
  } else if (severity >= 6) {
    recommendations.push("Schedule appointment with your doctor within 24-48 hours");
  } else {
    recommendations.push("Monitor symptoms and rest");
    recommendations.push("Stay hydrated and maintain good nutrition");
  }

  if (symptoms.includes('fever')) {
    recommendations.push("Take fever reducer as directed");
    recommendations.push("Rest and increase fluid intake");
  }

  if (symptoms.includes('headache')) {
    recommendations.push("Apply cold or warm compress");
    recommendations.push("Reduce screen time and bright lights");
  }

  return recommendations;
}

function checkRedFlags(symptoms, severity) {
  const redFlags = [];
  
  if (severity >= 9) {
    redFlags.push("Severe pain level requires immediate attention");
  }

  const emergencySymptoms = ['chest pain', 'breathing difficulty', 'severe headache', 'unconsciousness'];
  symptoms.forEach(symptom => {
    if (emergencySymptoms.some(flag => symptom.toLowerCase().includes(flag))) {
      redFlags.push(`${symptom} requires emergency evaluation`);
    }
  });

  return redFlags;
}

function generateImmediateActions(symptoms, severity) {
  if (severity >= 8) {
    return ["Call emergency services", "Go to nearest emergency room"];
  } else if (severity >= 6) {
    return ["Contact your doctor", "Monitor symptoms closely"];
  } else {
    return ["Rest and monitor", "Stay hydrated", "Take over-the-counter medication if needed"];
  }
}

function generateFollowUpActions(symptoms, medicalHistory) {
  return [
    "Schedule follow-up if symptoms persist or worsen",
    "Keep symptom diary",
    "Update your doctor about any changes"
  ];
}

function generateMonitoringPlan(symptoms) {
  return [
    "Track symptom severity daily",
    "Note any new symptoms",
    "Monitor vital signs if available",
    "Report significant changes immediately"
  ];
}

async function generatePatientRecommendations(patientId, patient) {
  const recommendations = [];
  
  // Generate based on patient data
  if (patient?.medicalHistory?.chronicConditions?.length > 0) {
    recommendations.push({
      type: 'checkup',
      title: 'Regular Health Checkup',
      description: 'Schedule your routine checkup based on your chronic conditions',
      priority: 'medium',
      aiAnalysis: {
        confidence: 0.9,
        basedOn: ['Chronic conditions', 'Medical history'],
        reasoning: 'Regular monitoring is essential for chronic condition management'
      },
      actions: [
        { action: 'Schedule appointment with primary doctor', timeframe: '30 days' },
        { action: 'Review current medications', timeframe: '7 days' }
      ]
    });
  }

  if (patient?.currentHealth?.vitals?.weight && patient?.currentHealth?.vitals?.height) {
    const bmi = patient.currentHealth.vitals.weight / Math.pow(patient.currentHealth.vitals.height / 100, 2);
    if (bmi > 25) {
      recommendations.push({
        type: 'lifestyle',
        title: 'Weight Management',
        description: 'Consider a healthy weight management plan',
        priority: 'medium',
        aiAnalysis: {
          confidence: 0.8,
          basedOn: ['BMI calculation', 'Current vitals'],
          reasoning: 'BMI indicates potential weight management benefits'
        },
        actions: [
          { action: 'Consult nutritionist', timeframe: '14 days' },
          { action: 'Start regular exercise routine', timeframe: '7 days' }
        ]
      });
    }
  }

  recommendations.push({
    type: 'lifestyle',
    title: 'Health Maintenance',
    description: 'General wellness recommendations for optimal health',
    priority: 'low',
    aiAnalysis: {
      confidence: 0.7,
      basedOn: ['General wellness guidelines'],
      reasoning: 'Preventive care is important for long-term health'
    },
    actions: [
      { action: 'Maintain regular exercise', timeframe: 'ongoing' },
      { action: 'Follow balanced diet', timeframe: 'ongoing' },
      { action: 'Get adequate sleep', timeframe: 'ongoing' }
    ]
  });

  return recommendations;
}

module.exports = router;
