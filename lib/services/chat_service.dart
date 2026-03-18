import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/message_model.dart';
import '../config/firebase_config.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get messages stream for a conversation
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

  // Get conversations stream for a user
  Stream<List<ConversationModel>> getConversationsStream(String userId) {
    return FirebaseConfig.conversationsCollection
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ConversationModel.fromFirestore(doc))
              .toList();
        });
  }

  // Send a message
  Future<MessageModel?> sendMessage({
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
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return message;
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }

  // Send image message
  Future<MessageModel?> sendImageMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required File imageFile,
    String? caption,
  }) async {
    try {
      // Upload image first
      final imageUrl = await uploadImage(
        conversationId: conversationId,
        imageFile: imageFile,
      );

      if (imageUrl == null) return null;

      // Create message with image
      final message = MessageModel(
        id: FirebaseConfig.messagesCollection.doc().id,
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        content: caption ?? '📷 Image',
        type: MessageType.image,
        mediaUrls: [imageUrl],
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      );

      await FirebaseConfig.messagesCollection
          .doc(message.id)
          .set(message.toFirestore());

      // Update conversation
      await FirebaseConfig.conversationsCollection.doc(conversationId).update({
        'lastMessage': message.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return message;
    } catch (e) {
      print('Error sending image message: $e');
      return null;
    }
  }

  // Upload image
  Future<String?> uploadImage({
    required String conversationId,
    required File imageFile,
  }) async {
    try {
      final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'chats/$conversationId/$fileName';
      
      final ref = _storage.ref().child(path);
      await ref.putFile(imageFile);
      
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Create new conversation
  Future<ConversationModel?> createConversation({
    required List<String> participants,
    required Map<String, String> participantNames,
    ConversationType type = ConversationType.direct,
    String? title,
    String? jobId,
    String? applicationId,
  }) async {
    try {
      // Check if conversation already exists for direct messages
      if (type == ConversationType.direct) {
        final existing = await _findExistingConversation(participants);
        if (existing != null) return existing;
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

      return conversation;
    } catch (e) {
      print('Error creating conversation: $e');
      return null;
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

  // Find existing direct conversation
  Future<ConversationModel?> _findExistingConversation(
    List<String> participants,
  ) async {
    try {
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
    } catch (e) {
      print('Error finding existing conversation: $e');
      return null;
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String conversationId, String userId) async {
    try {
      final batch = _firestore.batch();
      
      final unreadMessages = await FirebaseConfig.messagesCollection
          .where('conversationId', isEqualTo: conversationId)
          .where('senderId', isNotEqualTo: userId)
          .where('status', isNotEqualTo: 'read')
          .get();

      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {
          'status': 'read',
          'readAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      // Update unread count in conversation
      await FirebaseConfig.conversationsCollection.doc(conversationId).update({
        'unreadCount': 0,
      });
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Delete message
  Future<void> deleteMessage(String messageId) async {
    try {
      await FirebaseConfig.messagesCollection.doc(messageId).delete();
    } catch (e) {
      print('Error deleting message: $e');
      rethrow;
    }
  }

  // Edit message
  Future<void> editMessage(String messageId, String newContent) async {
    try {
      await FirebaseConfig.messagesCollection.doc(messageId).update({
        'content': newContent,
        'isEdited': true,
      });
    } catch (e) {
      print('Error editing message: $e');
      rethrow;
    }
  }

  // Add reaction to message
  Future<void> addReaction(String messageId, String userId, String reaction) async {
    try {
      final messageRef = FirebaseConfig.messagesCollection.doc(messageId);
      
      await messageRef.update({
        'reactions': FieldValue.arrayUnion([{
          'userId': userId,
          'reaction': reaction,
          'timestamp': FieldValue.serverTimestamp(),
        }]),
      });
    } catch (e) {
      print('Error adding reaction: $e');
      rethrow;
    }
  }

  // Remove reaction from message
  Future<void> removeReaction(String messageId, String userId, String reaction) async {
    try {
      final messageRef = FirebaseConfig.messagesCollection.doc(messageId);
      
      await messageRef.update({
        'reactions': FieldValue.arrayRemove([{
          'userId': userId,
          'reaction': reaction,
        }]),
      });
    } catch (e) {
      print('Error removing reaction: $e');
      rethrow;
    }
  }

  // Archive conversation
  Future<void> archiveConversation(String conversationId, bool archive) async {
    try {
      await FirebaseConfig.conversationsCollection.doc(conversationId).update({
        'isArchived': archive,
      });
    } catch (e) {
      print('Error archiving conversation: $e');
      rethrow;
    }
  }

  // Mute conversation
  Future<void> muteConversation(String conversationId, bool mute) async {
    try {
      await FirebaseConfig.conversationsCollection.doc(conversationId).update({
        'isMuted': mute,
      });
    } catch (e) {
      print('Error muting conversation: $e');
      rethrow;
    }
  }

  // Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      // Delete all messages in the conversation
      final messages = await FirebaseConfig.messagesCollection
          .where('conversationId', isEqualTo: conversationId)
          .get();

      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.delete(doc.reference);
      }

      // Delete conversation
      batch.delete(FirebaseConfig.conversationsCollection.doc(conversationId));

      await batch.commit();
    } catch (e) {
      print('Error deleting conversation: $e');
      rethrow;
    }
  }

  // Get unread count for user
  Future<int> getUnreadCount(String userId) async {
    try {
      final snapshot = await FirebaseConfig.conversationsCollection
          .where('participants', arrayContains: userId)
          .where('isMuted', isEqualTo: false)
          .get();

      int total = 0;
      for (var doc in snapshot.docs) {
        final conversation = ConversationModel.fromFirestore(doc);
        total += conversation.unreadCount;
      }
      return total;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // Search messages
  Future<List<MessageModel>> searchMessages({
    required String conversationId,
    required String query,
  }) async {
    try {
      // This is a simple client-side search
      // For production, consider using Algolia or similar
      final snapshot = await FirebaseConfig.messagesCollection
          .where('conversationId', isEqualTo: conversationId)
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      final messages = snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc))
          .where((message) => 
              message.content.toLowerCase().contains(query.toLowerCase()))
          .toList();

      return messages;
    } catch (e) {
      print('Error searching messages: $e');
      return [];
    }
  }
}