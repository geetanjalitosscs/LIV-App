// AI Coach Service - Simple implementation without external dependencies

class AICoachService {
  static final AICoachService _instance = AICoachService._internal();
  static AICoachService get instance => _instance;
  
  AICoachService._internal();
  
  Future<String> getCoachAdvice(Map<String, dynamic> healthData) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      return _generateAdvice(healthData);
    } catch (e) {
      print('Error getting coach advice: $e');
      return _getDefaultAdvice();
    }
  }
  
  String _generateAdvice(Map<String, dynamic> healthData) {
    final steps = healthData['steps'] ?? 0;
    final sleepHours = healthData['sleepHours'] ?? 0.0;
    final caloriesBurned = healthData['caloriesBurned'] ?? 0.0;
    final heartRate = healthData['averageHeartRate'] ?? 0.0;
    
    // Rule-based advice system
    final List<String> advice = [];
    
    // Steps advice
    if (steps < 5000) {
      advice.add("You're off to a slow start today! Try taking a 10-minute walk to get your steps up. Every step counts towards a healthier you! 🚶‍♀️");
    } else if (steps < 10000) {
      advice.add("Great progress on your steps! You're halfway to your daily goal. Keep up the momentum! 💪");
    } else {
      advice.add("Amazing work! You've hit your step goal and then some. Your body will thank you for this active day! 🎉");
    }
    
    // Sleep advice
    if (sleepHours < 6) {
      advice.add("Your sleep was quite short last night. Try to wind down earlier tonight - your body needs 7-9 hours to fully recover. 😴");
    } else if (sleepHours < 8) {
      advice.add("Good sleep duration! You're close to the recommended 7-9 hours. A little more rest would be perfect for optimal recovery. 🌙");
    } else {
      advice.add("Excellent sleep! You gave your body the rest it deserves. This quality sleep will fuel your energy throughout the day! ✨");
    }
    
    // Calories advice
    if (caloriesBurned < 200) {
      advice.add("Let's get your metabolism fired up! Try some light exercise or a brisk walk to burn more calories today. 🔥");
    } else if (caloriesBurned < 400) {
      advice.add("Nice calorie burn! You're building a healthy habit. Consider adding some strength training to boost your metabolism further! 💪");
    } else {
      advice.add("Outstanding calorie burn! You're really putting in the work. Remember to fuel your body with nutritious foods to support this activity! 🥗");
    }
    
    // Heart rate advice
    if (heartRate > 0) {
      if (heartRate < 60) {
        advice.add("Your resting heart rate is quite low - this could indicate excellent cardiovascular fitness! Keep up your healthy lifestyle! ❤️");
      } else if (heartRate > 100) {
        advice.add("Your heart rate seems elevated. Consider some deep breathing exercises or light stretching to help your body relax. 🧘‍♀️");
      } else {
        advice.add("Your heart rate looks healthy! This indicates good cardiovascular fitness. Keep maintaining your active lifestyle! 💓");
      }
    }
    
    // General motivation
    if (advice.isEmpty) {
      advice.add("Every day is a new opportunity to invest in your health. Small consistent actions lead to big results! 🌟");
    }
    
    return advice.join('\n\n');
  }
  
  String _getDefaultAdvice() {
    return "Welcome to your personal AI coach! I'm here to help you achieve your health and wellness goals. Let's start by tracking some of your daily activities and I'll provide personalized advice to keep you motivated! 🚀";
  }
  
  Future<List<String>> getQuickTips() async {
    return [
      "Drink a glass of water first thing in the morning to kickstart your metabolism! 💧",
      "Take the stairs instead of the elevator for extra steps throughout your day! 🏃‍♀️",
      "Practice 5 minutes of deep breathing to reduce stress and improve focus! 🧘‍♀️",
      "Stand up and stretch every hour if you work at a desk! 🧘‍♂️",
      "Get 7-9 hours of quality sleep for optimal recovery and energy! 😴",
      "Eat a rainbow of fruits and vegetables for essential nutrients! 🌈",
      "Take a 10-minute walk after meals to aid digestion! 🚶‍♀️",
      "Practice gratitude by writing down 3 things you're thankful for each day! ✨",
    ];
  }
  
  Future<String> getMotivationalQuote() async {
    final quotes = [
      "The only bad workout is the one that didn't happen! 💪",
      "Your health is an investment, not an expense! 💰",
      "Small steps every day lead to big changes over time! 🎯",
      "You are stronger than you think and more capable than you know! 🌟",
      "Every expert was once a beginner. Every pro was once an amateur! 🚀",
      "The body achieves what the mind believes! 🧠",
      "Health is not about being perfect, it's about being consistent! ⚖️",
      "Your future self will thank you for the choices you make today! 🙏",
    ];
    
    return quotes[DateTime.now().day % quotes.length];
  }
}
