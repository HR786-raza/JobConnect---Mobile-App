import 'package:cloud_firestore/cloud_firestore.dart';

enum JobType { fullTime, partTime, internship, contract, freelance, remote }
enum JobStatus { active, expired, draft, filled }
enum ExperienceLevel { entry, mid, senior, lead, manager }

class JobModel {
  final String id;
  final String employerId;
  final String employerName;
  final String? employerLogo;
  final String title;
  final String description;
  final List<String> requirements;
  final List<String> responsibilities;
  final List<String> skills;
  final JobType jobType;
  final JobStatus status;
  final ExperienceLevel experienceLevel;
  final String location;
  final bool isRemote;
  final double? salaryMin;
  final double? salaryMax;
  final String? salaryCurrency;
  final String? department;
  final int vacancies;
  final List<String> appliedApplicants;
  final List<String> shortlistedApplicants;
  final List<String> rejectedApplicants;
  final DateTime postedDate;
  final DateTime deadline;
  final DateTime? updatedAt;
  final Map<String, dynamic>? companyDetails;
  final List<String> benefits;
  final List<String> questions;
  final bool isFeatured;
  final int views;
  final int applicationsCount;

  JobModel({
    required this.id,
    required this.employerId,
    required this.employerName,
    this.employerLogo,
    required this.title,
    required this.description,
    this.requirements = const [],
    this.responsibilities = const [],
    this.skills = const [],
    required this.jobType,
    this.status = JobStatus.active,
    this.experienceLevel = ExperienceLevel.entry,
    required this.location,
    this.isRemote = false,
    this.salaryMin,
    this.salaryMax,
    this.salaryCurrency = 'USD',
    this.department,
    this.vacancies = 1,
    this.appliedApplicants = const [],
    this.shortlistedApplicants = const [],
    this.rejectedApplicants = const [],
    required this.postedDate,
    required this.deadline,
    this.updatedAt,
    this.companyDetails,
    this.benefits = const [],
    this.questions = const [],
    this.isFeatured = false,
    this.views = 0,
    this.applicationsCount = 0,
  });

  factory JobModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return JobModel(
      id: doc.id,
      employerId: data['employerId'] ?? '',
      employerName: data['employerName'] ?? '',
      employerLogo: data['employerLogo'],
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      requirements: List<String>.from(data['requirements'] ?? []),
      responsibilities: List<String>.from(data['responsibilities'] ?? []),
      skills: List<String>.from(data['skills'] ?? []),
      jobType: _parseJobType(data['jobType']),
      status: _parseJobStatus(data['status']),
      experienceLevel: _parseExperienceLevel(data['experienceLevel']),
      location: data['location'] ?? '',
      isRemote: data['isRemote'] ?? false,
      salaryMin: data['salaryMin']?.toDouble(),
      salaryMax: data['salaryMax']?.toDouble(),
      salaryCurrency: data['salaryCurrency'] ?? 'USD',
      department: data['department'],
      vacancies: data['vacancies'] ?? 1,
      appliedApplicants: List<String>.from(data['appliedApplicants'] ?? []),
      shortlistedApplicants: List<String>.from(data['shortlistedApplicants'] ?? []),
      rejectedApplicants: List<String>.from(data['rejectedApplicants'] ?? []),
      postedDate: (data['postedDate'] as Timestamp).toDate(),
      deadline: (data['deadline'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
      companyDetails: data['companyDetails'],
      benefits: List<String>.from(data['benefits'] ?? []),
      questions: List<String>.from(data['questions'] ?? []),
      isFeatured: data['isFeatured'] ?? false,
      views: data['views'] ?? 0,
      applicationsCount: data['applicationsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'employerId': employerId,
      'employerName': employerName,
      'employerLogo': employerLogo,
      'title': title,
      'description': description,
      'requirements': requirements,
      'responsibilities': responsibilities,
      'skills': skills,
      'jobType': jobType.toString().split('.').last,
      'status': status.toString().split('.').last,
      'experienceLevel': experienceLevel.toString().split('.').last,
      'location': location,
      'isRemote': isRemote,
      'salaryMin': salaryMin,
      'salaryMax': salaryMax,
      'salaryCurrency': salaryCurrency,
      'department': department,
      'vacancies': vacancies,
      'appliedApplicants': appliedApplicants,
      'shortlistedApplicants': shortlistedApplicants,
      'rejectedApplicants': rejectedApplicants,
      'postedDate': Timestamp.fromDate(postedDate),
      'deadline': Timestamp.fromDate(deadline),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'companyDetails': companyDetails,
      'benefits': benefits,
      'questions': questions,
      'isFeatured': isFeatured,
      'views': views,
      'applicationsCount': applicationsCount,
    };
  }

  static JobType _parseJobType(String? type) {
    if (type == null) return JobType.fullTime;
    switch (type) {
      case 'fullTime': return JobType.fullTime;
      case 'partTime': return JobType.partTime;
      case 'internship': return JobType.internship;
      case 'contract': return JobType.contract;
      case 'freelance': return JobType.freelance;
      case 'remote': return JobType.remote;
      default: return JobType.fullTime;
    }
  }

  static JobStatus _parseJobStatus(String? status) {
    if (status == null) return JobStatus.active;
    switch (status) {
      case 'active': return JobStatus.active;
      case 'expired': return JobStatus.expired;
      case 'draft': return JobStatus.draft;
      case 'filled': return JobStatus.filled;
      default: return JobStatus.active;
    }
  }

  static ExperienceLevel _parseExperienceLevel(String? level) {
    if (level == null) return ExperienceLevel.entry;
    switch (level) {
      case 'entry': return ExperienceLevel.entry;
      case 'mid': return ExperienceLevel.mid;
      case 'senior': return ExperienceLevel.senior;
      case 'lead': return ExperienceLevel.lead;
      case 'manager': return ExperienceLevel.manager;
      default: return ExperienceLevel.entry;
    }
  }

  JobModel copyWith({
    String? id,
    String? employerId,
    String? employerName,
    String? employerLogo,
    String? title,
    String? description,
    List<String>? requirements,
    List<String>? responsibilities,
    List<String>? skills,
    JobType? jobType,
    JobStatus? status,
    ExperienceLevel? experienceLevel,
    String? location,
    bool? isRemote,
    double? salaryMin,
    double? salaryMax,
    String? salaryCurrency,
    String? department,
    int? vacancies,
    List<String>? appliedApplicants,
    List<String>? shortlistedApplicants,
    List<String>? rejectedApplicants,
    DateTime? postedDate,
    DateTime? deadline,
    DateTime? updatedAt,
    Map<String, dynamic>? companyDetails,
    List<String>? benefits,
    List<String>? questions,
    bool? isFeatured,
    int? views,
    int? applicationsCount,
  }) {
    return JobModel(
      id: id ?? this.id,
      employerId: employerId ?? this.employerId,
      employerName: employerName ?? this.employerName,
      employerLogo: employerLogo ?? this.employerLogo,
      title: title ?? this.title,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      responsibilities: responsibilities ?? this.responsibilities,
      skills: skills ?? this.skills,
      jobType: jobType ?? this.jobType,
      status: status ?? this.status,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      location: location ?? this.location,
      isRemote: isRemote ?? this.isRemote,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      salaryCurrency: salaryCurrency ?? this.salaryCurrency,
      department: department ?? this.department,
      vacancies: vacancies ?? this.vacancies,
      appliedApplicants: appliedApplicants ?? this.appliedApplicants,
      shortlistedApplicants: shortlistedApplicants ?? this.shortlistedApplicants,
      rejectedApplicants: rejectedApplicants ?? this.rejectedApplicants,
      postedDate: postedDate ?? this.postedDate,
      deadline: deadline ?? this.deadline,
      updatedAt: updatedAt ?? this.updatedAt,
      companyDetails: companyDetails ?? this.companyDetails,
      benefits: benefits ?? this.benefits,
      questions: questions ?? this.questions,
      isFeatured: isFeatured ?? this.isFeatured,
      views: views ?? this.views,
      applicationsCount: applicationsCount ?? this.applicationsCount,
    );
  }

  double? get matchPercentage {
    // This would be calculated by AI in real implementation
    return null;
  }

  String get salaryDisplay {
    if (salaryMin == null && salaryMax == null) return 'Not specified';
    if (salaryMin != null && salaryMax != null) {
      return '$salaryCurrency ${salaryMin!.round()}k - ${salaryMax!.round()}k';
    }
    if (salaryMin != null) return '$salaryCurrency ${salaryMin!.round()}k+';
    return '$salaryCurrency ${salaryMax!.round()}k';
  }
}