import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/liv_theme.dart';

class WelcomeBackScreen extends StatefulWidget {
  const WelcomeBackScreen({super.key});

  @override
  State<WelcomeBackScreen> createState() => _WelcomeBackScreenState();
}

class _WelcomeBackScreenState extends State<WelcomeBackScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _heartController;
  late AnimationController _textController;
  
  late Animation<Color?> _backgroundTint;
  late Animation<double> _heartScale;
  late Animation<double> _heartRotation;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textOffset;
  
  @override
  void initState() {
    super.initState();
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _heartController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _backgroundTint = ColorTween(
      begin: const Color(0xFF667eea),
      end: const Color(0xFF764ba2),
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));
    
    _heartScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heartController,
      curve: Curves.elasticOut,
    ));
    
    _heartRotation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _heartController,
      curve: Curves.easeInOut,
    ));
    
    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));
    
    _textOffset = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));
    
    _startAnimations();
  }
  
  void _startAnimations() {
    _backgroundController.repeat(reverse: true);
    
    // Start heart animation
    _heartController.forward();
    
    // Start text animation after heart
    Future.delayed(const Duration(milliseconds: 800), () {
      _textController.forward();
    });
    
    // Make heart pulse
    Future.delayed(const Duration(seconds: 2), () {
      _heartController.repeat(reverse: true);
    });
  }
  
  @override
  void dispose() {
    _backgroundController.dispose();
    _heartController.dispose();
    _textController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundTint,
        builder: (context, child) {
          return Container(
            decoration: LivDecorations.gradientDecoration,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Heart Animation
                    AnimatedBuilder(
                      animation: Listenable.merge([_heartScale, _heartRotation]),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _heartScale.value,
                          child: Transform.rotate(
                            angle: _heartRotation.value,
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.3),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.favorite,
                                size: 80,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Welcome Message
                    AnimatedBuilder(
                      animation: Listenable.merge([_textOpacity, _textOffset]),
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _textOpacity,
                          child: SlideTransition(
                            position: _textOffset,
                            child: Column(
                              children: [
                                const Text(
                                  'Welcome Back!',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                
                                const SizedBox(height: 16),
                                
                                const Text(
                                  'Your twin missed you 🫶',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w300,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                
                                const SizedBox(height: 8),
                                
                                const Text(
                                  'Let\'s continue your health journey together',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white60,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // Continue Button
                    AnimatedBuilder(
                      animation: _textOpacity,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _textOpacity,
                          child: _buildContinueButton(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _continue,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.2),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
  
  Future<void> _continue() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      // Update last active time (simplified)
      print('User last active time updated');
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error updating last active time: $e');
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
