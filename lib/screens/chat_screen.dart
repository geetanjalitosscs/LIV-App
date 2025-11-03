import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/activity_service.dart';
import '../theme/liv_theme.dart';
import '../config/paths.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final int otherUserId;
  final String otherUserName;
  final String? otherUserEmail;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserEmail,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _editMessageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoadingMessages = false;
  bool _isSendingMessage = false;
  final Map<int, Future<String?>> _avatarFutures = {};
  final Map<int, bool> _messageLikes = {}; // message_id -> is_liked
  final Map<int, int> _messageLikeCounts = {}; // message_id -> likes_count
  int? _editingMessageId;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    // Load avatar for other user
    _avatarFutures[widget.otherUserId] = _loadUserAvatar(widget.otherUserId);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _editMessageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<String?> _loadUserAvatar(int userId) async {
    try {
      final userUploadsDir = Directory('${AppPaths.windowsUploadsBase}\\user_$userId');
      
      if (!userUploadsDir.existsSync()) {
        return null;
      }
      
      final prefs = await SharedPreferences.getInstance();
      final selectedGalleryAvatar = prefs.getString('user_${userId}_selectedGalleryAvatar');
      if (selectedGalleryAvatar != null && File(selectedGalleryAvatar).existsSync()) {
        return selectedGalleryAvatar;
      }
      
      final lastAvatarPngPath = prefs.getString('user_${userId}_lastAvatarPngPath');
      if (lastAvatarPngPath != null && File(lastAvatarPngPath).existsSync()) {
        return lastAvatarPngPath;
      }
      
      final pngFiles = userUploadsDir
          .listSync()
          .where((file) => file is File && file.path.toLowerCase().endsWith('.png'))
          .cast<File>()
          .toList();
      
      if (pngFiles.isEmpty) {
        return null;
      }
      
      pngFiles.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      return pngFiles.first.path;
    } catch (e) {
      return null;
    }
  }

  Future<void> _loadMessages() async {
    if (_isLoadingMessages) return;
    
    setState(() {
      _isLoadingMessages = true;
    });
    
    try {
      final authService = AuthService.instance;
      final currentUserId = authService.userId;
      
      if (currentUserId == null) {
        setState(() {
          _isLoadingMessages = false;
        });
        return;
      }
      
      final response = await http.post(
        Uri.parse('${AppPaths.apiBaseUrl}/get_messages.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user1_id': currentUserId,
          'user2_id': widget.otherUserId,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final messages = List<Map<String, dynamic>>.from(data['messages'] ?? []);
          
          // Update like states
          for (var msg in messages) {
            final msgId = msg['id'] != null ? int.tryParse(msg['id'].toString()) : null;
            if (msgId != null) {
              _messageLikes[msgId] = msg['is_liked'] == true || msg['is_liked'] == 1;
              _messageLikeCounts[msgId] = msg['likes_count'] != null 
                  ? int.tryParse(msg['likes_count'].toString()) ?? 0 
                  : 0;
            }
          }
          
          setState(() {
            _messages = messages;
            _isLoadingMessages = false;
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
        } else {
          setState(() {
            _isLoadingMessages = false;
          });
        }
      } else {
        setState(() {
          _isLoadingMessages = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingMessages = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSendingMessage) return;
    
    final authService = AuthService.instance;
    if (authService.userId == null) {
      return;
    }
    
    final messageText = _messageController.text.trim();
    _messageController.clear();
    
    setState(() {
      _isSendingMessage = true;
    });
    
    try {
      final response = await http.post(
        Uri.parse('${AppPaths.apiBaseUrl}/send_message.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'sender_id': authService.userId,
          'receiver_id': widget.otherUserId,
          'message': messageText,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Reload messages to show the new one
          await _loadMessages();
        }
      }
    } catch (e) {
      // Handle error silently or show message
    } finally {
      if (mounted) {
        setState(() {
          _isSendingMessage = false;
        });
      }
    }
  }

  Future<void> _editMessage(int messageId, String currentMessage) async {
    _editMessageController.text = currentMessage;
    _editingMessageId = messageId;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: _editMessageController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Edit your message...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _editingMessageId = null;
              _editMessageController.clear();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newText = _editMessageController.text.trim();
              if (newText.isNotEmpty) {
                await _saveEditMessage(messageId, newText);
              }
              Navigator.pop(context);
              _editingMessageId = null;
              _editMessageController.clear();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveEditMessage(int messageId, String newMessage) async {
    final authService = AuthService.instance;
    if (authService.userId == null) return;
    
    try {
      final response = await http.post(
        Uri.parse('${AppPaths.apiBaseUrl}/edit_message.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'message_id': messageId,
          'user_id': authService.userId,
          'message': newMessage,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          await _loadMessages();
        }
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _deleteMessage(int messageId) async {
    final authService = AuthService.instance;
    if (authService.userId == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final response = await http.post(
                  Uri.parse('${AppPaths.apiBaseUrl}/delete_message.php'),
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode({
                    'message_id': messageId,
                    'user_id': authService.userId,
                  }),
                );
                
                if (response.statusCode == 200) {
                  final data = json.decode(response.body);
                  if (data['success'] == true) {
                    await _loadMessages();
                  }
                }
              } catch (e) {
                // Handle error
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleMessageLike(int messageId) async {
    final authService = AuthService.instance;
    if (authService.userId == null) return;
    
    final currentLiked = _messageLikes[messageId] ?? false;
    
    // Optimistically update UI
    setState(() {
      _messageLikes[messageId] = !currentLiked;
      _messageLikeCounts[messageId] = (_messageLikeCounts[messageId] ?? 0) + (currentLiked ? -1 : 1);
    });
    
    try {
      final response = await http.post(
        Uri.parse('${AppPaths.apiBaseUrl}/toggle_message_like.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'message_id': messageId,
          'user_id': authService.userId,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _messageLikes[messageId] = data['is_liked'] == true || data['is_liked'] == 1;
            _messageLikeCounts[messageId] = int.tryParse(data['likes_count'].toString()) ?? 0;
          });
        } else {
          // Revert on error
          setState(() {
            _messageLikes[messageId] = currentLiked;
            _messageLikeCounts[messageId] = (_messageLikeCounts[messageId] ?? 0) + (currentLiked ? 1 : -1);
          });
        }
      }
    } catch (e) {
      // Revert on error
      setState(() {
        _messageLikes[messageId] = currentLiked;
        _messageLikeCounts[messageId] = (_messageLikeCounts[messageId] ?? 0) + (currentLiked ? 1 : -1);
      });
    }
  }

  String _formatTime(String? createdAt) {
    if (createdAt == null) return '';
    
    try {
      final created = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(created);
      
      if (difference.inDays > 0) {
        return '${created.day}/${created.month} ${created.hour}:${created.minute.toString().padLeft(2, '0')}';
      } else if (difference.inHours > 0) {
        return '${created.hour}:${created.minute.toString().padLeft(2, '0')}';
      } else if (difference.inMinutes > 0) {
        return '${created.hour}:${created.minute.toString().padLeft(2, '0')}';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService.instance;
    final currentUserId = authService.userId;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Consumer<ActivityService>(
              builder: (context, activityService, _) {
                final isOnline = activityService.isUserOnline(widget.otherUserId);
                
                return FutureBuilder<String?>(
                  future: _avatarFutures[widget.otherUserId],
                  builder: (context, snapshot) {
                    final avatarPath = snapshot.data;
                    
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        if (avatarPath != null && File(avatarPath).existsSync())
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: FileImage(File(avatarPath)),
                            onBackgroundImageError: (exception, stackTrace) {},
                          )
                        else
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.grey[300],
                            child: Icon(
                              Icons.person,
                              size: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        // Online indicator
                        if (isOnline)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Consumer<ActivityService>(
                builder: (context, activityService, _) {
                  final isOnline = activityService.isUserOnline(widget.otherUserId);
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.otherUserName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isOnline ? Colors.green : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isOnline ? 'Online' : 'Offline',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: LivDecorations.mainAppBackground,
        ),
      ),
      body: Container(
        decoration: LivDecorations.mainAppBackground,
        child: Column(
          children: [
            // Messages List
            Expanded(
              child: _isLoadingMessages && _messages.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : _messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: Colors.white.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No messages yet',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start a conversation',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final senderId = message['sender_id'] != null
                                ? int.tryParse(message['sender_id'].toString()) ?? 0
                                : 0;
                            final isMe = senderId == currentUserId;
                            
                            return _buildMessageBubble(message, isMe);
                          },
                        ),
            ),
            
            // Message Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [LivTheme.primaryPink, Colors.purple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: IconButton(
                        icon: _isSendingMessage
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.send, color: Colors.white),
                        onPressed: _isSendingMessage ? null : _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe) {
    final messageId = message['id'] != null ? int.tryParse(message['id'].toString()) : null;
    final messageText = message['message'] ?? '';
    final createdAt = message['created_at'];
    final editedAt = message['edited_at'];
    final isRead = message['is_read'] == true || message['is_read'] == 1;
    final authService = AuthService.instance;
    final currentUserId = authService.userId;
    final isLiked = messageId != null ? (_messageLikes[messageId] ?? false) : false;
    final likesCount = messageId != null ? (_messageLikeCounts[messageId] ?? 0) : 0;
    final isEdited = editedAt != null && editedAt.toString().isNotEmpty;
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: _MessageBubbleWithMenu(
        messageId: messageId,
        messageText: messageText,
        isMe: isMe,
        createdAt: createdAt,
        editedAt: editedAt,
        isRead: isRead,
        isLiked: isLiked,
        likesCount: likesCount,
        isEdited: isEdited,
        onEdit: messageId != null && isMe
            ? () => _editMessage(messageId, messageText)
            : null,
        onDelete: messageId != null ? () => _deleteMessage(messageId) : null,
        onLike: messageId != null ? () => _toggleMessageLike(messageId) : null,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          decoration: BoxDecoration(
            color: isMe
                ? LivTheme.primaryPink.withOpacity(0.9)
                : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20).copyWith(
              bottomRight: isMe ? const Radius.circular(4) : null,
              bottomLeft: !isMe ? const Radius.circular(4) : null,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                messageText,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.white,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isEdited)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        '(edited)',
                        style: TextStyle(
                          color: isMe
                              ? Colors.white.withOpacity(0.7)
                              : Colors.white.withOpacity(0.5),
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  Text(
                    _formatTime(createdAt),
                    style: TextStyle(
                      color: isMe
                          ? Colors.white.withOpacity(0.8)
                          : Colors.white.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                  if (isMe) // Read receipts only for sent messages
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        isRead ? Icons.done_all : Icons.done,
                        size: 14,
                        color: isRead ? Colors.blue[300] : Colors.white.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
              // Like count display - now shows for all messages including own
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: messageId != null ? () => _toggleMessageLike(messageId) : null,
                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 14,
                        color: isLiked ? Colors.red[300] : Colors.white.withOpacity(0.7),
                      ),
                    ),
                    if (likesCount > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        '$likesCount',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget that shows 3 dots menu on hover
class _MessageBubbleWithMenu extends StatefulWidget {
  final int? messageId;
  final String messageText;
  final bool isMe;
  final String? createdAt;
  final String? editedAt;
  final bool isRead;
  final bool isLiked;
  final int likesCount;
  final bool isEdited;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onLike;
  final Widget child;

  const _MessageBubbleWithMenu({
    required this.messageId,
    required this.messageText,
    required this.isMe,
    required this.createdAt,
    required this.editedAt,
    required this.isRead,
    required this.isLiked,
    required this.likesCount,
    required this.isEdited,
    this.onEdit,
    this.onDelete,
    this.onLike,
    required this.child,
  });

  @override
  State<_MessageBubbleWithMenu> createState() => _MessageBubbleWithMenuState();
}

class _MessageBubbleWithMenuState extends State<_MessageBubbleWithMenu> {
  bool _isHovering = false;

  void _showMenu() {
    if (widget.messageId == null) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: LivTheme.glassmorphicBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.onEdit != null) // Only show edit for own messages
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.white),
                title: const Text('Edit', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  widget.onEdit?.call();
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                widget.onDelete?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onLongPress: _showMenu,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            widget.child,
            // 3 dots menu button
            if (_isHovering)
              Positioned(
                top: 4,
                right: widget.isMe ? 4 : null,
                left: widget.isMe ? null : 4,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _showMenu,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.more_vert,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
