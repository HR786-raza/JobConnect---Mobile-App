import 'package:cloud_firestore/cloud_firestore.dart';

class AssessmentModel {
  final String id;
  final String userId;
  final String skillName;
  final AssessmentStatus status;
  final DateTime startedAt;
  final DateTime? completedAt;
  final List<AssessmentQuestion> questions;
  final int score;
  final int totalQuestions;
  final Map<String, dynamic>? results;
  final String? skillLevel;
  final Map<String, dynamic>? aiAnalysis;
  final List<String> recommendations;

  AssessmentModel({
    required this.id,
    required this.userId,
    required this.skillName,
    this.status = AssessmentStatus.pending,
    required this.startedAt,
    this.completedAt,
    this.questions = const [],
    this.score = 0,
    this.totalQuestions = 0,
    this.results,
    this.skillLevel,
    this.aiAnalysis,
    this.recommendations = const [],
  });

  factory AssessmentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return AssessmentModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      skillName: data['skillName'] ?? '',
      status: _parseAssessmentStatus(data['status']),
      startedAt: (data['startedAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      questions: (data['questions'] as List? ?? [])
          .map((q) => AssessmentQuestion.fromMap(q))
          .toList(),
      score: data['score'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
      results: data['results'],
      skillLevel: data['skillLevel'],
      aiAnalysis: data['aiAnalysis'],
      recommendations: List<String>.from(data['recommendations'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'skillName': skillName,
      'status': status.toString().split('.').last,
      'startedAt': Timestamp.fromDate(startedAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'questions': questions.map((q) => q.toMap()).toList(),
      'score': score,
      'totalQuestions': totalQuestions,
      'results': results,
      'skillLevel': skillLevel,
      'aiAnalysis': aiAnalysis,
      'recommendations': recommendations,
    };
  }

  static AssessmentStatus _parseAssessmentStatus(String? status) {
    if (status == null) return AssessmentStatus.pending;
    switch (status) {
      case 'pending': return AssessmentStatus.pending;
      case 'inProgress': return AssessmentStatus.inProgress;
      case 'completed': return AssessmentStatus.completed;
      case 'expired': return AssessmentStatus.expired;
      default: return AssessmentStatus.pending;
    }
  }

  double get percentage {
    if (totalQuestions == 0) return 0;
    return (score / totalQuestions) * 100;
  }

  String get level {
    final p = percentage;
    if (p >= 80) return 'Expert';
    if (p >= 60) return 'Advanced';
    if (p >= 40) return 'Intermediate';
    if (p >= 20) return 'Beginner';
    return 'Novice';
  }
}

enum AssessmentStatus { pending, inProgress, completed, expired }

class AssessmentQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String? explanation;
  final String difficulty;
  final String category;
  final Map<String, dynamic>? metadata;

  AssessmentQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    this.difficulty = 'medium',
    this.category = 'general',
    this.metadata,
  });

  factory AssessmentQuestion.fromMap(Map<String, dynamic> map) {
    return AssessmentQuestion(
      id: map['id'] ?? '',
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswer: map['correctAnswer'] ?? 0,
      explanation: map['explanation'],
      difficulty: map['difficulty'] ?? 'medium',
      category: map['category'] ?? 'general',
      metadata: map['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'difficulty': difficulty,
      'category': category,
      'metadata': metadata,
    };
  }
}

// Renamed from InterviewPreparationModel to avoid confusion with application's InterviewRound
class InterviewPrepSession {
  final String id;
  final String userId;
  final String jobTitle;
  final String company;
  final List<String> skills;
  final InterviewPrepType type;
  final DateTime scheduledFor;
  final InterviewPrepSessionStatus status;
  final List<InterviewPrepQuestion> questions;
  final Map<String, dynamic>? feedback;
  final String? recording;
  final int score;
  final List<String> tips;
  final Map<String, dynamic>? aiAnalysis;

  InterviewPrepSession({
    required this.id,
    required this.userId,
    required this.jobTitle,
    required this.company,
    this.skills = const [],
    this.type = InterviewPrepType.general,
    required this.scheduledFor,
    this.status = InterviewPrepSessionStatus.pending,
    this.questions = const [],
    this.feedback,
    this.recording,
    this.score = 0,
    this.tips = const [],
    this.aiAnalysis,
  });

  factory InterviewPrepSession.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return InterviewPrepSession(
      id: doc.id,
      userId: data['userId'] ?? '',
      jobTitle: data['jobTitle'] ?? '',
      company: data['company'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      type: _parseInterviewPrepType(data['type']),
      scheduledFor: (data['scheduledFor'] as Timestamp).toDate(),
      status: _parseInterviewPrepSessionStatus(data['status']),
      questions: (data['questions'] as List? ?? [])
          .map((q) => InterviewPrepQuestion.fromMap(q))
          .toList(),
      feedback: data['feedback'],
      recording: data['recording'],
      score: data['score'] ?? 0,
      tips: List<String>.from(data['tips'] ?? []),
      aiAnalysis: data['aiAnalysis'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'jobTitle': jobTitle,
      'company': company,
      'skills': skills,
      'type': type.toString().split('.').last,
      'scheduledFor': Timestamp.fromDate(scheduledFor),
      'status': status.toString().split('.').last,
      'questions': questions.map((q) => q.toMap()).toList(),
      'feedback': feedback,
      'recording': recording,
      'score': score,
      'tips': tips,
      'aiAnalysis': aiAnalysis,
    };
  }

  static InterviewPrepType _parseInterviewPrepType(String? type) {
    if (type == null) return InterviewPrepType.general;
    switch (type) {
      case 'general': return InterviewPrepType.general;
      case 'technical': return InterviewPrepType.technical;
      case 'behavioral': return InterviewPrepType.behavioral;
      case 'case': return InterviewPrepType.case_;
      default: return InterviewPrepType.general;
    }
  }

  static InterviewPrepSessionStatus _parseInterviewPrepSessionStatus(String? status) {
    if (status == null) return InterviewPrepSessionStatus.pending;
    switch (status) {
      case 'pending': return InterviewPrepSessionStatus.pending;
      case 'inProgress': return InterviewPrepSessionStatus.inProgress;
      case 'completed': return InterviewPrepSessionStatus.completed;
      default: return InterviewPrepSessionStatus.pending;
    }
  }
}

enum InterviewPrepType { general, technical, behavioral, case_ }

enum InterviewPrepSessionStatus { pending, inProgress, completed }

class InterviewPrepQuestion {
  final String id;
  final String question;
  final String category;
  final String difficulty;
  final List<String>? keywords;
  final String? sampleAnswer;
  final List<String>? tips;

  InterviewPrepQuestion({
    required this.id,
    required this.question,
    this.category = 'general',
    this.difficulty = 'medium',
    this.keywords,
    this.sampleAnswer,
    this.tips,
  });

  factory InterviewPrepQuestion.fromMap(Map<String, dynamic> map) {
    return InterviewPrepQuestion(
      id: map['id'] ?? '',
      question: map['question'] ?? '',
      category: map['category'] ?? 'general',
      difficulty: map['difficulty'] ?? 'medium',
      keywords: map['keywords'] != null
          ? List<String>.from(map['keywords'])
          : null,
      sampleAnswer: map['sampleAnswer'],
      tips: map['tips'] != null
          ? List<String>.from(map['tips'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'category': category,
      'difficulty': difficulty,
      'keywords': keywords,
      'sampleAnswer': sampleAnswer,
      'tips': tips,
    };
  }
}