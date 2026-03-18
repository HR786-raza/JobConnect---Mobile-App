import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../models/application_model.dart';
import '../config/firebase_config.dart';

class JobProvider extends ChangeNotifier {
  List<JobModel> _jobs = [];
  List<JobModel> _featuredJobs = [];
  List<JobModel> _recommendedJobs = [];
  List<ApplicationModel> _applications = [];
  List<JobModel> _savedJobs = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<JobModel> get jobs => _jobs;
  List<JobModel> get featuredJobs => _featuredJobs;
  List<JobModel> get recommendedJobs => _recommendedJobs;
  List<ApplicationModel> get applications => _applications;
  List<JobModel> get savedJobs => _savedJobs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all jobs
  Future<void> loadJobs({Map<String, dynamic>? filters}) async {
    try {
      _setLoading(true);

      Query<Map<String, dynamic>> query = FirebaseConfig.jobsCollection;
      
      // Apply filters
      if (filters != null) {
        if (filters.containsKey('jobType') && filters['jobType'] != 'All') {
          query = query.where('jobType', isEqualTo: filters['jobType']);
        }
        if (filters.containsKey('location') && filters['location'] != 'All') {
          query = query.where('location', isEqualTo: filters['location']);
        }
        if (filters.containsKey('salaryMin')) {
          query = query.where('salaryMin', isGreaterThanOrEqualTo: filters['salaryMin']);
        }
        if (filters.containsKey('salaryMax')) {
          query = query.where('salaryMax', isLessThanOrEqualTo: filters['salaryMax']);
        }
      }

      final snapshot = await query.get();
      
      _jobs = snapshot.docs
          .map((doc) => JobModel.fromFirestore(doc))
          .where((job) => job.status == 'active')  // FIXED: Compare with string instead of JobStatus
          .toList();

      // Load featured jobs - FIXED: Use appropriate field name
      _featuredJobs = _jobs.where((job) => job.isFeatured == true).toList();

      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading jobs: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Load AI recommended jobs for user
  Future<void> loadRecommendedJobs(String userId) async {
    try {
      _setLoading(true);

      // Get user skills
      final userDoc = await FirebaseConfig.usersCollection.doc(userId).get();
      final userSkills = List<String>.from(userDoc.data()?['skills'] ?? []);

      // In a real app, this would call an AI service
      // For now, we'll filter jobs based on skills
      final snapshot = await FirebaseConfig.jobsCollection
          .where('status', isEqualTo: 'active')
          .limit(10)
          .get();

      _recommendedJobs = snapshot.docs
          .map((doc) => JobModel.fromFirestore(doc))
          .where((job) {
            // Simple matching: check if job skills overlap with user skills
            return job.skills.any((skill) => userSkills.contains(skill));
          })
          .toList();

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading recommended jobs: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Get job by ID
  Future<JobModel?> getJobById(String jobId) async {
    try {
      final doc = await FirebaseConfig.jobsCollection.doc(jobId).get();
      if (doc.exists) {
        return JobModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      _errorMessage = 'Error loading job: $e';
      return null;
    }
  }

  // Apply for a job - FIXED: Updated to match ApplicationModel constructor
  Future<bool> applyForJob({
    required String jobId,
    required String userId,
    required String resumeUrl,
    String? coverLetter,
    Map<String, dynamic>? answers,
  }) async {
    try {
      _setLoading(true);

      // Get job details
      final jobDoc = await FirebaseConfig.jobsCollection.doc(jobId).get();
      if (!jobDoc.exists) return false;

      final job = JobModel.fromFirestore(jobDoc);

      // Get user details
      final userDoc = await FirebaseConfig.usersCollection.doc(userId).get();
      final userData = userDoc.data() ?? {};
      final userName = userData['name'] ?? 'User';
      final userEmail = userData['email'] ?? '';

      // Create application - FIXED: Match ApplicationModel constructor
      final application = ApplicationModel(
        id: FirebaseConfig.applicationsCollection.doc().id,
        jobId: jobId,
        jobTitle: job.title,
        applicantId: userId,
        applicantName: userName,
        applicantEmail: userEmail,
        employerName: job.employerName,  // FIXED: Use company name
        status: ApplicationStatus.pending,
        appliedAt: DateTime.now(),
        matchScore: null,
        coverLetter: coverLetter,
        resumeUrl: resumeUrl,
        aiAnalysis: null,
        additionalData: {
          'answers': answers,
        },
      );

      await FirebaseConfig.applicationsCollection
          .doc(application.id)
          .set(application.toFirestore());

      // Update job's applicant count
      await FirebaseConfig.jobsCollection.doc(jobId).update({
        'applicantsCount': FieldValue.increment(1),
      });

      // Update user's applied jobs
      await FirebaseConfig.usersCollection.doc(userId).update({
        'appliedJobs': FieldValue.arrayUnion([jobId]),
      });

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error applying for job: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Save/unsave a job
  Future<void> toggleSaveJob(String userId, String jobId) async {
    try {
      final userRef = FirebaseConfig.usersCollection.doc(userId);
      
      if (_savedJobs.any((job) => job.id == jobId)) {
        // Unsave
        await userRef.update({
          'savedJobs': FieldValue.arrayRemove([jobId]),
        });
        _savedJobs.removeWhere((job) => job.id == jobId);
      } else {
        // Save
        await userRef.update({
          'savedJobs': FieldValue.arrayUnion([jobId]),
        });
        
        // Load the job details
        final job = await getJobById(jobId);
        if (job != null) {
          _savedJobs.add(job);
        }
      }
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error toggling save job: $e';
      notifyListeners();
    }
  }

  // Load saved jobs for user
  Future<void> loadSavedJobs(String userId) async {
    try {
      _setLoading(true);

      final userDoc = await FirebaseConfig.usersCollection.doc(userId).get();
      final savedJobIds = List<String>.from(userDoc.data()?['savedJobs'] ?? []);

      if (savedJobIds.isEmpty) {
        _savedJobs = [];
        notifyListeners();
        return;
      }

      // Load each saved job
      final jobs = await Future.wait(
        savedJobIds.map((id) => getJobById(id)),
      );

      _savedJobs = jobs.whereType<JobModel>().toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading saved jobs: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Load applications for user
  Future<void> loadUserApplications(String userId) async {
    try {
      _setLoading(true);

      final snapshot = await FirebaseConfig.applicationsCollection
          .where('applicantId', isEqualTo: userId)
          .orderBy('appliedAt', descending: true)  // FIXED: Changed from 'appliedDate' to 'appliedAt'
          .get();

      _applications = snapshot.docs
          .map((doc) => ApplicationModel.fromFirestore(doc))
          .toList();

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading applications: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Load applications for employer
  Future<void> loadEmployerApplications(String employerId) async {
    try {
      _setLoading(true);

      final snapshot = await FirebaseConfig.applicationsCollection
          .where('employerName', isEqualTo: employerId)  // FIXED: Changed from 'employerId' to 'employerName'
          .orderBy('appliedAt', descending: true)  // FIXED: Changed from 'appliedDate' to 'appliedAt'
          .get();

      _applications = snapshot.docs
          .map((doc) => ApplicationModel.fromFirestore(doc))
          .toList();

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading applications: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Update application status
  Future<void> updateApplicationStatus(
    String applicationId,
    ApplicationStatus status, {
    String? feedback,
  }) async {
    try {
      await FirebaseConfig.applicationsCollection.doc(applicationId).update({
        'status': status.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),  // FIXED: Changed from 'reviewedDate'
        if (feedback != null) 'feedback': feedback,
      });

      // Update local list
      final index = _applications.indexWhere((app) => app.id == applicationId);
      if (index != -1) {
        final oldApp = _applications[index];
        
        // Create updated application
        final updatedApplication = ApplicationModel(
          id: oldApp.id,
          jobId: oldApp.jobId,
          jobTitle: oldApp.jobTitle,
          applicantId: oldApp.applicantId,
          applicantName: oldApp.applicantName,
          applicantEmail: oldApp.applicantEmail,
          employerName: oldApp.employerName,
          status: status,
          appliedAt: oldApp.appliedAt,
          updatedAt: DateTime.now(),
          matchScore: oldApp.matchScore,
          coverLetter: oldApp.coverLetter,
          resumeUrl: oldApp.resumeUrl,
          aiAnalysis: oldApp.aiAnalysis,
          additionalData: {
            ...?oldApp.additionalData,
            'feedback': feedback ?? oldApp.additionalData?['feedback'],
          },
        );
        
        _applications[index] = updatedApplication;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error updating application status: $e';
      notifyListeners();
    }
  }

  // Search jobs
  Future<void> searchJobs(String query) async {
    try {
      _setLoading(true);

      // This is a simple search - in production, use Algolia or similar
      final snapshot = await FirebaseConfig.jobsCollection
          .where('status', isEqualTo: 'active')
          .get();

      _jobs = snapshot.docs
          .map((doc) => JobModel.fromFirestore(doc))
          .where((job) {
            return job.title.toLowerCase().contains(query.toLowerCase()) ||
                   job.description.toLowerCase().contains(query.toLowerCase()) ||
                   job.employerName.toLowerCase().contains(query.toLowerCase());  // FIXED: Changed from 'employerName' to 'company'
          })
          .toList();

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error searching jobs: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Post a new job (for employers)
  Future<bool> postJob(JobModel job) async {
    try {
      _setLoading(true);

      await FirebaseConfig.jobsCollection.doc(job.id).set(job.toFirestore());
      
      // Add to local list
      _jobs.insert(0, job);
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error posting job: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get application statistics
  Map<String, int> getApplicationStats() {
    if (_applications.isEmpty) return {};

    final stats = <String, int>{};
    for (var app in _applications) {
      final status = app.status.display;
      stats[status] = (stats[status] ?? 0) + 1;
    }
    return stats;
  }

  // Get recent applications
  List<ApplicationModel> getRecentApplications({int limit = 5}) {
    final sorted = List<ApplicationModel>.from(_applications)
      ..sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
    return sorted.take(limit).toList();
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}