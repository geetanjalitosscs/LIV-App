import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/theme_service.dart';
import '../services/avatar_service.dart';
import '../theme/liv_theme.dart';
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
  
  @override
  void initState() {
    super.initState();
    // Refresh avatar when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh avatar when returning to this screen
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
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
                child: FutureBuilder<String?>(
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
                      // Fallback to default avatar
                      return Consumer<UserService>(
                        builder: (context, userService, child) {
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: LivTheme.glassmorphicLightBorder, width: 2),
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
                      );
                    }
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
              style: LivTheme.getBlackTitle(context).copyWith(
                fontSize: isSmallScreen ? 24 : 28,
                fontWeight: FontWeight.bold,
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
                        onTap: () => _navigateToScreen(context, const EditProfileScreen()),
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
                        style: LivTheme.getBlackTitle(context).copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${userService.age} years old',
                        style: LivTheme.getBlackBodySecondary(context).copyWith(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const                           Icon(
                            Icons.location_on,
                            color: LivTheme.glassmorphicLightBorder,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            userService.location,
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
                      
            // About Section
                      Container(
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
                  Consumer<UserService>(
                    builder: (context, userService, child) {
                      return Text(
                              userService.bio,
                        style: LivTheme.getBlackBodySecondary(context).copyWith(
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
    
    return MouseRegion(
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
                ),
                const SizedBox(height: 4),
                Text(
                  'New York, NY',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
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
                          onPressed: () {
                            _showMessageDialog(context);
                          },
                          icon: const Icon(Icons.chat, color: Colors.white, size: 16),
                          label: const Text(
                            'Chat',
                            style: TextStyle(
                              color: Colors.white,
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
                          gradient: LivTheme.mainAppGradient,
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
                          icon: const Icon(Icons.favorite, color: Colors.white, size: 16),
                          label: const Text(
                            'Like',
                            style: TextStyle(
                              color: Colors.white,
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
      decoration: LivDecorations.glassmorphicCard,
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
                  style: LivTheme.getBlackTitle(context).copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${ages[index % ages.length]} years old',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
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
                    Text(
                      locations[index % locations.length],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
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
                          gradient: LivTheme.mainAppGradient,
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
                          label: Text(
                            'Like',
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
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Message feature coming soon!'),
                                backgroundColor: Color(0xFF9C27B0),
                              ),
                            );
                          },
                          icon: const Icon(Icons.message, size: 16, color: Colors.white),
                          label: const Text(
                            'Message',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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
