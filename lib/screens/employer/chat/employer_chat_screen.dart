import 'package:flutter/material.dart';
import 'package:jobconnect/services/chat_service.dart';
import 'package:jobconnect/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class EmployerChatScreen extends StatefulWidget {
  const EmployerChatScreen({super.key});

  @override
  State<EmployerChatScreen> createState() => _EmployerChatScreenState();
}

class _EmployerChatScreenState extends State<EmployerChatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ChatService chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, dynamic>> _aiConversations = [];
  List<Map<String, dynamic>> _applicantConversations = [];
  Map<String, dynamic>? _selectedConversation;
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadConversations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading conversations
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _aiConversations = [
        {
          'id': 'ai_1',
          'name': 'AI Career Assistant',
          'lastMessage': 'I can help you find the best candidates',
          'time': '2 min ago',
          'unread': 0,
          'avatar': Icons.auto_awesome,
          'type': 'ai',
        },
      ];

      _applicantConversations = [
        {
          'id': 'app_1',
          'name': 'John Doe',
          'position': 'Flutter Developer',
          'lastMessage': 'Thank you for the opportunity!',
          'time': '1 hour ago',
          'unread': 2,
          'avatar': 'JD',
          'type': 'applicant',
        },
        {
          'id': 'app_2',
          'name': 'Jane Smith',
          'position': 'UI/UX Designer',
          'lastMessage': 'When can I expect to hear back?',
          'time': '3 hours ago',
          'unread': 0,
          'avatar': 'JS',
          'type': 'applicant',
        },
        {
          'id': 'app_3',
          'name': 'Mike Johnson',
          'position': 'Product Manager',
          'lastMessage': 'I\'m interested in the position',
          'time': '1 day ago',
          'unread': 0,
          'avatar': 'MJ',
          'type': 'applicant',
        },
      ];

      _isLoading = false;
    });
  }

  void _selectConversation(Map<String, dynamic> conversation) {
    setState(() {
      _selectedConversation = conversation;
      _loadMessages(conversation['id']);
    });
  }

  void _loadMessages(String conversationId) {
    // Simulate loading messages
    setState(() {
      if (conversationId == 'ai_1') {
        _messages = [
          {
            'isMe': false,
            'message': 'Hello! I\'m your AI Career Assistant. How can I help you find candidates today?',
            'time': DateTime.now().subtract(const Duration(minutes: 5)),
            'type': 'text',
          },
          {
            'isMe': true,
            'message': 'I need help finding Flutter developers',
            'time': DateTime.now().subtract(const Duration(minutes: 4)),
            'type': 'text',
          },
          {
            'isMe': false,
            'message': 'I can help with that! I\'ll analyze your job requirements and suggest the best matching candidates from our database.',
            'time': DateTime.now().subtract(const Duration(minutes: 3)),
            'type': 'text',
          },
        ];
      } else {
        _messages = [
          {
            'isMe': false,
            'message': 'Thank you for considering my application!',
            'time': DateTime.now().subtract(const Duration(hours: 2)),
            'type': 'text',
          },
          {
            'isMe': true,
            'message': 'We were impressed with your resume. Would you be available for an interview next week?',
            'time': DateTime.now().subtract(const Duration(hours: 1)),
            'type': 'text',
          },
          {
            'isMe': false,
            'message': 'Yes, I would love that! When would be a good time?',
            'time': DateTime.now().subtract(const Duration(minutes: 30)),
            'type': 'text',
          },
        ];
      }
    });

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'isMe': true,
        'message': _messageController.text,
        'time': DateTime.now(),
        'type': 'text',
      });
      _messageController.clear();
    });

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Simulate response for AI chat
    if (_selectedConversation?['type'] == 'ai') {
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _messages.add({
            'isMe': false,
            'message': _getAIResponse(_messageController.text),
            'time': DateTime.now(),
            'type': 'text',
          });
        });
      });
    }
  }

  String _getAIResponse(String message) {
    if (message.toLowerCase().contains('candidate') || message.toLowerCase().contains('developer')) {
      return 'I found 15 candidates matching your requirements. Would you like to see their profiles?';
    } else if (message.toLowerCase().contains('interview')) {
      return 'I can help you schedule interviews. Which candidate would you like to interview?';
    } else if (message.toLowerCase().contains('job')) {
      return 'I can help you optimize your job posting to attract more qualified candidates.';
    } else {
      return 'I understand. How else can I assist you with your hiring process?';
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'AI Assistant', icon: Icon(Icons.auto_awesome)),
            Tab(text: 'Applicants', icon: Icon(Icons.people)),
          ],
        ),
      ),
      body: Row(
        children: [
          // Conversations List
          Container(
            width: 320,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const TextField(
                            decoration: InputDecoration(
                              hintText: 'Search conversations...',
                              prefixIcon: Icon(Icons.search, size: 20),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),

                      // Conversations
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // AI Conversations
                            ListView.builder(
                              itemCount: _aiConversations.length,
                              itemBuilder: (context, index) {
                                return _buildConversationTile(_aiConversations[index]);
                              },
                            ),

                            // Applicant Conversations
                            ListView.builder(
                              itemCount: _applicantConversations.length,
                              itemBuilder: (context, index) {
                                return _buildConversationTile(_applicantConversations[index]);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),

          // Chat Area
          Expanded(
            child: _selectedConversation == null
                ? _buildEmptyChat()
                : Column(
                    children: [
                      // Chat Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: Row(
                          children: [
                            if (_selectedConversation!['type'] == 'ai')
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.blue, Colors.purple],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.auto_awesome,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              )
                            else
                              CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                child: Text(
                                  _selectedConversation!['avatar'],
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedConversation!['name'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (_selectedConversation!['type'] == 'applicant')
                                    Text(
                                      _selectedConversation!['position'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () {
                                _showChatOptions();
                              },
                            ),
                          ],
                        ),
                      ),

                      // Messages
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            return _buildMessageBubble(message);
                          },
                        ),
                      ),

                      // Message Input
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: InputDecoration(
                                  hintText: 'Type a message...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                ),
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.send, color: Colors.white),
                                onPressed: _sendMessage,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(Map<String, dynamic> conversation) {
    final isSelected = _selectedConversation?['id'] == conversation['id'];

    return ListTile(
      selected: isSelected,
      selectedTileColor: Colors.blue.withOpacity(0.1),
      leading: conversation['type'] == 'ai'
          ? Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 20,
              ),
            )
          : CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Text(
                conversation['avatar'],
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
      title: Text(
        conversation['name'],
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        conversation['lastMessage'],
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            conversation['time'],
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
          if (conversation['unread'] > 0)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${conversation['unread']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: () => _selectConversation(conversation),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message['isMe'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Colors.grey[200],
                child: _selectedConversation?['type'] == 'ai'
                    ? const Icon(Icons.auto_awesome, size: 12, color: Colors.blue)
                    : Text(
                        _selectedConversation!['avatar'][0],
                        style: const TextStyle(fontSize: 10),
                      ),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe
                    ? Theme.of(context).primaryColor
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: isMe
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: isMe
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
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

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No conversation selected',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a conversation to start messaging',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Chat Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.archive, color: Colors.blue),
              title: const Text('Archive Chat'),
              onTap: () {
                Navigator.pop(context);
                // Archive chat
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_off, color: Colors.orange),
              title: const Text('Mute Notifications'),
              onTap: () {
                Navigator.pop(context);
                // Mute chat
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Chat'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: const Text('Are you sure you want to delete this conversation? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedConversation = null;
                _messages = [];
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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