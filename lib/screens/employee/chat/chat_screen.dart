import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isAIChat = true;

  final List<Map<String, dynamic>> _aiConversations = [
    {
      'id': '1',
      'name': 'AI Career Assistant',
      'lastMessage': 'I can help you with your job search',
      'time': 'Now',
      'unread': 0,
      'avatar': Icons.auto_awesome,
      'isAI': true,
    },
  ];

  final List<Map<String, dynamic>> _recruiterConversations = [
    {
      'id': '2',
      'name': 'Sarah Johnson',
      'company': 'Tech Corp',
      'lastMessage': 'We\'d like to schedule an interview',
      'time': '2h',
      'unread': 2,
      'avatar': 'SJ',
    },
    {
      'id': '3',
      'name': 'Michael Chen',
      'company': 'Google',
      'lastMessage': 'Your application looks promising',
      'time': '1d',
      'unread': 0,
      'avatar': 'MC',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Add welcome message
    _messages.add({
      'isMe': false,
      'message': 'Hello! I\'m your AI Career Assistant. How can I help you today?',
      'time': DateTime.now(),
      'isAI': true,
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'AI Assistant', icon: Icon(Icons.auto_awesome)),
            Tab(text: 'Recruiters', icon: Icon(Icons.person)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAIChatList(),
          _buildRecruiterChatList(),
        ],
      ),
    );
  }

  Widget _buildAIChatList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _aiConversations.length,
      itemBuilder: (context, index) {
        return _buildChatTile(_aiConversations[index]);
      },
    );
  }

  Widget _buildRecruiterChatList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _recruiterConversations.length,
      itemBuilder: (context, index) {
        return _buildChatTile(_recruiterConversations[index]);
      },
    );
  }

  Widget _buildChatTile(Map<String, dynamic> chat) {
    return ListTile(
      leading: chat['isAI'] == true
          ? Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white),
            )
          : CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Text(
                chat['avatar'],
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              chat['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if (chat['unread'] > 0)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${chat['unread']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (chat.containsKey('company'))
            Text(
              chat['company'],
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          Text(
            chat['lastMessage'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      trailing: Text(
        chat['time'],
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[500],
        ),
      ),
      onTap: () {
        if (chat['isAI'] == true) {
          _openAIChat(chat);
        } else {
          _openRecruiterChat(chat);
        }
      },
    );
  }

  void _openAIChat(Map<String, dynamic> chat) {
    setState(() {
      _isAIChat = true;
      _messages.clear();
      _messages.add({
        'isMe': false,
        'message': 'Hello! I\'m your AI Career Assistant. How can I help you today?',
        'time': DateTime.now(),
        'isAI': true,
      });
    });

    _showChatDialog(chat['name']);
  }

  void _openRecruiterChat(Map<String, dynamic> chat) {
    setState(() {
      _isAIChat = false;
      _messages.clear();
      _messages.add({
        'isMe': false,
        'message': 'Thank you for your interest in our company.',
        'time': DateTime.now().subtract(const Duration(hours: 2)),
        'isAI': false,
      });
      _messages.add({
        'isMe': true,
        'message': 'I\'m very interested in the position!',
        'time': DateTime.now().subtract(const Duration(hours: 1)),
        'isAI': false,
      });
    });

    _showChatDialog(chat['name']);
  }

  void _showChatDialog(String name) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (_isAIChat)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue, Colors.purple],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                      )
                    else
                      CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        child: Text(
                          name[0],
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_isAIChat)
                            const Text(
                              'AI Career Assistant',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages.reversed.toList()[index];
                      return _buildMessageBubble(message);
                    },
                  ),
                ),
                _buildMessageInput(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message['isMe'];
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe && message['isAI'] == true)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: const Icon(Icons.auto_awesome, size: 16, color: Colors.blue),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe
                    ? Theme.of(context).primaryColor
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['message'],
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message['time']),
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () {
              // Attach file
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: Theme.of(context).primaryColor,
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        _messages.add({
          'isMe': true,
          'message': _messageController.text,
          'time': DateTime.now(),
          'isAI': false,
        });
        _messageController.clear();
      });

      // Simulate AI response
      if (_isAIChat) {
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            _messages.add({
              'isMe': false,
              'message': _getAIResponse(_messageController.text),
              'time': DateTime.now(),
              'isAI': true,
            });
          });
        });
      }
    }
  }

  String _getAIResponse(String message) {
    // This would be AI-generated in real implementation
    if (message.toLowerCase().contains('job')) {
      return 'I found several jobs matching your profile. Would you like me to show them?';
    } else if (message.toLowerCase().contains('resume')) {
      return 'I can help you improve your resume. What specific area would you like to work on?';
    } else if (message.toLowerCase().contains('interview')) {
      return 'I can help you prepare for interviews. Would you like to practice some common questions?';
    } else {
      return 'I understand. How can I assist you with your job search today?';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}