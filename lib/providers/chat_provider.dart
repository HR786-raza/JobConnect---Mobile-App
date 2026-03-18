import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../config/firebase_config.dart';

class ChatProvider extends ChangeNotifier {
  List<ConversationModel> _conversations = [];
  List<MessageModel> _messages = [];
  ConversationModel? _currentConversation;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<ConversationModel> get conversations => _conversations;
  List<MessageModel> get messages => _messages;
  ConversationModel? get currentConversation => _currentConversation;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load conversations for user
  Future<void> loadConversations(String userId) async {
    try {
      _setLoading(true);

      final snapshot = await FirebaseConfig.conversationsCollection
          .where('participants', arrayContains: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      _conversations = snapshot.docs
          .map((doc) => ConversationModel.fromFirestore(doc))
          .toList();

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading conversations: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Load messages for a conversation
  Stream<List<MessageModel>> getMessagesStream(String conversationId) {
    return FirebaseConfig.messagesCollection
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MessageModel.fromFirestore(doc))
              .toList();
        });
  }

  // Load messages for a conversation (one-time)
  Future<void> loadMessages(String conversationId) async {
    try {
      _setLoading(true);

      final snapshot = await FirebaseConfig.messagesCollection
          .where('conversationId', isEqualTo: conversationId)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      _messages = snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc))
          .toList();

      // Mark messages as read
      await _markMessagesAsRead(conversationId);

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading messages: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Send a message
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String content,
    MessageType type = MessageType.text,
    String? replyToId,
  }) async {
    try {
      final message = MessageModel(
        id: FirebaseConfig.messagesCollection.doc().id,
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        content: content,
        type: type,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
        replyToId: replyToId,
      );

      // Save message
      await FirebaseConfig.messagesCollection
          .doc(message.id)
          .set(message.toFirestore());

      // Update conversation last message
      await FirebaseConfig.conversationsCollection.doc(conversationId).update({
        'lastMessage': message.toMap(),
        'updatedAt': Timestamp.now(),
      });

      // Add to local list if we're in this conversation
      if (_currentConversation?.id == conversationId) {
        _messages.insert(0, message);
        notifyListeners();
      }

      // Update the conversation in the list
      final convIndex = _conversations.indexWhere((c) => c.id == conversationId);
      if (convIndex != -1) {
        final updatedConversation = ConversationModel(
          id: _conversations[convIndex].id,
          participants: _conversations[convIndex].participants,
          participantNames: _conversations[convIndex].participantNames,
          participantPhotos: _conversations[convIndex].participantPhotos,
          lastMessage: message,
          unreadCount: _conversations[convIndex].unreadCount,
          createdAt: _conversations[convIndex].createdAt,
          updatedAt: DateTime.now(),
          type: _conversations[convIndex].type,
          title: _conversations[convIndex].title,
          jobId: _conversations[convIndex].jobId,
          applicationId: _conversations[convIndex].applicationId,
          metadata: _conversations[convIndex].metadata,
          isArchived: _conversations[convIndex].isArchived,
          isMuted: _conversations[convIndex].isMuted,
        );
        
        _conversations[convIndex] = updatedConversation;
        // Reorder conversations
        _conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error sending message: $e';
      notifyListeners();
    }
  }

  // Send AI message (for AI assistant)
  Future<void> sendAIMessage({
    required String conversationId,
    required String content,
  }) async {
    await sendMessage(
      conversationId: conversationId,
      senderId: 'ai_assistant',
      senderName: 'AI Assistant',
      content: content,
      type: MessageType.text,
    );
  }

  // Create a new conversation
  Future<ConversationModel?> createConversation({
    required List<String> participants,
    required Map<String, String> participantNames,
    ConversationType type = ConversationType.direct,
    String? title,
    String? jobId,
    String? applicationId,
  }) async {
    try {
      _setLoading(true);

      // Check if conversation already exists
      if (type == ConversationType.direct) {
        final existing = await _findExistingDirectConversation(participants);
        if (existing != null) {
          return existing;
        }
      }

      final conversation = ConversationModel(
        id: FirebaseConfig.conversationsCollection.doc().id,
        participants: participants,
        participantNames: participantNames,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        type: type,
        title: title,
        jobId: jobId,
        applicationId: applicationId,
      );

      await FirebaseConfig.conversationsCollection
          .doc(conversation.id)
          .set(conversation.toFirestore());

      // If it's an AI conversation, send welcome message
      if (type == ConversationType.ai) {
        await sendAIMessage(
          conversationId: conversation.id,
          content: 'Hello! I\'m your AI Career Assistant. How can I help you today?',
        );
      }

      _conversations.insert(0, conversation);
      notifyListeners();

      return conversation;
    } catch (e) {
      _errorMessage = 'Error creating conversation: $e';
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Create AI assistant conversation
  Future<ConversationModel?> createAIConversation(String userId) async {
    return await createConversation(
      participants: [userId, 'ai_assistant'],
      participantNames: {
        userId: 'You',
        'ai_assistant': 'AI Assistant',
      },
      type: ConversationType.ai,
      title: 'AI Career Assistant',
    );
  }

  // Mark messages as read
  Future<void> _markMessagesAsRead(String conversationId) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      
      final unreadMessages = await FirebaseConfig.messagesCollection
          .where('conversationId', isEqualTo: conversationId)
          .where('status', isNotEqualTo: 'read')
          .get();

      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {
          'status': 'read',
          'readAt': Timestamp.now(),
        });
      }

      await batch.commit();

      // Update unread count in conversation
      await FirebaseConfig.conversationsCollection.doc(conversationId).update({
        'unreadCount': 0,
      });

      // Update local conversation
      final index = _conversations.indexWhere((c) => c.id == conversationId);
      if (index != -1) {
        final updatedConversation = ConversationModel(
          id: _conversations[index].id,
          participants: _conversations[index].participants,
          participantNames: _conversations[index].participantNames,
          participantPhotos: _conversations[index].participantPhotos,
          lastMessage: _conversations[index].lastMessage,
          unreadCount: 0,
          createdAt: _conversations[index].createdAt,
          updatedAt: _conversations[index].updatedAt,
          type: _conversations[index].type,
          title: _conversations[index].title,
          jobId: _conversations[index].jobId,
          applicationId: _conversations[index].applicationId,
          metadata: _conversations[index].metadata,
          isArchived: _conversations[index].isArchived,
          isMuted: _conversations[index].isMuted,
        );
        
        _conversations[index] = updatedConversation;
        notifyListeners();
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Find existing direct conversation
  Future<ConversationModel?> _findExistingDirectConversation(
    List<String> participants,
  ) async {
    final snapshot = await FirebaseConfig.conversationsCollection
        .where('participants', arrayContains: participants.first)
        .get();

    for (var doc in snapshot.docs) {
      final conversation = ConversationModel.fromFirestore(doc);
      if (conversation.type == ConversationType.direct &&
          conversation.participants.toSet().containsAll(participants)) {
        return conversation;
      }
    }

    return null;
  }

  // Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      // Delete all messages
      final messages = await FirebaseConfig.messagesCollection
          .where('conversationId', isEqualTo: conversationId)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in messages.docs) {
        batch.delete(doc.reference);
      }

      // Delete conversation
      batch.delete(FirebaseConfig.conversationsCollection.doc(conversationId));

      await batch.commit();

      _conversations.removeWhere((conv) => conv.id == conversationId);
      if (_currentConversation?.id == conversationId) {
        _currentConversation = null;
        _messages = [];
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error deleting conversation: $e';
      notifyListeners();
    }
  }

  // Archive conversation - FIXED: Without copyWith
  Future<void> archiveConversation(String conversationId) async {
    try {
      await FirebaseConfig.conversationsCollection.doc(conversationId).update({
        'isArchived': true,
      });

      final index = _conversations.indexWhere((conv) => conv.id == conversationId);
      if (index != -1) {
        // Create updated conversation manually without copyWith
        final oldConv = _conversations[index];
        final updatedConversation = ConversationModel(
          id: oldConv.id,
          participants: oldConv.participants,
          participantNames: oldConv.participantNames,
          participantPhotos: oldConv.participantPhotos,
          lastMessage: oldConv.lastMessage,
          unreadCount: oldConv.unreadCount,
          createdAt: oldConv.createdAt,
          updatedAt: oldConv.updatedAt,
          type: oldConv.type,
          title: oldConv.title,
          jobId: oldConv.jobId,
          applicationId: oldConv.applicationId,
          metadata: oldConv.metadata,
          isArchived: true,
          isMuted: oldConv.isMuted,
        );
        
        _conversations[index] = updatedConversation;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error archiving conversation: $e';
      notifyListeners();
    }
  }

  // Mute conversation - FIXED: Without copyWith
  Future<void> muteConversation(String conversationId, bool mute) async {
    try {
      await FirebaseConfig.conversationsCollection.doc(conversationId).update({
        'isMuted': mute,
      });

      final index = _conversations.indexWhere((conv) => conv.id == conversationId);
      if (index != -1) {
        // Create updated conversation manually without copyWith
        final oldConv = _conversations[index];
        final updatedConversation = ConversationModel(
          id: oldConv.id,
          participants: oldConv.participants,
          participantNames: oldConv.participantNames,
          participantPhotos: oldConv.participantPhotos,
          lastMessage: oldConv.lastMessage,
          unreadCount: oldConv.unreadCount,
          createdAt: oldConv.createdAt,
          updatedAt: oldConv.updatedAt,
          type: oldConv.type,
          title: oldConv.title,
          jobId: oldConv.jobId,
          applicationId: oldConv.applicationId,
          metadata: oldConv.metadata,
          isArchived: oldConv.isArchived,
          isMuted: mute,
        );
        
        _conversations[index] = updatedConversation;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error muting conversation: $e';
      notifyListeners();
    }
  }

  // Set current conversation
  void setCurrentConversation(ConversationModel? conversation) {
    _currentConversation = conversation;
    if (conversation != null) {
      loadMessages(conversation.id);
    } else {
      _messages = [];
    }
    notifyListeners();
  }

  // Get unread count
  int getUnreadCount(String userId) {
    return _conversations.fold(0, (sum, conv) {
      if (!conv.isMuted && conv.participants.contains(userId)) {
        return sum + conv.unreadCount;
      }
      return sum;
    });
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