import 'package:flutter/material.dart';
import '../services/ai_coach_service.dart';
import '../services/health_service.dart';
import '../widgets/typing_text.dart';
import '../theme/liv_theme.dart';

class CoachScreen extends StatefulWidget {
  const CoachScreen({super.key});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _coachController;
  late Animation<Color?> _backgroundTint;
  late Animation<double> _coachScale;
  
  String _coachAdvice = '';
  bool _isLoading = true;
  List<String> _quickTips = [];
  String _motivationalQuote = '';
  
  @override
  void initState() {
    super.initState();
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _coachController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _backgroundTint = ColorTween(
      begin: const Color(0xFF667eea),
      end: const Color(0xFF764ba2),
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));
    
    _coachScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _coachController,
      curve: Curves.elasticOut,
    ));
    
    _backgroundController.repeat(reverse: true);
    _loadCoachData();
  }
  
  @override
  void dispose() {
    _backgroundController.dispose();
    _coachController.dispose();
    super.dispose();
  }
  
  Future<void> _loadCoachData() async {
    try {
      // Load health data
      final healthData = await HealthService.instance.getTodayHealthData();
      
      // Get AI coach advice
      final advice = await AICoachService.instance.getCoachAdvice(healthData);
      
      // Get quick tips
      final tips = await AICoachService.instance.getQuickTips();
      
      // Get motivational quote
      final quote = await AICoachService.instance.getMotivationalQuote();
      
      setState(() {
        _coachAdvice = advice;
        _quickTips = tips;
        _motivationalQuote = quote;
        _isLoading = false;
      });
      
      // Start coach animation
      _coachController.forward();
    } catch (e) {
      print('Error loading coach data: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Header
                    _buildHeader(),
                    
                    const SizedBox(height: 32),
                    
                    // Coach Avatar
                    _buildCoachAvatar(),
                    
                    const SizedBox(height: 32),
                    
                    // Coach Advice
                    _buildCoachAdvice(),
                    
                    const SizedBox(height: 32),
                    
                    // Quick Tips
                    _buildQuickTips(),
                    
                    const SizedBox(height: 32),
                    
                    // Motivational Quote
                    _buildMotivationalQuote(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        const Text(
          'AI Coach',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: _loadCoachData,
          icon: const Icon(Icons.refresh, color: Colors.white),
        ),
      ],
    );
  }
  
  Widget _buildCoachAvatar() {
    return AnimatedBuilder(
      animation: _coachScale,
      builder: (context, child) {
        return Transform.scale(
          scale: _coachScale.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.psychology,
              size: 60,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildCoachAdvice() {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Personal Advice',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          TypingText(
            _coachAdvice,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
            duration: const Duration(milliseconds: 30),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickTips() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Tips',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ..._quickTips.take(3).map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tip,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
  
  Widget _buildMotivationalQuote() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.format_quote,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            _motivationalQuote,
            style: const TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.white,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
