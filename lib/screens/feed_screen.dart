import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../theme/liv_theme.dart';
import '../config/paths.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late Animation<Color?> _backgroundTint;
  
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  bool _isPosting = false;
  bool _isLoadingPosts = false;
  
  List<Map<String, dynamic>> _posts = [];
  final Map<int, Future<String?>> _avatarFutures = {}; // Cache for avatar futures
  final Map<int, List<Map<String, dynamic>>> _commentsCache = {}; // Cache for comments
  
  @override
  void initState() {
    super.initState();
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    
    _backgroundTint = ColorTween(
      begin: const Color(0xFF667eea),
      end: const Color(0xFF764ba2),
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));
    
    _backgroundController.repeat(reverse: true);
    
    // Load posts when screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPosts();
    });
  }
  
  @override
  void dispose() {
    _backgroundController.dispose();
    _postController.dispose();
    _commentController.dispose();
    super.dispose();
  }
  
  Future<void> _loadPosts() async {
    if (_isLoadingPosts) return;
    
    setState(() {
      _isLoadingPosts = true;
    });
    
    try {
      final authService = AuthService.instance;
      final currentUserId = authService.userId;
      
      final response = await http.post(
        Uri.parse('${AppPaths.apiBaseUrl}/get_posts.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'current_user_id': currentUserId,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final posts = List<Map<String, dynamic>>.from(data['posts'] ?? []);
          
          // Pre-load avatars for all posts
          for (var post in posts) {
            final userIdInt = post['user_id'] != null 
                ? int.tryParse(post['user_id'].toString()) 
                : null;
            if (userIdInt != null && !_avatarFutures.containsKey(userIdInt)) {
              _avatarFutures[userIdInt] = _loadUserAvatar(userIdInt);
            }
          }
          
          setState(() {
            _posts = posts;
            _isLoadingPosts = false;
          });
        } else {
          setState(() {
            _isLoadingPosts = false;
          });
          if (mounted) {
            LivPopupMessage.showError(context, data['error'] ?? 'Failed to load posts');
          }
        }
      } else {
        setState(() {
          _isLoadingPosts = false;
        });
        if (mounted) {
          LivPopupMessage.showError(context, 'Server error: ${response.statusCode}');
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingPosts = false;
      });
      if (mounted) {
        LivPopupMessage.showError(context, 'Error loading posts: ${e.toString()}');
      }
    }
  }
  
  Future<String?> _loadUserAvatar(int userId) async {
    try {
      final userUploadsDir = Directory('${AppPaths.windowsUploadsBase}\\user_$userId');
      
      if (!userUploadsDir.existsSync()) {
        return null;
      }
      
      // Check for selected gallery avatar first
      final prefs = await SharedPreferences.getInstance();
      final selectedGalleryAvatar = prefs.getString('user_${userId}_selectedGalleryAvatar');
      if (selectedGalleryAvatar != null && File(selectedGalleryAvatar).existsSync()) {
        return selectedGalleryAvatar;
      }
      
      // Check for last avatar PNG path
      final lastAvatarPngPath = prefs.getString('user_${userId}_lastAvatarPngPath');
      if (lastAvatarPngPath != null && File(lastAvatarPngPath).existsSync()) {
        return lastAvatarPngPath;
      }
      
      // Fallback: Get most recent PNG file
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
  
  Future<String?> _getUserAvatarFuture(int userId) {
    if (!_avatarFutures.containsKey(userId)) {
      _avatarFutures[userId] = _loadUserAvatar(userId);
    }
    return _avatarFutures[userId]!;
  }
  
  Future<void> _createPost() async {
    if (_postController.text.trim().isEmpty) return;
    
    final authService = AuthService.instance;
    if (authService.userId == null) {
      LivPopupMessage.showError(context, 'Please log in to create a post');
      return;
    }
    
    setState(() {
      _isPosting = true;
    });
    
    try {
      final response = await http.post(
        Uri.parse('${AppPaths.apiBaseUrl}/create_post.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': authService.userId,
          'content': _postController.text.trim(),
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _postController.clear();
          // Reload posts to show the new one
          await _loadPosts();
          if (mounted) {
            LivPopupMessage.showSuccess(context, 'Post created successfully!');
          }
        } else {
          if (mounted) {
            LivPopupMessage.showError(context, data['error'] ?? 'Failed to create post');
          }
        }
      } else {
        if (mounted) {
          LivPopupMessage.showError(context, 'Server error: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (mounted) {
        LivPopupMessage.showError(context, 'Error creating post: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }
  
  Future<void> _togglePostLike(int postId, int index) async {
    final authService = AuthService.instance;
    if (authService.userId == null) {
      LivPopupMessage.showError(context, 'Please log in to like posts');
      return;
    }
    
    try {
      final response = await http.post(
        Uri.parse('${AppPaths.apiBaseUrl}/toggle_post_like.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'post_id': postId,
          'user_id': authService.userId,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _posts[index]['is_liked'] = data['is_liked'] == true || data['is_liked'] == 1;
            _posts[index]['likes_count'] = data['likes_count'] != null 
                ? int.tryParse(data['likes_count'].toString()) ?? 0 
                : 0;
          });
        } else {
          if (mounted) {
            LivPopupMessage.showError(context, data['error'] ?? 'Failed to like post');
          }
        }
      } else {
        if (mounted) {
          LivPopupMessage.showError(context, 'Server error: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (mounted) {
        LivPopupMessage.showError(context, 'Error: ${e.toString()}');
      }
    }
  }
  
  Future<void> _loadComments(int postId) async {
    if (_commentsCache.containsKey(postId)) {
      return; // Comments already loaded
    }
    
    try {
      final response = await http.post(
        Uri.parse('${AppPaths.apiBaseUrl}/get_comments.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'post_id': postId,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final comments = List<Map<String, dynamic>>.from(data['comments'] ?? []);
          setState(() {
            _commentsCache[postId] = comments;
          });
        }
      }
    } catch (e) {
      // Silently handle errors
    }
  }
  
  Future<void> _addComment(int postId, int postIndex) async {
    if (_commentController.text.trim().isEmpty) return;
    
    final authService = AuthService.instance;
    if (authService.userId == null) {
      LivPopupMessage.showError(context, 'Please log in to comment');
      return;
    }
    
    try {
      final response = await http.post(
        Uri.parse('${AppPaths.apiBaseUrl}/add_comment.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'post_id': postId,
          'user_id': authService.userId,
          'content': _commentController.text.trim(),
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Clear comment input
          _commentController.clear();
          
          // Reload comments
          _commentsCache.remove(postId);
          await _loadComments(postId);
          
          // Update comment count
          setState(() {
            final currentCount = _posts[postIndex]['comments_count'] != null
                ? int.tryParse(_posts[postIndex]['comments_count'].toString()) ?? 0
                : 0;
            _posts[postIndex]['comments_count'] = currentCount + 1;
          });
        } else {
          if (mounted) {
            LivPopupMessage.showError(context, data['error'] ?? 'Failed to add comment');
          }
        }
      } else {
        if (mounted) {
          LivPopupMessage.showError(context, 'Server error: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (mounted) {
        LivPopupMessage.showError(context, 'Error: ${e.toString()}');
      }
    }
  }
  
  Future<void> _sharePost(int postId) async {
    final authService = AuthService.instance;
    if (authService.userId == null) {
      LivPopupMessage.showError(context, 'Please log in to share posts');
      return;
    }
    
    try {
      final response = await http.post(
        Uri.parse('${AppPaths.apiBaseUrl}/share_post.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'post_id': postId,
          'user_id': authService.userId,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          LivPopupMessage.showSuccess(context, 'Post shared successfully!');
        } else {
          LivPopupMessage.showError(context, data['error'] ?? 'Failed to share post');
        }
      } else {
        LivPopupMessage.showError(context, 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      LivPopupMessage.showError(context, 'Error: ${e.toString()}');
    }
  }
  
  String _formatTime(String? createdAt) {
    if (createdAt == null) return 'Just now';
    
    try {
      final created = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(created);
      
      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Just now';
    }
  }
  
  void _showCommentsDialog(int postId, int postIndex) {
    // Load comments if not cached
    if (!_commentsCache.containsKey(postId)) {
      _loadComments(postId);
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Comments',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Comments List
                Expanded(
                  child: _commentsCache.containsKey(postId)
                      ? (_commentsCache[postId]!.isEmpty
                          ? Center(
                              child: Text(
                                'No comments yet',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _commentsCache[postId]!.length,
                              itemBuilder: (context, index) {
                                final comment = _commentsCache[postId]![index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            comment['user_name'] ?? 'User',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _formatTime(comment['created_at']),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        comment['content'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ))
                      : const Center(
                          child: CircularProgressIndicator(),
                        ),
                ),
                // Add Comment Input
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'Write a comment...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) {
                            _addComment(postId, postIndex);
                            Navigator.pop(context);
                            _showCommentsDialog(postId, postIndex);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send),
                        color: LivTheme.primaryPink,
                        onPressed: () {
                          _addComment(postId, postIndex);
                          Navigator.pop(context);
                          _showCommentsDialog(postId, postIndex);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Feed'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: LivDecorations.mainAppBackground,
        ),
      ),
      body: AnimatedBuilder(
        animation: _backgroundTint,
        builder: (context, child) {
          return Container(
            decoration: LivDecorations.mainAppBackground,
            child: SafeArea(
              child: Column(
                children: [
                  // Create Post Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _postController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Share your thoughts or ask for advice...',
                            hintStyle: const TextStyle(color: Colors.white70),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white30),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white30),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: _isPosting ? null : _createPost,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF667eea),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isPosting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                                      ),
                                    )
                                  : const Text('Post'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Posts List
                  Expanded(
                    child: _isLoadingPosts
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : _posts.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.feed_outlined,
                                      size: 64,
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No posts yet',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: _loadPosts,
                                      child: const Text(
                                        'Refresh Here',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _posts.length,
                                itemBuilder: (context, index) {
                                  final post = _posts[index];
                                  final postId = post['id'] != null 
                                      ? int.tryParse(post['id'].toString()) 
                                      : null;
                                  // Skip posts with invalid IDs
                                  if (postId == null || postId == 0) {
                                    return const SizedBox.shrink();
                                  }
                                  return _buildPostCard(post, index);
                                },
                              ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildPostCard(Map<String, dynamic> post, int index) {
    final postId = post['id'] != null 
        ? int.tryParse(post['id'].toString()) ?? 0 
        : 0;
    final userId = post['user_id'] != null 
        ? int.tryParse(post['user_id'].toString()) ?? 0 
        : 0;
    final userName = post['user_name'] ?? 'User';
    final content = post['content'] ?? '';
    final createdAt = post['created_at'];
    final likesCount = post['likes_count'] != null 
        ? int.tryParse(post['likes_count'].toString()) ?? 0 
        : 0;
    final commentsCount = post['comments_count'] != null 
        ? int.tryParse(post['comments_count'].toString()) ?? 0 
        : 0;
    final isLiked = post['is_liked'] == true || post['is_liked'] == 1;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info
          Row(
            children: [
              FutureBuilder<String?>(
                key: ValueKey('post_avatar_$userId'),
                future: _getUserAvatarFuture(userId),
                builder: (context, snapshot) {
                  final avatarPath = snapshot.data;
                  if (avatarPath != null && File(avatarPath).existsSync()) {
                    return CircleAvatar(
                      radius: 20,
                      backgroundImage: FileImage(File(avatarPath)),
                      onBackgroundImageError: (exception, stackTrace) {},
                    );
                  }
                  return CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[300],
                    child: Icon(
                      Icons.person,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _formatTime(createdAt),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // Show more options
                  _showPostOptions(context, postId);
                },
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Post Content
          Text(
            content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          
          // Actions
          Row(
            children: [
              GestureDetector(
                onTap: () => _togglePostLike(postId, index),
                child: Row(
                  children: [
                    Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.white70,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$likesCount',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              GestureDetector(
                onTap: () => _showCommentsDialog(postId, index),
                child: Row(
                  children: [
                    const Icon(
                      Icons.comment_outlined,
                      color: Colors.white70,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$commentsCount',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              GestureDetector(
                onTap: () => _sharePost(postId),
                child: const Icon(
                  Icons.share_outlined,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _showPostOptions(BuildContext context, int postId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.report),
                  title: const Text('Report'),
                  onTap: () {
                    Navigator.pop(context);
                    LivPopupMessage.showInfo(context, 'Post reported');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.block),
                  title: const Text('Block User'),
                  onTap: () {
                    Navigator.pop(context);
                    LivPopupMessage.showInfo(context, 'User blocked');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.copy),
                  title: const Text('Copy Text'),
                  onTap: () {
                    Navigator.pop(context);
                    LivPopupMessage.showInfo(context, 'Text copied to clipboard');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}