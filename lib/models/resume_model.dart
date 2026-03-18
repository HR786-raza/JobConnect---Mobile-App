import 'package:cloud_firestore/cloud_firestore.dart';

class ResumeModel {
  final String id;
  final String userId;
  final String title;
  final bool isDefault;
  final PersonalInfo personalInfo;
  final List<Education> education;
  final List<Experience> experience;
  final List<Project> projects;
  final List<Skill> skills;
  final List<Language> languages;
  final List<Certification> certifications;
  final String? summary;
  final Map<String, dynamic>? additionalInfo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? pdfUrl;
  final int version;
  final List<String>? templates;
  final ATSScore? atsScore;

  ResumeModel({
    required this.id,
    required this.userId,
    required this.title,
    this.isDefault = false,
    required this.personalInfo,
    this.education = const [],
    this.experience = const [],
    this.projects = const [],
    this.skills = const [],
    this.languages = const [],
    this.certifications = const [],
    this.summary,
    this.additionalInfo,
    required this.createdAt,
    required this.updatedAt,
    this.pdfUrl,
    this.version = 1,
    this.templates,
    this.atsScore,
  });

  factory ResumeModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return ResumeModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? 'My Resume',
      isDefault: data['isDefault'] ?? false,
      personalInfo: PersonalInfo.fromMap(data['personalInfo'] ?? {}),
      education: (data['education'] as List? ?? [])
          .map((e) => Education.fromMap(e))
          .toList(),
      experience: (data['experience'] as List? ?? [])
          .map((e) => Experience.fromMap(e))
          .toList(),
      projects: (data['projects'] as List? ?? [])
          .map((p) => Project.fromMap(p))
          .toList(),
      skills: (data['skills'] as List? ?? [])
          .map((s) => Skill.fromMap(s))
          .toList(),
      languages: (data['languages'] as List? ?? [])
          .map((l) => Language.fromMap(l))
          .toList(),
      certifications: (data['certifications'] as List? ?? [])
          .map((c) => Certification.fromMap(c))
          .toList(),
      summary: data['summary'],
      additionalInfo: data['additionalInfo'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      pdfUrl: data['pdfUrl'],
      version: data['version'] ?? 1,
      templates: data['templates'] != null
          ? List<String>.from(data['templates'])
          : null,
      atsScore: data['atsScore'] != null
          ? ATSScore.fromMap(data['atsScore'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'isDefault': isDefault,
      'personalInfo': personalInfo.toMap(),
      'education': education.map((e) => e.toMap()).toList(),
      'experience': experience.map((e) => e.toMap()).toList(),
      'projects': projects.map((p) => p.toMap()).toList(),
      'skills': skills.map((s) => s.toMap()).toList(),
      'languages': languages.map((l) => l.toMap()).toList(),
      'certifications': certifications.map((c) => c.toMap()).toList(),
      'summary': summary,
      'additionalInfo': additionalInfo,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'pdfUrl': pdfUrl,
      'version': version,
      'templates': templates,
      'atsScore': atsScore?.toMap(),
    };
  }

  ResumeModel copyWith({
    String? id,
    String? userId,
    String? title,
    bool? isDefault,
    PersonalInfo? personalInfo,
    List<Education>? education,
    List<Experience>? experience,
    List<Project>? projects,
    List<Skill>? skills,
    List<Language>? languages,
    List<Certification>? certifications,
    String? summary,
    Map<String, dynamic>? additionalInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? pdfUrl,
    int? version,
    List<String>? templates,
    ATSScore? atsScore,
  }) {
    return ResumeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      isDefault: isDefault ?? this.isDefault,
      personalInfo: personalInfo ?? this.personalInfo,
      education: education ?? this.education,
      experience: experience ?? this.experience,
      projects: projects ?? this.projects,
      skills: skills ?? this.skills,
      languages: languages ?? this.languages,
      certifications: certifications ?? this.certifications,
      summary: summary ?? this.summary,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      version: version ?? this.version,
      templates: templates ?? this.templates,
      atsScore: atsScore ?? this.atsScore,
    );
  }
}

class PersonalInfo {
  final String fullName;
  final String email;
  final String? phone;
  final String? location;
  final String? linkedIn;
  final String? github;
  final String? portfolio;
  final String? currentStatus; // student, fresh-graduate, job-seeker, working-professional
  final String? profileImage;

  PersonalInfo({
    required this.fullName,
    required this.email,
    this.phone,
    this.location,
    this.linkedIn,
    this.github,
    this.portfolio,
    this.currentStatus,
    this.profileImage,
  });

  factory PersonalInfo.fromMap(Map<String, dynamic> map) {
    return PersonalInfo(
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      location: map['location'],
      linkedIn: map['linkedIn'],
      github: map['github'],
      portfolio: map['portfolio'],
      currentStatus: map['currentStatus'],
      profileImage: map['profileImage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'location': location,
      'linkedIn': linkedIn,
      'github': github,
      'portfolio': portfolio,
      'currentStatus': currentStatus,
      'profileImage': profileImage,
    };
  }
}

class Education {
  final String id;
  final String degree;
  final String institution;
  final String? fieldOfStudy;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final String? grade;
  final String? description;
  final List<String>? activities;

  Education({
    required this.id,
    required this.degree,
    required this.institution,
    this.fieldOfStudy,
    required this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.grade,
    this.description,
    this.activities,
  });

  factory Education.fromMap(Map<String, dynamic> map) {
    return Education(
      id: map['id'] ?? '',
      degree: map['degree'] ?? '',
      institution: map['institution'] ?? '',
      fieldOfStudy: map['fieldOfStudy'],
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: map['endDate'] != null
          ? (map['endDate'] as Timestamp).toDate()
          : null,
      isCurrent: map['isCurrent'] ?? false,
      grade: map['grade'],
      description: map['description'],
      activities: map['activities'] != null
          ? List<String>.from(map['activities'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'degree': degree,
      'institution': institution,
      'fieldOfStudy': fieldOfStudy,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'isCurrent': isCurrent,
      'grade': grade,
      'description': description,
      'activities': activities,
    };
  }
}

class Experience {
  final String id;
  final String title;
  final String company;
  final String? location;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final String description;
  final List<String>? achievements;
  final String? companyLogo;

  Experience({
    required this.id,
    required this.title,
    required this.company,
    this.location,
    required this.startDate,
    this.endDate,
    this.isCurrent = false,
    required this.description,
    this.achievements,
    this.companyLogo,
  });

  factory Experience.fromMap(Map<String, dynamic> map) {
    return Experience(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      company: map['company'] ?? '',
      location: map['location'],
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: map['endDate'] != null
          ? (map['endDate'] as Timestamp).toDate()
          : null,
      isCurrent: map['isCurrent'] ?? false,
      description: map['description'] ?? '',
      achievements: map['achievements'] != null
          ? List<String>.from(map['achievements'])
          : null,
      companyLogo: map['companyLogo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'location': location,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'isCurrent': isCurrent,
      'description': description,
      'achievements': achievements,
      'companyLogo': companyLogo,
    };
  }
}

class Project {
  final String id;
  final String name;
  final String description;
  final List<String> technologies;
  final String? projectUrl;
  final String? githubUrl;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? highlights;

  Project({
    required this.id,
    required this.name,
    required this.description,
    this.technologies = const [],
    this.projectUrl,
    this.githubUrl,
    this.startDate,
    this.endDate,
    this.highlights,
  });

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      technologies: List<String>.from(map['technologies'] ?? []),
      projectUrl: map['projectUrl'],
      githubUrl: map['githubUrl'],
      startDate: map['startDate'] != null
          ? (map['startDate'] as Timestamp).toDate()
          : null,
      endDate: map['endDate'] != null
          ? (map['endDate'] as Timestamp).toDate()
          : null,
      highlights: map['highlights'] != null
          ? List<String>.from(map['highlights'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'technologies': technologies,
      'projectUrl': projectUrl,
      'githubUrl': githubUrl,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'highlights': highlights,
    };
  }
}

class Skill {
  final String name;
  final SkillLevel level;
  final int yearsOfExperience;
  final bool isHighlighted;

  Skill({
    required this.name,
    this.level = SkillLevel.intermediate,
    this.yearsOfExperience = 0,
    this.isHighlighted = false,
  });

  factory Skill.fromMap(Map<String, dynamic> map) {
    return Skill(
      name: map['name'] ?? '',
      level: _parseSkillLevel(map['level']),
      yearsOfExperience: map['yearsOfExperience'] ?? 0,
      isHighlighted: map['isHighlighted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'level': level.toString().split('.').last,
      'yearsOfExperience': yearsOfExperience,
      'isHighlighted': isHighlighted,
    };
  }

  static SkillLevel _parseSkillLevel(String? level) {
    if (level == null) return SkillLevel.intermediate;
    switch (level) {
      case 'beginner': return SkillLevel.beginner;
      case 'intermediate': return SkillLevel.intermediate;
      case 'advanced': return SkillLevel.advanced;
      case 'expert': return SkillLevel.expert;
      default: return SkillLevel.intermediate;
    }
  }
}

enum SkillLevel { beginner, intermediate, advanced, expert }

class Language {
  final String name;
  final LanguageProficiency proficiency;

  Language({
    required this.name,
    this.proficiency = LanguageProficiency.conversational,
  });

  factory Language.fromMap(Map<String, dynamic> map) {
    return Language(
      name: map['name'] ?? '',
      proficiency: _parseProficiency(map['proficiency']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'proficiency': proficiency.toString().split('.').last,
    };
  }

  static LanguageProficiency _parseProficiency(String? proficiency) {
    if (proficiency == null) return LanguageProficiency.conversational;
    switch (proficiency) {
      case 'basic': return LanguageProficiency.basic;
      case 'conversational': return LanguageProficiency.conversational;
      case 'professional': return LanguageProficiency.professional;
      case 'native': return LanguageProficiency.native;
      default: return LanguageProficiency.conversational;
    }
  }
}

enum LanguageProficiency { basic, conversational, professional, native }

class Certification {
  final String id;
  final String name;
  final String issuingOrganization;
  final DateTime issueDate;
  final DateTime? expirationDate;
  final String? credentialId;
  final String? credentialUrl;

  Certification({
    required this.id,
    required this.name,
    required this.issuingOrganization,
    required this.issueDate,
    this.expirationDate,
    this.credentialId,
    this.credentialUrl,
  });

  factory Certification.fromMap(Map<String, dynamic> map) {
    return Certification(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      issuingOrganization: map['issuingOrganization'] ?? '',
      issueDate: (map['issueDate'] as Timestamp).toDate(),
      expirationDate: map['expirationDate'] != null
          ? (map['expirationDate'] as Timestamp).toDate()
          : null,
      credentialId: map['credentialId'],
      credentialUrl: map['credentialUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'issuingOrganization': issuingOrganization,
      'issueDate': Timestamp.fromDate(issueDate),
      'expirationDate': expirationDate != null
          ? Timestamp.fromDate(expirationDate!)
          : null,
      'credentialId': credentialId,
      'credentialUrl': credentialUrl,
    };
  }
}

class ATSScore {
  final int overallScore;
  final int keywordsScore;
  final int formattingScore;
  final int lengthScore;
  final List<String> missingKeywords;
  final List<String> suggestions;
  final Map<String, dynamic> detailedAnalysis;

  ATSScore({
    required this.overallScore,
    required this.keywordsScore,
    required this.formattingScore,
    required this.lengthScore,
    this.missingKeywords = const [],
    this.suggestions = const [],
    this.detailedAnalysis = const {},
  });

  factory ATSScore.fromMap(Map<String, dynamic> map) {
    return ATSScore(
      overallScore: map['overallScore'] ?? 0,
      keywordsScore: map['keywordsScore'] ?? 0,
      formattingScore: map['formattingScore'] ?? 0,
      lengthScore: map['lengthScore'] ?? 0,
      missingKeywords: List<String>.from(map['missingKeywords'] ?? []),
      suggestions: List<String>.from(map['suggestions'] ?? []),
      detailedAnalysis: map['detailedAnalysis'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'overallScore': overallScore,
      'keywordsScore': keywordsScore,
      'formattingScore': formattingScore,
      'lengthScore': lengthScore,
      'missingKeywords': missingKeywords,
      'suggestions': suggestions,
      'detailedAnalysis': detailedAnalysis,
    };
  }
}