import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../theme/liv_theme.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late Animation<Color?> _backgroundTint;
  
  final TextEditingController _postController = TextEditingController();
  bool _isPosting = false;
  
  List<Map<String, dynamic>> _posts = [
    {
      'id': '1',
      'user': 'Sarah M.',
      'avatar': 'assets/avatars/Gemini_Generated_Image_1x9rce1x9rce1x9r.png',
      'time': '2 hours ago',
      'content': 'Just had an amazing time with friends! The key was being myself and asking genuine questions. 💕',
      'likes': 24,
      'comments': 8,
      'isLiked': false,
    },
    {
      'id': '2',
      'user': 'Mike T.',
      'avatar': 'assets/avatars/Gemini_Generated_Image_4echfc4echfc4ech.png',
      'time': '4 hours ago',
      'content': 'Friendship tip: Listen more than you talk. People love to feel heard and understood.',
      'likes': 18,
      'comments': 5,
      'isLiked': true,
    },
    {
      'id': '3',
      'user': 'Emma L.',
      'avatar': 'assets/avatars/Gemini_Generated_Image_8h3zz58h3zz58h3z.png',
      'time': '6 hours ago',
      'content': 'Found my best friend through this app! We connected over our shared love for hiking and books. 📚🏔️',
      'likes': 42,
      'comments': 15,
      'isLiked': false,
    },
    {
      'id': '4',
      'user': 'Jessica K.',
      'avatar': 'assets/avatars/Gemini_Generated_Image_9btvl39btvl39btv.png',
      'time': '8 hours ago',
      'content': 'Hey babe sorry na - just got busy with work! Let\'s catch up soon 💕',
      'likes': 12,
      'comments': 3,
      'isLiked': false,
    },
    {
      'id': '5',
      'user': 'Alex R.',
      'avatar': 'assets/avatars/Gemini_Generated_Image_9tb20o9tb20o9tb2.png',
      'time': '1 day ago',
      'content': 'Coffee dates are the best! Simple, relaxed, and perfect for getting to know someone ☕',
      'likes': 31,
      'comments': 7,
      'isLiked': true,
    },
    {
      'id': '6',
      'user': 'Lisa P.',
      'avatar': 'assets/avatars/Gemini_Generated_Image_dnyipmdnyipmdnyi.png',
      'time': '1 day ago',
      'content': 'First date success! We talked for 3 hours straight - time just flew by ⏰',
      'likes': 28,
      'comments': 9,
      'isLiked': false,
    },
  ];
  
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
  }
  
  @override
  void dispose() {
    _backgroundController.dispose();
    _postController.dispose();
    super.dispose();
  }
  
  void _toggleLike(int index) {
    setState(() {
      _posts[index]['isLiked'] = !_posts[index]['isLiked'];
      if (_posts[index]['isLiked']) {
        _posts[index]['likes']++;
      } else {
        _posts[index]['likes']--;
      }
    });
  }
  
  Future<void> _createPost() async {
    if (_postController.text.trim().isEmpty) return;
    
    setState(() {
      _isPosting = true;
    });
    
    // Simulate posting
    await Future.delayed(const Duration(seconds: 2));
    
    final newPost = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'user': 'You',
      'avatar': '👤',
      'time': 'Just now',
      'content': _postController.text.trim(),
      'likes': 0,
      'comments': 0,
      'isLiked': false,
    };
    
    setState(() {
      _posts.insert(0, newPost);
      _postController.clear();
      _isPosting = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post created successfully!'),
        backgroundColor: Colors.green,
      ),
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
            decoration: LivDecorations.gradientDecoration,
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
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _posts.length,
                      itemBuilder: (context, index) {
                        final post = _posts[index];
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
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(post['avatar']),
                onBackgroundImageError: (exception, stackTrace) {
                  // Handle error by showing a fallback
                },
                child: null, // Always use backgroundImage for assets
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['user'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      post['time'],
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
                  _showPostOptions(context, index);
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
            post['content'],
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
                onTap: () => _toggleLike(index),
                child: Row(
                  children: [
                    Icon(
                      post['isLiked'] ? Icons.favorite : Icons.favorite_border,
                      color: post['isLiked'] ? Colors.red : Colors.white70,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post['likes']}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Row(
                children: [
                  const Icon(
                    Icons.comment_outlined,
                    color: Colors.white70,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post['comments']}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              const Icon(
                Icons.share_outlined,
                color: Colors.white70,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _showPostOptions(BuildContext context, int index) {
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Post reported')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.block),
                  title: const Text('Block User'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User blocked')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.copy),
                  title: const Text('Copy Text'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Text copied to clipboard')),
                    );
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