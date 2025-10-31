import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/theme_service.dart';
import '../services/avtar_service.dart';
import '../theme/liv_theme.dart';
import '../config/paths.dart';
import '../widgets/bottom_navigation.dart';
import 'coach_screen.dart';
import 'feed_screen.dart';
import 'edit_profile_screen.dart';
import 'feedback_screen.dart';
import 'welcome_back_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Map<String, dynamic>> _allUsers = [];
  bool _isLoadingUsers = false;
  // Cache futures to prevent recreation on rebuilds
  final Map<int, Future<String?>> _avatarFutures = {};
  // Track like counts and liked status
  final Map<int, int> _likeCounts = {};
  final Set<int> _likedUserIds = {};
  int? _lastLoadedUserId; // Track which user's likes were loaded
  
  @override
  void initState() {
    super.initState();
    // Refresh avatar when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
      _loadAllUsers();
    });
  }
  
  Future<void> _loadAllUsers() async {
    setState(() {
      _isLoadingUsers = true;
    });
    
    try {
      final authService = AuthService.instance;
      final currentUserId = authService.userId;
      
      print('Loading all users... Current User ID: $currentUserId');
      print('API URL: ${AppPaths.apiBaseUrl}/get_all_users.php');
      
      final response = await http.post(
        Uri.parse('${AppPaths.apiBaseUrl}/get_all_users.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'current_user_id': currentUserId,
        }),
      );
      
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Parsed data: $data');
        
        if (data['success'] == true) {
          final users = List<Map<String, dynamic>>.from(data['users'] ?? []);
          print('Loaded ${users.length} users');
          // Clear old avatar futures that are no longer needed
          final userIds = users.map((u) => u['id'] != null ? int.tryParse(u['id'].toString()) : null).whereType<int>().toSet();
          _avatarFutures.removeWhere((key, _) => !userIds.contains(key));
          
          // Load like counts and liked status
          await _loadLikesData(userIds.toList());
          
          // Update last loaded user ID if current user is logged in
          final authService = AuthService.instance;
          if (authService.userId != null) {
            _lastLoadedUserId = authService.userId;
          }
          
          setState(() {
            _allUsers = users;
            _isLoadingUsers = false;
          });
        } else {
          print('API returned success=false');
          setState(() {
            _isLoadingUsers = false;
          });
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Response: ${response.body}');
        setState(() {
          _isLoadingUsers = false;
        });
      }
    } catch (e, stackTrace) {
      print('Error loading users: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isLoadingUsers = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh avatar when returning to this screen
    setState(() {});
  }
  
  // Method to refresh the avatar display
  void refreshAvatar() {
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        // Reload likes when user logs in (userId changes) or when switching to Discover tab
        final currentUserId = authService.userId;
        
        // When user logs in (userId changes from null to a value, or different user logs in)
        // Reload likes if:
        // 1. User is logged in
        // 2. Different user than last loaded OR likes haven't been loaded yet
        // 3. We have users loaded OR we're on Discover tab (will load users)
        if (currentUserId != null && 
            _lastLoadedUserId != currentUserId && 
            !_isLoadingUsers) {
          print('User changed: $currentUserId (was: $_lastLoadedUserId)');
          // If on Discover tab and users are loaded, reload likes immediately
          if (_currentIndex == 3 && _allUsers.isNotEmpty) {
            print('Reloading likes immediately on Discover tab');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final userIds = _allUsers.map((u) => u['id'] != null ? int.tryParse(u['id'].toString()) : null).whereType<int>().toList();
              if (userIds.isNotEmpty) {
                _loadLikesData(userIds);
                _lastLoadedUserId = currentUserId;
              }
            });
          } else if (_currentIndex != 3) {
            // If not on Discover tab, mark that we need to reload likes when we switch to it
            // Just update the last loaded user ID to null so it reloads when switching tabs
            print('Not on Discover tab, will reload when switching to it');
            _lastLoadedUserId = null;
          }
        }
        
        // When user logs out (userId becomes null)
        if (currentUserId == null && _lastLoadedUserId != null) {
          print('User logged out, clearing likes data');
          _likedUserIds.clear();
          _likeCounts.clear();
          _lastLoadedUserId = null;
        }
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _currentIndex == 4 ? null : AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: LivDecorations.mainAppBackground,
        ),
        title: Row(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = 4; // Switch to profile tab
                  });
                },
                child: Consumer<UserService>(
                  builder: (context, userService, child) {
                    // First check if user has a selected avatar from UserService
                    if (userService.selectedAvatar != null && File(userService.selectedAvatar!).existsSync()) {
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: LivTheme.glassmorphicLightBorder, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundImage: FileImage(File(userService.selectedAvatar!)),
                          onBackgroundImageError: (exception, stackTrace) {
                            // Handle error if needed
                          },
                        ),
                      );
                    }
                    
                    // Then check Ready Player Me avatars
                    return FutureBuilder<String?>(
                      future: AvatarService.getAvatarImagePath(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null && File(snapshot.data!).existsSync()) {
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: LivTheme.glassmorphicLightBorder, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundImage: FileImage(File(snapshot.data!)),
                              onBackgroundImageError: (exception, stackTrace) {
                                // Handle error if needed
                              },
                            ),
                          );
                        } else {
                          // Fallback to simple grey person icon placeholder
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: LivTheme.glassmorphicLightBorder, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.grey[300],
                              child: Icon(
                                Icons.person,
                                size: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'LIV',
                style: LivTheme.getBlackTitle(context).copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 1,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () {
                Provider.of<AuthService>(context, listen: false).signOut();
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: LivDecorations.mainAppBackground,
        child: SafeArea(
          child: _buildBody(),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Refresh users list when switching to Discover tab (index 3)
          if (index == 3) {
            // Always reload users and likes when switching to Discover tab
            // This ensures likes are fresh after login
            _loadAllUsers(); // This will also load likes via _loadLikesData
          }
        },
      ),
        );
      },
    );
  }
  
  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildMatchesContent();
      case 2:
        return _buildMessagesContent();
      case 3:
        return _buildFeedContent();
      case 4:
        return ProfileScreen(
          onBackPressed: () {
            setState(() {
              _currentIndex = 0; // Switch to home tab
            });
          },
        );
      default:
        return _buildHomeContent();
    }
  }
  
  Widget _buildHomeContent() {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isVerySmallScreen = screenSize.height < 700;
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16.0 : 24.0,
          vertical: isVerySmallScreen ? 8.0 : 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: LivDecorations.glassmorphicCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer<UserService>(
                    builder: (context, userService, child) {
                      return Text(
                        'Welcome back, ${userService.displayName}! 👋',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 24 : 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C2C2C),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connect with friends and build meaningful relationships',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Stats Cards
            _buildStatsSection(isSmallScreen),
            
            const SizedBox(height: 24),
            
            // Navigation Grid
            _buildNavigationSection(isSmallScreen),
            
            const SizedBox(height: 24),
            
            // Quick Action Button
            _buildQuickActionButton(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatsSection(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Social Data',
          style: LivTheme.getBlackTitle(context).copyWith(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard('Friends', '12', const Color(0xFFE91E63)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard('Messages', '24', const Color(0xFF9C27B0)),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildNavigationSection(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: LivTheme.getBlackTitle(context).copyWith(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // Quick Actions Grid - 2 cards in first row, 1 centered in second row
        Column(
          children: [
            // First row with 2 cards
            Row(
              children: [
                Expanded(
                  child: _buildNavigationCard(
                    'AI Coach',
                    'Get personalized advice',
                    Icons.psychology,
                    const Color(0xFFE91E63),
                    () => _navigateToScreen(context, const CoachScreen()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNavigationCard(
                    'Feed',
                    'Discover new friends',
                    Icons.explore,
                    const Color(0xFF9C27B0),
                    () => _navigateToScreen(context, const FeedScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Second row with centered feedback card
            Center(
              child: SizedBox(
                width: (MediaQuery.of(context).size.width - 48) / 2, // Half width minus padding
                child: _buildNavigationCard(
                  'Feedback',
                  'Share your thoughts',
                  Icons.feedback,
                  const Color(0xFF3F51B5),
                  () => _navigateToScreen(context, const FeedbackScreen()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildQuickActionButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: LivDecorations.buttonGradientDecoration,
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Finding friends for you...'),
              backgroundColor: Color(0xFFE91E63),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(Icons.flash_on, color: Color(0xFF1565C0)),
        label: Text(
          'Find Friends Now',
          style: LivTheme.getBlackButton(context).copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
  
  Widget _buildMatchesContent() {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16.0 : 24.0,
          vertical: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Your Friends',
              style: LivTheme.getBlackTitle(context).copyWith(
                fontSize: isSmallScreen ? 24 : 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return _buildMatchCard(index);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMessagesContent() {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16.0 : 24.0,
          vertical: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Messages',
              style: LivTheme.getBlackTitle(context).copyWith(
                fontSize: isSmallScreen ? 24 : 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 8,
              itemBuilder: (context, index) {
                return _buildMessageCard(index);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedContent() {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
    return LayoutBuilder(
      builder: (context, constraints) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16.0 : 24.0,
          vertical: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
            Text(
              'Discover People',
              style: LivTheme.getBlackTitle(context).copyWith(
                fontSize: isSmallScreen ? 24 : 28,
                fontWeight: FontWeight.bold,
              ),
                      ),
                      IconButton(
                        onPressed: () {
                          _loadAllUsers();
                        },
                        icon: _isLoadingUsers
                            ? SizedBox(
                                width: isSmallScreen ? 20 : 24,
                                height: isSmallScreen ? 20 : 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Icon(
                                Icons.refresh,
                                color: Colors.white,
                                size: isSmallScreen ? 20 : 24,
                              ),
                        tooltip: 'Refresh',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ],
            ),
            const SizedBox(height: 20),
                  if (_isLoadingUsers)
                    SizedBox(
                      height: constraints.maxHeight.isFinite 
                          ? constraints.maxHeight - 200 
                          : MediaQuery.of(context).size.height - 300,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                    )
                  else if (_allUsers.isEmpty)
                    SizedBox(
                      height: constraints.maxHeight.isFinite 
                          ? constraints.maxHeight - 200 
                          : MediaQuery.of(context).size.height - 300,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.white.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No users found',
                                style: LivTheme.getBlackBody(context),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () {
                                  _loadAllUsers();
                                },
                                icon: const Icon(Icons.refresh, color: Colors.white70),
                                label: const Text(
                                  'Refresh',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: _allUsers.map((user) => _buildFeedCard(user)).toList(),
            ),
            const SizedBox(height: 20),
          ],
              ),
        ),
      ),
        );
      },
    );
  }
  
  Widget _buildProfileContent() {
    return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
            // Profile Header
              Consumer<UserService>(
                builder: (context, userService, child) {
                return GestureDetector(
                        onTap: () => _navigateToScreen(context, const EditProfileScreen()),
                        child: Stack(
                          children: [
                            // First check if user has a selected avatar
                            userService.selectedAvatar != null && File(userService.selectedAvatar!).existsSync()
                                ? CircleAvatar(
                              radius: 60,
                                    backgroundImage: FileImage(File(userService.selectedAvatar!)),
                              onBackgroundImageError: (exception, stackTrace) {
                                // Handle error if needed
                              },
                                  )
                                : FutureBuilder<String?>(
                                    future: AvatarService.getAvatarImagePath(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData && snapshot.data != null && File(snapshot.data!).existsSync()) {
                                        return CircleAvatar(
                                          radius: 60,
                                          backgroundImage: FileImage(File(snapshot.data!)),
                                          onBackgroundImageError: (exception, stackTrace) {
                                            // Handle error if needed
                                          },
                                        );
                                      } else {
                                        // Show simple grey person icon placeholder
                                        return CircleAvatar(
                                          radius: 60,
                                          backgroundColor: Colors.grey[300],
                                          child: Icon(
                                            Icons.person,
                                            size: 60,
                                            color: Colors.grey[600],
                                          ),
                                        );
                                      }
                              },
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
          child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
              shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Color(0xFF667eea),
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                );
              },
                      ),
                      const SizedBox(height: 16),
                      
            // Profile Info - Get from database only
            Consumer<AuthService>(
              builder: (context, authService, child) {
                final userData = authService.userData;
                final displayName = userData?['full_name']?.toString().trim() ?? '';
                final ageValue = userData?['age'] != null 
                    ? int.tryParse(userData!['age'].toString())
                    : null;
                final location = userData?['location']?.toString().trim() ?? '';
                
                return Column(
                  children: [
                      Text(
                      displayName.isNotEmpty ? displayName : 'Profile',
                        style: LivTheme.getBlackTitle(context).copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (ageValue != null)
                      Text(
                        '$ageValue years old',
                        style: LivTheme.getBlackBodySecondary(context).copyWith(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                    if (location.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: LivTheme.glassmorphicLightBorder,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            location,
                            style: LivTheme.getBlackBodySecondary(context).copyWith(
                              fontSize: 14,
                            ),
                ),
              ],
                    ),
                  ],
                );
              },
            ),
                      const SizedBox(height: 16),
                      
            // About Section - Get from database only
                      Consumer<AuthService>(
                        builder: (context, authService, child) {
                          final userData = authService.userData;
                          final bio = userData?['bio']?.toString().trim() ?? '';
                          
                          return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: LivDecorations.glassmorphicLightCard,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About Me',
          style: LivTheme.getBlackSubtitle(context),
        ),
                            const SizedBox(height: 8),
                                Text(
                                  bio.isNotEmpty ? bio : 'No bio available',
                        style: LivTheme.getBlackBodySecondary(context).copyWith(
                          height: 1.4,
                        ),
                            ),
                          ],
                        ),
                          );
                        },
        ),
              const SizedBox(height: 24),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _navigateToScreen(context, const EditProfileScreen());
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LivTheme.glassmorphicLightBackground,
                        foregroundColor: LivTheme.accentBlue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showMessageDialog(context);
                      },
                      icon: const Icon(Icons.message),
                      label: const Text('Message'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LivTheme.accentBlue,
                        foregroundColor: LivTheme.glassmorphicLightBorder,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
        ),
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LivTheme.glassmorphicBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: LivTheme.glassmorphicBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: LivTheme.getBlackTitle(context).copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isSmallScreen = screenWidth < 600;
    
    // Very conservative scaling to prevent overflow
    final scaleFactor = isSmallScreen ? 0.7 : (screenWidth / 600).clamp(0.7, 1.0);
    
    final cardPadding = isSmallScreen ? 10.0 : 12.0; 
    final iconSize = isSmallScreen ? 20.0 : 24.0; 
    final iconPadding = isSmallScreen ? 6.0 : 8.0; 
    final titleFontSize = isSmallScreen ? 14.0 : 16.0; 
    final subtitleFontSize = isSmallScreen ? 11.0 : 12.0; 
    final spacing = isSmallScreen ? 6.0 : 8.0;
    final borderRadius = isSmallScreen ? 12.0 : 16.0;
    final iconBorderRadius = isSmallScreen ? 6.0 : 8.0;
    
    return Builder(
      builder: (context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: LivTheme.glassmorphicBackground,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: LivTheme.glassmorphicBorder,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(iconPadding),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.3),
                    color.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(iconBorderRadius),
                border: Border.all(
                  color: color.withOpacity(0.4),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 12 * scaleFactor,
                    offset: Offset(0, 6 * scaleFactor),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: color,
              ),
            ),
            SizedBox(height: spacing),
            Text(
              title,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4 * scaleFactor),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: subtitleFontSize,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
    ),
    );
  }
  
  Widget _buildMatchCard(int index) {
    final avatars = [
      'assets/avatars/Gemini_Generated_Image_1x9rce1x9rce1x9r.png',
      'assets/avatars/Gemini_Generated_Image_4echfc4echfc4ech.png',
      'assets/avatars/Gemini_Generated_Image_8h3zz58h3zz58h3z.png',
      'assets/avatars/Gemini_Generated_Image_9btvl39btvl39btv.png',
      'assets/avatars/Gemini_Generated_Image_9tb20o9tb20o9tb2.png',
    ];
    
    final names = ['Sarah', 'Emma', 'Jessica', 'Amanda', 'Lisa'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: LivDecorations.glassmorphicCard,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: LivTheme.primaryPink, width: 2),
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(avatars[index % avatars.length]),
              onBackgroundImageError: (exception, stackTrace) {
                // Handle error if needed
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  names[index % names.length],
                  style: LivTheme.getBlackTitle(context).copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: LivTheme.textBlack54,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'New York, NY',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [LivTheme.primaryPink.withOpacity(0.8), LivTheme.primaryPink],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: LivTheme.primaryPink.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: const Size(0, 36),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                          ),
                          onPressed: () {
                            _showMessageDialog(context);
                          },
                          icon: const Icon(Icons.chat, color: Colors.white, size: 14),
                          label: const Text(
                            'Chat',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: LivTheme.mainAppGradient,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: const Size(0, 36),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Like feature coming soon!'),
                                backgroundColor: Color(0xFF9C27B0),
                              ),
                            );
                          },
                          icon: const Icon(Icons.favorite, color: Colors.white, size: 14),
                          label: const Text(
                            'Like',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMessageCard(int index) {
    final avatars = [
      'assets/avatars/Gemini_Generated_Image_1x9rce1x9rce1x9r.png',
      'assets/avatars/Gemini_Generated_Image_4echfc4echfc4ech.png',
      'assets/avatars/Gemini_Generated_Image_8h3zz58h3zz58h3z.png',
      'assets/avatars/Gemini_Generated_Image_9btvl39btvl39btv.png',
      'assets/avatars/Gemini_Generated_Image_9tb20o9tb20o9tb2.png',
    ];
    
    final names = ['Sarah', 'Emma', 'Jessica', 'Amanda', 'Lisa', 'Rachel', 'Megan', 'Ashley'];
    final messages = ['Hey! How are you?', 'Thanks for the message!', 'Let\'s meet up soon', 'I had a great time', 'What are you up to?', 'Good morning!', 'See you later', 'Have a great day!'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LivTheme.glassmorphicBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: LivTheme.glassmorphicBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage(avatars[index % avatars.length]),
            onBackgroundImageError: (exception, stackTrace) {
              // Handle error if needed
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  names[index % names.length],
                  style: LivTheme.getBlackTitle(context).copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  messages[index % messages.length],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [LivTheme.primaryPink.withOpacity(0.8), LivTheme.primaryPink],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: LivTheme.primaryPink.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              '2m',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get or create avatar future for a user (cached)
  Future<String?> _getUserAvatarFuture(int userId) {
    if (!_avatarFutures.containsKey(userId)) {
      _avatarFutures[userId] = _loadUserAvatar(userId);
    }
    return _avatarFutures[userId]!;
  }

  /// Load like counts and liked status for users
  Future<void> _loadLikesData(List<int> userIds) async {
    if (userIds.isEmpty) return;
    
    final authService = AuthService.instance;
    final currentUserId = authService.userId;
    if (currentUserId == null) return;
    
    print('Loading likes data for user $currentUserId, checking ${userIds.length} users');
    
    try {
      // Get like counts for all users
      final likesResponse = await http.post(
        Uri.parse('${AppPaths.apiBaseUrl}/get_likes_count.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_ids': userIds}),
      );
      
      if (likesResponse.statusCode == 200) {
        final likesData = json.decode(likesResponse.body);
        print('Likes count response: $likesData');
        if (likesData['success'] == true && likesData['likes'] != null) {
          final likes = Map<String, dynamic>.from(likesData['likes']);
          _likeCounts.clear();
          for (final entry in likes.entries) {
            final userId = int.tryParse(entry.key.toString());
            if (userId != null) {
              _likeCounts[userId] = int.tryParse(entry.value.toString()) ?? 0;
            }
          }
          print('Loaded like counts: $_likeCounts');
        }
      }
      
      // Check which users the current user has liked
      final likedResponse = await http.post(
        Uri.parse('${AppPaths.apiBaseUrl}/check_user_liked.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': currentUserId,
          'liked_user_ids': userIds,
        }),
      );
      
      if (likedResponse.statusCode == 200) {
        final likedData = json.decode(likedResponse.body);
        print('Liked users response: $likedData');
        if (likedData['success'] == true && likedData['liked_user_ids'] != null) {
          final likedIds = List.from(likedData['liked_user_ids'])
              .map((id) => int.tryParse(id.toString()))
              .whereType<int>()
              .toList();
          _likedUserIds.clear();
          _likedUserIds.addAll(likedIds);
          print('Loaded liked user IDs: $_likedUserIds');
        }
      } else {
        print('Error getting liked users: ${likedResponse.statusCode}');
      }
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error loading likes data: $e');
    }
  }

  /// Toggle like for a user
  Future<void> _toggleLike(int likedUserId) async {
    final authService = AuthService.instance;
    final currentUserId = authService.userId;
    if (currentUserId == null) {
      LivPopupMessage.showError(context, 'Please log in to like users');
      return;
    }
    
    if (currentUserId == likedUserId) {
      LivPopupMessage.showError(context, 'Cannot like yourself');
      return;
    }
    
    try {
      final response = await http.post(
        Uri.parse('${AppPaths.apiBaseUrl}/toggle_like.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': currentUserId,
          'liked_user_id': likedUserId,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final isLiked = data['liked'] == true;
          final likeCount = int.tryParse(data['like_count'].toString()) ?? 0;
          
          setState(() {
            if (isLiked) {
              _likedUserIds.add(likedUserId);
            } else {
              _likedUserIds.remove(likedUserId);
            }
            _likeCounts[likedUserId] = likeCount;
          });
        } else {
          LivPopupMessage.showError(context, data['error'] ?? 'Failed to like user');
        }
      } else {
        LivPopupMessage.showError(context, 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      LivPopupMessage.showError(context, 'Error: ${e.toString()}');
    }
  }

  /// Load avatar for a specific user
  Future<String?> _loadUserAvatar(int userId) async {
    try {
      final userUploadsDir = Directory('${AppPaths.windowsUploadsBase}\\user_$userId');
      
      if (!userUploadsDir.existsSync()) {
        return null;
      }
      
      final prefs = await SharedPreferences.getInstance();
      
      // First check SharedPreferences for selected avatar (gallery image)
      final selectedGalleryAvatar = prefs.getString('user_${userId}_selectedGalleryAvatar');
      if (selectedGalleryAvatar != null && File(selectedGalleryAvatar).existsSync()) {
        return selectedGalleryAvatar;
      }
      
      // Check for last avatar PNG path
      final lastAvatarPngPath = prefs.getString('user_${userId}_lastAvatarPngPath');
      if (lastAvatarPngPath != null && File(lastAvatarPngPath).existsSync()) {
        return lastAvatarPngPath;
      }
      
      // Fallback: Get all PNG files from user directory and find the most recent one
      final pngFiles = userUploadsDir
          .listSync()
          .where((file) => file is File && file.path.toLowerCase().endsWith('.png'))
          .cast<File>()
          .toList();
      
      if (pngFiles.isEmpty) {
        return null;
      }
      
      // Sort by modification time (most recent first)
      pngFiles.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      return pngFiles.first.path;
    } catch (e) {
      // Silently handle errors
      return null;
    }
  }

  Widget _buildFeedCard(Map<String, dynamic> user) {
    final userId = user['id'];
    final userIdInt = userId != null ? int.tryParse(userId.toString()) : null;
    final fullName = user['full_name']?.toString() ?? 'User';
    final age = user['age'] != null ? int.tryParse(user['age'].toString()) ?? 0 : 0;
    final location = user['location']?.toString() ?? '';
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showUserProfile(context, user),
        child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: LivDecorations.glassmorphicCard,
      child: Row(
        children: [
          // Avatar - Load asynchronously using FutureBuilder (with cached future)
          FutureBuilder<String?>(
            key: ValueKey('avatar_$userIdInt'),
            future: userIdInt != null ? _getUserAvatarFuture(userIdInt) : Future.value(null),
            builder: (context, snapshot) {
              final avatarPath = snapshot.data;
              if (avatarPath != null && File(avatarPath).existsSync()) {
                return CircleAvatar(
            radius: 35,
                  backgroundImage: FileImage(File(avatarPath)),
            onBackgroundImageError: (exception, stackTrace) {
                    // Silently handle error - will show placeholder on next rebuild
                  },
                  child: null,
                );
              }
              // Placeholder
              return CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey[300],
                child: Icon(
                  Icons.person,
                  size: 35,
                  color: Colors.grey[600],
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: LivTheme.getBlackTitle(context).copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$age years old',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                if (location.isNotEmpty)
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: LivTheme.textBlack54,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                          location,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                  ],
                ),
                // Like count display
                if (_likeCounts.containsKey(userIdInt) && _likeCounts[userIdInt]! > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12, top: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 14,
                          color: LivTheme.primaryPink,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_likeCounts[userIdInt]} ${_likeCounts[userIdInt] == 1 ? 'like' : 'likes'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: LivTheme.mainAppGradient,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: const Size(0, 36),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                          ),
                          onPressed: () {
                            if (userIdInt != null) {
                              _toggleLike(userIdInt);
                            }
                          },
                          icon: Icon(
                            _likedUserIds.contains(userIdInt) ? Icons.favorite : Icons.favorite_border,
                            size: 14,
                            color: Colors.white,
                          ),
                          label: Text(
                            _likedUserIds.contains(userIdInt) ? 'Liked' : 'Like',
                            style: LivTheme.getBlackButton(context).copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [LivTheme.primaryPink.withOpacity(0.8), LivTheme.primaryPink],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: LivTheme.primaryPink.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: const Size(0, 36),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Message feature coming soon!'),
                                backgroundColor: Color(0xFF9C27B0),
                              ),
                            );
                          },
                          icon: const Icon(Icons.message, size: 14, color: Colors.white),
                          label: const Text(
                            'Message',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      ),
      ),
    );
  }

  /// Show user profile details dialog
  Future<void> _showUserProfile(BuildContext context, Map<String, dynamic> user) async {
    final userId = user['id'];
    final userIdInt = userId != null ? int.tryParse(userId.toString()) : null;
    
    // Fetch full user data including bio from database
    Map<String, dynamic> fullUserData = Map<String, dynamic>.from(user);
    
    if (userIdInt != null) {
      try {
        final response = await http.post(
          Uri.parse('${AppPaths.apiBaseUrl}/get_user_by_id.php'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'user_id': userIdInt}),
        );
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true && data['user'] != null) {
            fullUserData = Map<String, dynamic>.from(data['user']);
          }
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
    
    // Get user avatar
    String? avatarPath;
    int likeCount = 0;
    if (userIdInt != null) {
      try {
        avatarPath = await _getUserAvatarFuture(userIdInt);
        if (avatarPath != null && !File(avatarPath).existsSync()) {
          avatarPath = null;
        }
        
        // Get like count for this user
        final likesResponse = await http.post(
          Uri.parse('${AppPaths.apiBaseUrl}/get_likes_count.php'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'user_ids': [userIdInt]}),
        );
        
        if (likesResponse.statusCode == 200) {
          final likesData = json.decode(likesResponse.body);
          if (likesData['success'] == true && likesData['likes'] != null) {
            likeCount = int.tryParse(likesData['likes'][userIdInt.toString()].toString()) ?? 0;
          }
        }
      } catch (e) {
        print('Error loading avatar: $e');
      }
    }
    
    // Show dialog
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.95),
                Colors.white.withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: LivTheme.primaryPink.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: LivTheme.primaryPink.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 0,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                // Avatar
                CircleAvatar(
                  radius: 60,
                  backgroundColor: LivTheme.glassmorphicLightBorder,
                  backgroundImage: avatarPath != null
                      ? FileImage(File(avatarPath))
                      : null,
                  child: avatarPath == null
                      ? Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey[600],
                        )
                      : null,
                ),
                const SizedBox(height: 20),
                // Full Name
                Text(
                  fullUserData['full_name']?.toString() ?? 'User',
                  style: LivTheme.getBlackTitle(context).copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Age and Gender
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (fullUserData['age'] != null)
                      Text(
                        '${fullUserData['age']} years old',
                        style: const TextStyle(
                          fontSize: 16,
                          color: LivTheme.textPrimary,
                        ),
                      ),
                    if (fullUserData['age'] != null && fullUserData['gender'] != null)
                      const Text(
                        ' • ',
                        style: TextStyle(
                          fontSize: 16,
                          color: LivTheme.textPrimary,
                        ),
                      ),
                    if (fullUserData['gender'] != null)
                      Text(
                        fullUserData['gender'].toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: LivTheme.textPrimary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Like Count
                if (likeCount > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite,
                        color: LivTheme.primaryPink,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$likeCount ${likeCount == 1 ? 'like' : 'likes'}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: LivTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                if (likeCount > 0) const SizedBox(height: 12),
                // Location
                if (fullUserData['location'] != null && fullUserData['location'].toString().isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: LivTheme.primaryPink,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        fullUserData['location'].toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: LivTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
                // About section (bio from local preferences - may be empty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: LivDecorations.glassmorphicLightCard,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        fullUserData['bio']?.toString().trim() ?? 'No bio available',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.75),
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
                ),
              ),
              // Close button in top right corner
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.black87,
                    size: 24,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.8),
                    padding: const EdgeInsets.all(8),
                    shape: const CircleBorder(),
                  ),
                  tooltip: 'Close',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _showMessageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Contact Options'),
          content: const Text('Choose how you want to contact this user:'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showCallDialog(context);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Call'),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showMessageDialog(context);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.message, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Message'),
                ],
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showCallDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
              Icon(Icons.phone, color: Colors.green),
              SizedBox(width: 8),
              Text('Calling...'),
            ],
          ),
          content: const Text('Connecting to user...\n\nThis is a demo. In a real app, this would initiate a phone call.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('End Call'),
            ),
          ],
        );
      },
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Settings'),
          content: const Text('Settings feature coming soon!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
