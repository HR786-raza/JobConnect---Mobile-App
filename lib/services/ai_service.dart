import 'package:flutter/foundation.dart' show debugPrint;
import '../models/job_model.dart';
import '../models/resume_model.dart';

class AIService {
  // Get AI-powered job matches for user - simplified version
  static Future<List<JobModel>> getJobMatches(String userId) async {
    debugPrint('AI Service: Getting job matches for user $userId');
    return []; // Return empty list for now
  }

  // Get AI interview questions - simplified version
  static Future<List<Map<String, dynamic>>> getInterviewQuestions({
    required String jobTitle,
    required String company,
    required List<String> skills,
  }) async {
    // Return some default questions
    return [
      {
        'question': 'Tell me about yourself.',
        'category': 'general',
        'difficulty': 'beginner',
        'sampleAnswer': 'Focus on your relevant experience and skills.',
      },
      {
        'question': 'Why do you want to work at $company?',
        'category': 'company',
        'difficulty': 'beginner',
        'sampleAnswer': 'Research the company and mention specific aspects that appeal to you.',
      },
      {
        'question': 'What are your greatest strengths?',
        'category': 'general',
        'difficulty': 'beginner',
        'sampleAnswer': 'Highlight skills relevant to the position.',
      },
    ];
  }

  // Analyze resume - simplified version
  static Future<Map<String, dynamic>> analyzeResume(ResumeModel resume) async {
    return {
      'overallScore': 75,
      'suggestions': ['Add more quantifiable achievements', 'Include relevant keywords'],
      'missingKeywords': ['leadership', 'project management'],
      'strengths': ['Good experience section', 'Clear formatting'],
    };
  }

  // Get skill assessment questions - simplified version
  static Future<List<Map<String, dynamic>>> getSkillAssessmentQuestions(
    String skill,
    String level,
  ) async {
    return [
      {
        'id': '${skill}_1',
        'question': 'What is your experience with $skill?',
        'options': ['Beginner', 'Intermediate', 'Advanced', 'Expert'],
        'correctAnswer': 0,
        'explanation': 'This helps us understand your skill level.',
      },
    ];
  }
}