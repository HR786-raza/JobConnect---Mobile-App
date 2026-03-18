import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyModel {
  final String id;
  final String name;
  final String? logo;
  final String? banner;
  final String description;
  final String industry;
  final String? website;
  final String? linkedIn;
  final String? twitter;
  final String size; // 1-10, 11-50, 51-200, 201-500, 501-1000, 1000+
  final String founded;
  final String headquarters;
  final List<String> locations;
  final List<String> benefits;
  final List<String> technologies;
  final Map<String, dynamic>? socialMedia;
  final List<CompanyReview>? reviews;
  final double rating;
  final int reviewCount;
  final int jobCount;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  CompanyModel({
    required this.id,
    required this.name,
    this.logo,
    this.banner,
    required this.description,
    required this.industry,
    this.website,
    this.linkedIn,
    this.twitter,
    required this.size,
    required this.founded,
    required this.headquarters,
    this.locations = const [],
    this.benefits = const [],
    this.technologies = const [],
    this.socialMedia,
    this.reviews,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.jobCount = 0,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  factory CompanyModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return CompanyModel(
      id: doc.id,
      name: data['name'] ?? '',
      logo: data['logo'],
      banner: data['banner'],
      description: data['description'] ?? '',
      industry: data['industry'] ?? '',
      website: data['website'],
      linkedIn: data['linkedIn'],
      twitter: data['twitter'],
      size: data['size'] ?? '11-50',
      founded: data['founded'] ?? '',
      headquarters: data['headquarters'] ?? '',
      locations: List<String>.from(data['locations'] ?? []),
      benefits: List<String>.from(data['benefits'] ?? []),
      technologies: List<String>.from(data['technologies'] ?? []),
      socialMedia: data['socialMedia'],
      reviews: data['reviews'] != null
          ? (data['reviews'] as List)
              .map((r) => CompanyReview.fromMap(r))
              .toList()
          : null,
      rating: data['rating']?.toDouble() ?? 0.0,
      reviewCount: data['reviewCount'] ?? 0,
      jobCount: data['jobCount'] ?? 0,
      isVerified: data['isVerified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'logo': logo,
      'banner': banner,
      'description': description,
      'industry': industry,
      'website': website,
      'linkedIn': linkedIn,
      'twitter': twitter,
      'size': size,
      'founded': founded,
      'headquarters': headquarters,
      'locations': locations,
      'benefits': benefits,
      'technologies': technologies,
      'socialMedia': socialMedia,
      'reviews': reviews?.map((r) => r.toMap()).toList(),
      'rating': rating,
      'reviewCount': reviewCount,
      'jobCount': jobCount,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'metadata': metadata,
    };
  }
}

class CompanyReview {
  final String id;
  final String userId;
  final String userName;
  final double rating;
  final String title;
  final String review;
  final List<String> pros;
  final List<String> cons;
  final String? position;
  final DateTime date;
  final bool isRecommended;
  final int helpfulCount;
  final List<String>? responses;

  CompanyReview({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.title,
    required this.review,
    this.pros = const [],
    this.cons = const [],
    this.position,
    required this.date,
    this.isRecommended = true,
    this.helpfulCount = 0,
    this.responses,
  });

  factory CompanyReview.fromMap(Map<String, dynamic> map) {
    return CompanyReview(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      rating: map['rating']?.toDouble() ?? 0.0,
      title: map['title'] ?? '',
      review: map['review'] ?? '',
      pros: List<String>.from(map['pros'] ?? []),
      cons: List<String>.from(map['cons'] ?? []),
      position: map['position'],
      date: map['date'] is Timestamp
          ? (map['date'] as Timestamp).toDate()
          : map['date'] as DateTime,
      isRecommended: map['isRecommended'] ?? true,
      helpfulCount: map['helpfulCount'] ?? 0,
      responses: map['responses'] != null
          ? List<String>.from(map['responses'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'title': title,
      'review': review,
      'pros': pros,
      'cons': cons,
      'position': position,
      'date': Timestamp.fromDate(date),
      'isRecommended': isRecommended,
      'helpfulCount': helpfulCount,
      'responses': responses,
    };
  }
}

class DocumentTemplate {
  final String id;
  final String employerId;
  final String type; // joining_letter, internship_certificate, offer_letter
  final String name;
  final String content;
  final Map<String, dynamic>? placeholders;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  DocumentTemplate({
    required this.id,
    required this.employerId,
    required this.type,
    required this.name,
    required this.content,
    this.placeholders,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DocumentTemplate.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return DocumentTemplate(
      id: doc.id,
      employerId: data['employerId'] ?? '',
      type: data['type'] ?? '',
      name: data['name'] ?? '',
      content: data['content'] ?? '',
      placeholders: data['placeholders'],
      isDefault: data['isDefault'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'employerId': employerId,
      'type': type,
      'name': name,
      'content': content,
      'placeholders': placeholders,
      'isDefault': isDefault,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}