import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/theme_service.dart';
import '../widgets/bottom_navigation.dart';
import 'coach_screen.dart';
import 'feed_screen.dart';
import 'avatar_setup_screen.dart';
import 'feedback_screen.dart';
import 'welcome_back_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _backgroundController;
  late Animation<double> _backgroundOpacity;
  
  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _backgroundOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));
    _backgroundController.forward();
  }
  
  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFE91E63).withOpacity(0.9),
                const Color(0xFF9C27B0).withOpacity(0.9),
              ],
            ),
          ),
        ),
        title: Row(
          children: [
            Consumer<UserService>(
              builder: (context, userService, child) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: AssetImage(userService.currentAvatar),
                    onBackgroundImageError: (exception, stackTrace) {
                      // Handle error if needed
                    },
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'LIV',
                style: TextStyle(
                  color: Colors.white,
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
          Consumer<ThemeService>(
            builder: (context, themeService, child) {
              return IconButton(
                icon: Icon(
                  themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: Colors.white,
                ),
                onPressed: () {
                  themeService.toggleTheme();
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).signOut();
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _backgroundOpacity,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFF8BBD9).withOpacity(_backgroundOpacity.value),
                  const Color(0xFFE1BEE7).withOpacity(_backgroundOpacity.value),
                  const Color(0xFFC5CAE9).withOpacity(_backgroundOpacity.value),
                  const Color(0xFFB39DDB).withOpacity(_backgroundOpacity.value),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: SafeArea(
              child: _buildBody(),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
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
        return const ProfileScreen();
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
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
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
                      color: const Color(0xFF666666),
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
          'Your Stats',
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard('Matches', '12', const Color(0xFFE91E63)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard('Messages', '24', const Color(0xFF9C27B0)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard('Profile Views', '156', const Color(0xFF673AB7)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard('Rating', '4.8', const Color(0xFF3F51B5)),
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
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: isSmallScreen ? 1.2 : 1.0,
          children: [
            _buildNavigationCard(
              'AI Coach',
              'Get personalized advice',
              Icons.psychology,
              const Color(0xFFE91E63),
              () => _navigateToScreen(context, const CoachScreen()),
            ),
            _buildNavigationCard(
              'Feed',
              'Discover new friends',
              Icons.explore,
              const Color(0xFF9C27B0),
              () => _navigateToScreen(context, const FeedScreen()),
            ),
            _buildNavigationCard(
              'Profile',
              'View your profile',
              Icons.person,
              const Color(0xFF673AB7),
              () => _navigateToScreen(context, const ProfileScreen()),
            ),
            _buildNavigationCard(
              'Feedback',
              'Share your thoughts',
              Icons.feedback,
              const Color(0xFF3F51B5),
              () => _navigateToScreen(context, const FeedbackScreen()),
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
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
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
        icon: const Icon(Icons.flash_on, color: Colors.white),
        label: const Text(
          'Find Friends Now',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
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
              'Your Matches',
              style: TextStyle(
                fontSize: isSmallScreen ? 24 : 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C2C2C),
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
              style: TextStyle(
                fontSize: isSmallScreen ? 24 : 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C2C2C),
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
              'Discover People',
              style: TextStyle(
                fontSize: isSmallScreen ? 24 : 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C2C2C),
              ),
            ),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 10,
              itemBuilder: (context, index) {
                return _buildFeedCard(index);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
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
                        onTap: () => _navigateToScreen(context, const AvatarSetupScreen()),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: AssetImage(userService.currentAvatar),
                              onBackgroundImageError: (exception, stackTrace) {
                                // Handle error if needed
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
                      
            // Profile Info
            Consumer<UserService>(
              builder: (context, userService, child) {
                return Column(
                  children: [
                      Text(
                        userService.displayName,
                        style: const TextStyle(
                        fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${userService.age} years old',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            userService.location,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                ),
              ],
                    ),
                  ],
                );
              },
            ),
                      const SizedBox(height: 16),
                      
            // About Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
                              'About Me',
          style: TextStyle(
                      fontSize: 18,
            fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
                            const SizedBox(height: 8),
                  Consumer<UserService>(
                    builder: (context, userService, child) {
                      return Text(
                              userService.bio,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                                height: 1.4,
                              ),
                      );
                    },
                            ),
                          ],
                        ),
        ),
              
              const SizedBox(height: 24),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _navigateToScreen(context, const AvatarSetupScreen());
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF667eea),
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
                        backgroundColor: const Color(0xFF667eea),
                        foregroundColor: Colors.white,
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
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
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
              color: Color(0xFF666666),
              fontWeight: FontWeight.w500,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C2C2C),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE91E63), width: 2),
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
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'New York, NY',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE91E63).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: TextButton.icon(
                          onPressed: () {
                            _showMessageDialog(context);
                          },
                          icon: const Icon(Icons.chat, color: Color(0xFFE91E63), size: 16),
                          label: const Text(
                            'Chat',
                            style: TextStyle(
                              color: Color(0xFFE91E63),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
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
                          color: const Color(0xFF9C27B0).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: TextButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Like feature coming soon!'),
                                backgroundColor: Color(0xFF9C27B0),
                              ),
                            );
                          },
                          icon: const Icon(Icons.favorite, color: Color(0xFF9C27B0), size: 16),
                          label: const Text(
                            'Like',
                            style: TextStyle(
                              color: Color(0xFF9C27B0),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
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
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  messages[index % messages.length],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
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
              color: const Color(0xFFE91E63).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '2m',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFE91E63),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedCard(int index) {
    final avatars = [
      'assets/avatars/Gemini_Generated_Image_1x9rce1x9rce1x9r.png',
      'assets/avatars/Gemini_Generated_Image_4echfc4echfc4ech.png',
      'assets/avatars/Gemini_Generated_Image_8h3zz58h3zz58h3z.png',
      'assets/avatars/Gemini_Generated_Image_9btvl39btvl39btv.png',
      'assets/avatars/Gemini_Generated_Image_9tb20o9tb20o9tb2.png',
    ];
    
    final names = ['Sarah', 'Emma', 'Jessica', 'Amanda', 'Lisa', 'Rachel', 'Megan', 'Ashley', 'Nicole', 'Stephanie'];
    final ages = [25, 28, 23, 30, 26, 27, 24, 29, 31, 22];
    final locations = ['New York, NY', 'Los Angeles, CA', 'Chicago, IL', 'Miami, FL', 'Seattle, WA', 'Boston, MA', 'Denver, CO', 'Austin, TX', 'Portland, OR', 'Nashville, TN'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
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
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${ages[index % ages.length]} years old',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFF666666),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      locations[index % locations.length],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
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
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: TextButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Like feature coming soon!'),
                                backgroundColor: Color(0xFFE91E63),
                              ),
                            );
                          },
                          icon: const Icon(Icons.favorite, size: 16, color: Colors.white),
                          label: const Text(
                            'Like',
                            style: TextStyle(
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
                          color: const Color(0xFFE91E63).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: TextButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Message feature coming soon!'),
                                backgroundColor: Color(0xFF9C27B0),
                              ),
                            );
                          },
                          icon: const Icon(Icons.message, size: 16, color: Color(0xFFE91E63)),
                          label: const Text(
                            'Message',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFE91E63),
                            ),
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
