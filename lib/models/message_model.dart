import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, file, system }
enum MessageStatus { sent, delivered, read, failed }

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String? senderPhoto;
  final MessageType type;
  final String content;
  final List<String>? mediaUrls;
  final Map<String, dynamic>? metadata;
  final MessageStatus status;
  final DateTime timestamp;
  final DateTime? readAt;
  final DateTime? deliveredAt;
  final bool isEdited;
  final String? replyToId;
  final MessageModel? replyTo;
  final List<MessageReaction> reactions;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderPhoto,
    this.type = MessageType.text,
    required this.content,
    this.mediaUrls,
    this.metadata,
    this.status = MessageStatus.sent,
    required this.timestamp,
    this.readAt,
    this.deliveredAt,
    this.isEdited = false,
    this.replyToId,
    this.replyTo,
    this.reactions = const [],
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return MessageModel(
      id: doc.id,
      conversationId: data['conversationId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderPhoto: data['senderPhoto'],
      type: _parseMessageType(data['type']),
      content: data['content'] ?? '',
      mediaUrls: data['mediaUrls'] != null
          ? List<String>.from(data['mediaUrls'])
          : null,
      metadata: data['metadata'],
      status: _parseMessageStatus(data['status']),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      readAt: data['readAt'] != null
          ? (data['readAt'] as Timestamp).toDate()
          : null,
      deliveredAt: data['deliveredAt'] != null
          ? (data['deliveredAt'] as Timestamp).toDate()
          : null,
      isEdited: data['isEdited'] ?? false,
      replyToId: data['replyToId'],
      replyTo: data['replyTo'] != null
          ? MessageModel.fromMap(data['replyTo'])
          : null,
      reactions: (data['reactions'] as List? ?? [])
          .map((r) => MessageReaction.fromMap(r))
          .toList(),
    );
  }

  factory MessageModel.fromMap(Map<String, dynamic> data) {
    return MessageModel(
      id: data['id'] ?? '',
      conversationId: data['conversationId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderPhoto: data['senderPhoto'],
      type: _parseMessageType(data['type']),
      content: data['content'] ?? '',
      mediaUrls: data['mediaUrls'] != null
          ? List<String>.from(data['mediaUrls'])
          : null,
      metadata: data['metadata'],
      status: _parseMessageStatus(data['status']),
      timestamp: data['timestamp'] is Timestamp
          ? (data['timestamp'] as Timestamp).toDate()
          : data['timestamp'] as DateTime,
      readAt: data['readAt'] != null
          ? data['readAt'] is Timestamp
              ? (data['readAt'] as Timestamp).toDate()
              : data['readAt'] as DateTime
          : null,
      deliveredAt: data['deliveredAt'] != null
          ? data['deliveredAt'] is Timestamp
              ? (data['deliveredAt'] as Timestamp).toDate()
              : data['deliveredAt'] as DateTime
          : null,
      isEdited: data['isEdited'] ?? false,
      replyToId: data['replyToId'],
      replyTo: data['replyTo'] != null
          ? MessageModel.fromMap(data['replyTo'])
          : null,
      reactions: (data['reactions'] as List? ?? [])
          .map((r) => MessageReaction.fromMap(r))
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'senderPhoto': senderPhoto,
      'type': type.toString().split('.').last,
      'content': content,
      'mediaUrls': mediaUrls,
      'metadata': metadata,
      'status': status.toString().split('.').last,
      'timestamp': Timestamp.fromDate(timestamp),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
      'isEdited': isEdited,
      'replyToId': replyToId,
      'replyTo': replyTo?.toMap(),
      'reactions': reactions.map((r) => r.toMap()).toList(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'senderPhoto': senderPhoto,
      'type': type.toString().split('.').last,
      'content': content,
      'mediaUrls': mediaUrls,
      'metadata': metadata,
      'status': status.toString().split('.').last,
      'timestamp': timestamp,
      'readAt': readAt,
      'deliveredAt': deliveredAt,
      'isEdited': isEdited,
      'replyToId': replyToId,
      'replyTo': replyTo?.toMap(),
      'reactions': reactions.map((r) => r.toMap()).toList(),
    };
  }

  static MessageType _parseMessageType(String? type) {
    if (type == null) return MessageType.text;
    switch (type) {
      case 'text': return MessageType.text;
      case 'image': return MessageType.image;
      case 'file': return MessageType.file;
      case 'system': return MessageType.system;
      default: return MessageType.text;
    }
  }

  static MessageStatus _parseMessageStatus(String? status) {
    if (status == null) return MessageStatus.sent;
    switch (status) {
      case 'sent': return MessageStatus.sent;
      case 'delivered': return MessageStatus.delivered;
      case 'read': return MessageStatus.read;
      case 'failed': return MessageStatus.failed;
      default: return MessageStatus.sent;
    }
  }

  bool get isMe => false; // This will be set based on current user
}

class MessageReaction {
  final String userId;
  final String reaction;
  final DateTime timestamp;

  MessageReaction({
    required this.userId,
    required this.reaction,
    required this.timestamp,
  });

  factory MessageReaction.fromMap(Map<String, dynamic> map) {
    return MessageReaction(
      userId: map['userId'] ?? '',
      reaction: map['reaction'] ?? '',
      timestamp: map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : map['timestamp'] as DateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'reaction': reaction,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

class ConversationModel {
  final String id;
  final List<String> participants;
  final Map<String, String> participantNames;
  final Map<String, String> participantPhotos;
  final MessageModel? lastMessage;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ConversationType type;
  final String? title;
  final String? jobId;
  final String? applicationId;
  final Map<String, dynamic>? metadata;
  final bool isArchived;
  final bool isMuted;

  ConversationModel({
    required this.id,
    required this.participants,
    required this.participantNames,
    this.participantPhotos = const {},
    this.lastMessage,
    this.unreadCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.type = ConversationType.direct,
    this.title,
    this.jobId,
    this.applicationId,
    this.metadata,
    this.isArchived = false,
    this.isMuted = false,
  });

  factory ConversationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return ConversationModel(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      participantNames: Map<String, String>.from(data['participantNames'] ?? {}),
      participantPhotos: Map<String, String>.from(data['participantPhotos'] ?? {}),
      lastMessage: data['lastMessage'] != null
          ? MessageModel.fromMap(data['lastMessage'])
          : null,
      unreadCount: data['unreadCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      type: _parseConversationType(data['type']),
      title: data['title'],
      jobId: data['jobId'],
      applicationId: data['applicationId'],
      metadata: data['metadata'],
      isArchived: data['isArchived'] ?? false,
      isMuted: data['isMuted'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants,
      'participantNames': participantNames,
      'participantPhotos': participantPhotos,
      'lastMessage': lastMessage?.toMap(),
      'unreadCount': unreadCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'type': type.toString().split('.').last,
      'title': title,
      'jobId': jobId,
      'applicationId': applicationId,
      'metadata': metadata,
      'isArchived': isArchived,
      'isMuted': isMuted,
    };
  }

  static ConversationType _parseConversationType(String? type) {
    if (type == null) return ConversationType.direct;
    switch (type) {
      case 'direct': return ConversationType.direct;
      case 'group': return ConversationType.group;
      case 'ai': return ConversationType.ai;
      default: return ConversationType.direct;
    }
  }

  String getDisplayName(String currentUserId) {
    if (type == ConversationType.ai) {
      return 'AI Assistant';
    }
    
    if (type == ConversationType.group) {
      return title ?? 'Group Chat';
    }
    
    // For direct messages, show the other participant's name
    final otherParticipant = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => participants.first,
    );
    
    return participantNames[otherParticipant] ?? 'User';
  }

  String? getDisplayPhoto(String currentUserId) {
    if (type == ConversationType.ai) {
      return null; // AI has default icon
    }
    
    final otherParticipant = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => participants.first,
    );
    
    return participantPhotos[otherParticipant];
  }
}

enum ConversationType { direct, group, ai }