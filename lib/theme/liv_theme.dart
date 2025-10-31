import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive_helper.dart';

/// LIV App Theme Configuration
/// Professional theme with responsive design similar to Apatkal app
class LivTheme {
  // Color Palette - LIV App Colors
  static const Color primaryPink = Color(0xFFE91E63);
  static const Color primaryPinkDark = Color(0xFFC2185B);
  static const Color primaryPinkLight = Color(0xFFF8BBD9);
  
  static const Color secondaryPurple = Color(0xFF9C27B0);
  static const Color secondaryPurpleDark = Color(0xFF7B1FA2);
  static const Color secondaryPurpleLight = Color(0xFFE1BEE7);
  
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color accentBlueDark = Color(0xFF1976D2);
  static const Color accentBlueLight = Color(0xFFC5CAE9);
  
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentGreenDark = Color(0xFF388E3C);
  static const Color accentGreenLight = Color(0xFF81C784);
  
  static const Color accentRed = Color(0xFFE53935);
  static const Color accentRedDark = Color(0xFFD32F2F);
  static const Color accentRedLight = Color(0xFFEF5350);
  
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentOrangeDark = Color(0xFFF57C00);
  static const Color accentOrangeLight = Color(0xFFFFB74D);
  
  // Neutral Colors
  static const Color neutralGrey = Color(0xFF424242);
  static const Color neutralGreyLight = Color(0xFF757575);
  static const Color neutralGreyDark = Color(0xFF212121);
  
  // Additional grey variants
  static const Color neutralGrey50 = Color(0xFFFAFAFA);
  static const Color neutralGrey100 = Color(0xFFF5F5F5);
  static const Color neutralGrey200 = Color(0xFFEEEEEE);
  static const Color neutralGrey300 = Color(0xFFE0E0E0);
  static const Color neutralGrey400 = Color(0xFFBDBDBD);
  static const Color neutralGrey500 = Color(0xFF9E9E9E);
  static const Color neutralGrey600 = Color(0xFF757575);
  static const Color neutralGrey700 = Color(0xFF616161);
  static const Color neutralGrey800 = Color(0xFF424242);
  static const Color neutralGrey900 = Color(0xFF212121);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF2C2C2C);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textBlack = Color(0xFF000000);
  static const Color textBlack87 = Color(0xDD000000);
  static const Color textBlack54 = Color(0x8A000000);
  
  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFFF8BBD9),
    Color(0xFFE1BEE7),
    Color(0xFFC5CAE9),
    Color(0xFFB39DDB),
  ];
  
  static const List<Color> buttonGradient = [
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
  ];

  // Main App Gradient (Blue to Pink)
  static const LinearGradient mainAppGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF42A5F5),
      Color(0xFFE91E63),
    ],
  );

  // Button Gradients
  static const LinearGradient editProfileGradient = LinearGradient(
    colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
  );

  static const LinearGradient avatarManagerGradient = LinearGradient(
    colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
  );

  static const LinearGradient logoutGradient = LinearGradient(
    colors: [Color(0xFFE53E3E), Color(0xFFC53030)],
  );

  static const LinearGradient saveAvatarGradient = LinearGradient(
    colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
  );

  // Glassmorphic Colors
  static const Color glassmorphicBackground = Color(0x26FFFFFF); // Colors.white.withOpacity(0.15)
  static const Color glassmorphicBorder = Color(0x4DFFFFFF); // Colors.white.withOpacity(0.3)
  static const Color glassmorphicLightBackground = Color(0x1AFFFFFF); // Colors.white.withOpacity(0.1)
  static const Color glassmorphicLightBorder = Color(0x33FFFFFF); // Colors.white.withOpacity(0.2)
  static const Color glassmorphicUltraLightBackground = Color(0x0FFFFFFF); // Colors.white.withOpacity(0.06)
  static const Color glassmorphicUltraLightBorder = Color(0x1FFFFFFF); // Colors.white.withOpacity(0.12)

  // Responsive Text Styles
  static TextStyle getHeading1(BuildContext context) => GoogleFonts.roboto(
    fontSize: ResponsiveHelper.getFontSize(context, 
      mobile: 28, 
      tablet: 32, 
      desktop: 36,
      narrowWindow: 24,
    ),
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static TextStyle getHeading2(BuildContext context) => GoogleFonts.roboto(
    fontSize: ResponsiveHelper.getFontSize(context, 
      mobile: 22, 
      tablet: 24, 
      desktop: 28,
      narrowWindow: 20,
    ),
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static TextStyle getHeading3(BuildContext context) => GoogleFonts.roboto(
    fontSize: ResponsiveHelper.getFontSize(context, 
      mobile: 18, 
      tablet: 20, 
      desktop: 22,
      narrowWindow: 16,
    ),
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle getBodyLarge(BuildContext context) => GoogleFonts.roboto(
    fontSize: ResponsiveHelper.getFontSize(context, 
      mobile: 16, 
      tablet: 18, 
      desktop: 20,
      narrowWindow: 14,
    ),
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static TextStyle getBodyMedium(BuildContext context) => GoogleFonts.roboto(
    fontSize: ResponsiveHelper.getFontSize(context, 
      mobile: 14, 
      tablet: 16, 
      desktop: 18,
      narrowWindow: 12,
    ),
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static TextStyle getBodySmall(BuildContext context) => GoogleFonts.roboto(
    fontSize: ResponsiveHelper.getFontSize(context, 
      mobile: 12, 
      tablet: 14, 
      desktop: 16,
      narrowWindow: 10,
    ),
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );

  static TextStyle getButtonText(BuildContext context) => GoogleFonts.roboto(
    fontSize: ResponsiveHelper.getFontSize(context, 
      mobile: 16, 
      tablet: 18, 
      desktop: 20,
      narrowWindow: 14,
    ),
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle getCaption(BuildContext context) => GoogleFonts.roboto(
    fontSize: ResponsiveHelper.getFontSize(context, 
      mobile: 10, 
      tablet: 12, 
      desktop: 14,
      narrowWindow: 9,
    ),
    fontWeight: FontWeight.normal,
    color: textTertiary,
  );

  // Glassmorphic Text Styles
  static TextStyle getGlassmorphicTitle(BuildContext context) => GoogleFonts.roboto(
    fontSize: ResponsiveHelper.getFontSize(context, 
      mobile: 24, 
      tablet: 26, 
      desktop: 28,
      narrowWindow: 22,
    ),
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle getGlassmorphicSubtitle(BuildContext context) => GoogleFonts.roboto(
    fontSize: ResponsiveHelper.getFontSize(context, 
      mobile: 18, 
      tablet: 20, 
      desktop: 22,
      narrowWindow: 16,
    ),
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle getGlassmorphicBody(BuildContext context) => GoogleFonts.roboto(
    fontSize: ResponsiveHelper.getFontSize(context, 
      mobile: 16, 
      tablet: 18, 
      desktop: 20,
      narrowWindow: 14,
    ),
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );

  static TextStyle getGlassmorphicBodySecondary(BuildContext context) => GoogleFonts.roboto(
    fontSize: ResponsiveHelper.getFontSize(context, 
      mobile: 14, 
      tablet: 16, 
      desktop: 18,
      narrowWindow: 12,
    ),
    fontWeight: FontWeight.normal,
    color: Colors.white70,
  );

  static TextStyle getGlassmorphicCaption(BuildContext context) => GoogleFonts.roboto(
    fontSize: ResponsiveHelper.getFontSize(context, 
      mobile: 12, 
      tablet: 14, 
      desktop: 16,
      narrowWindow: 10,
    ),
    fontWeight: FontWeight.normal,
    color: Colors.white60,
  );

  static TextStyle getGlassmorphicButton(BuildContext context) => GoogleFonts.roboto(
    fontSize: ResponsiveHelper.getFontSize(context, 
      mobile: 16, 
      tablet: 18, 
      desktop: 20,
      narrowWindow: 14,
    ),
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  // Black Text Styles
  static TextStyle getBlackTitle(BuildContext context) => GoogleFonts.roboto(
    fontSize: ResponsiveHelper.getFontSize(context, 
      mobile: 24, 
      tablet: 26, 
      desktop: 28,
      narrowWindow: 22,
    ),
    fontWeight: FontWeight.bold,
    color: textBlack,
  );

  static TextStyle getBlackSubtitle(BuildContext context) => GoogleFonts.roboto(
    fontSize: ResponsiveHelper.getFontSize(context, 
      mobile: 18, 
      tablet: 20, 
      desktop: 22,
      narrowWindow: 16,
    ),
    fontWeight: FontWeight.w600,
    color: textBlack87,
  );

  static TextStyle getBlackBody(BuildContext context) => GoogleFonts.roboto(
    fontSize: ResponsiveHelper.getFontSize(context, 
      mobile: 16, 
      tablet: 18, 
      desktop: 20,
      narrowWindow: 14,
    ),
    fontWeight: FontWeight.normal,
    color: textBlack87,
  );

  static TextStyle getBlackBodySecondary(BuildContext context) => GoogleFonts.roboto(
    fontSize: ResponsiveHelper.getFontSize(context, 
      mobile: 14, 
      tablet: 16, 
      desktop: 18,
      narrowWindow: 12,
    ),
    fontWeight: FontWeight.normal,
    color: textBlack54,
  );

  static TextStyle getBlackCaption(BuildContext context) => GoogleFonts.roboto(
    fontSize: ResponsiveHelper.getFontSize(context, 
      mobile: 12, 
      tablet: 14, 
      desktop: 16,
      narrowWindow: 10,
    ),
    fontWeight: FontWeight.normal,
    color: textBlack54,
  );

  static TextStyle getBlackButton(BuildContext context) => GoogleFonts.roboto(
    fontSize: ResponsiveHelper.getFontSize(context, 
      mobile: 16, 
      tablet: 18, 
      desktop: 20,
      narrowWindow: 14,
    ),
    fontWeight: FontWeight.w600,
    color: textBlack87,
    letterSpacing: 0.5,
  );

  // Dialog Text Styles
  static TextStyle getDialogTitle(BuildContext context) => GoogleFonts.roboto(
    fontSize: ResponsiveHelper.getFontSize(context, 
      mobile: 24, 
      tablet: 26, 
      desktop: 28,
      narrowWindow: 22,
    ),
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static TextStyle getDialogBody(BuildContext context) => GoogleFonts.roboto(
    fontSize: ResponsiveHelper.getFontSize(context, 
      mobile: 16, 
      tablet: 18, 
      desktop: 20,
      narrowWindow: 14,
    ),
    fontWeight: FontWeight.normal,
    color: Colors.black54,
  );

  static TextStyle getDialogButton(BuildContext context) => GoogleFonts.roboto(
    fontSize: ResponsiveHelper.getFontSize(context, 
      mobile: 16, 
      tablet: 18, 
      desktop: 20,
      narrowWindow: 14,
    ),
    fontWeight: FontWeight.w600,
    color: Colors.black54,
  );

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryPink,
        primaryContainer: primaryPinkLight,
        secondary: secondaryPurple,
        secondaryContainer: secondaryPurpleLight,
        surface: surfaceLight,
        background: backgroundLight,
        error: accentRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
        onError: Colors.white,
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: primaryPink,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 24,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: surfaceLight,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPink,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryPink,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryPink, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentRed),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: GoogleFonts.roboto(
          color: textTertiary,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.roboto(
          color: textTertiary,
          fontSize: 14,
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: neutralGrey,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      
      // Text Theme
      textTheme: GoogleFonts.robotoTextTheme().copyWith(
        headlineLarge: GoogleFonts.roboto(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.roboto(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineSmall: GoogleFonts.roboto(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodySmall: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textSecondary,
        ),
        labelLarge: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        labelMedium: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textTertiary,
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: textPrimary,
        size: 24,
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: Colors.grey[300],
        thickness: 1,
        space: 1,
      ),
    );
  }
}

/// LIV App Decorations
class LivDecorations {
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration get elevatedCardDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration statusCardDecoration(Color color) => BoxDecoration(
    color: color.withOpacity(0.1),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: color, width: 2),
    boxShadow: [
      BoxShadow(
        color: color.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration buttonDecoration(Color color) => BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: color.withOpacity(0.3),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration get gradientDecoration => BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: LivTheme.primaryGradient,
      stops: [0.0, 0.3, 0.7, 1.0],
    ),
  );

  static BoxDecoration get buttonGradientDecoration => BoxDecoration(
    gradient: const LinearGradient(
      colors: LivTheme.buttonGradient,
    ),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: LivTheme.primaryPink.withOpacity(0.3),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Main App Background Gradient
  static BoxDecoration get mainAppBackground => const BoxDecoration(
    gradient: LivTheme.mainAppGradient,
  );

  // Glassmorphic Decorations
  static BoxDecoration get glassmorphicCard => BoxDecoration(
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
  );

  static BoxDecoration get glassmorphicLightCard => BoxDecoration(
    color: LivTheme.glassmorphicLightBackground,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: LivTheme.glassmorphicLightBorder,
      width: 1,
    ),
  );

  static BoxDecoration get glassmorphicUltraLightCard => BoxDecoration(
    color: LivTheme.glassmorphicUltraLightBackground,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: LivTheme.glassmorphicUltraLightBorder,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.25),
        blurRadius: 24,
        offset: const Offset(0, 10),
      ),
    ],
  );

  // Button Gradient Decorations
  static BoxDecoration get editProfileButton => BoxDecoration(
    gradient: LivTheme.editProfileGradient,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: LivTheme.primaryPink.withOpacity(0.3),
        blurRadius: 15,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration get avatarManagerButton => BoxDecoration(
    gradient: LivTheme.avatarManagerGradient,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: LivTheme.secondaryPurple.withOpacity(0.3),
        blurRadius: 15,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration get logoutButton => BoxDecoration(
    gradient: LivTheme.logoutGradient,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: LivTheme.accentRed.withOpacity(0.3),
        blurRadius: 15,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration get saveAvatarButton => BoxDecoration(
    gradient: LivTheme.saveAvatarGradient,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: LivTheme.accentBlue.withOpacity(0.3),
        blurRadius: 15,
        offset: const Offset(0, 8),
      ),
    ],
  );

  // Dialog Decorations
  static BoxDecoration get dialogDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: Colors.grey.withOpacity(0.3),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 25,
        offset: const Offset(0, 8),
        spreadRadius: 0,
      ),
    ],
  );

  // Input Field Decorations
  static BoxDecoration get glassmorphicInput => BoxDecoration(
    color: LivTheme.glassmorphicLightBackground,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: LivTheme.glassmorphicLightBorder,
      width: 1,
    ),
  );

  // Avatar Decorations
  static BoxDecoration get avatarContainer => BoxDecoration(
    color: LivTheme.glassmorphicLightBorder,
    shape: BoxShape.circle,
    border: Border.all(
      color: LivTheme.glassmorphicBorder,
      width: 1,
    ),
  );

  static BoxDecoration get cameraIconContainer => BoxDecoration(
    color: Colors.white.withOpacity(0.9),
    shape: BoxShape.circle,
    border: Border.all(
      color: Colors.white.withOpacity(0.5),
      width: 1,
    ),
  );
}

/// LIV App Spacing
class LivSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Common padding
  static const EdgeInsets paddingSmall = EdgeInsets.all(sm);
  static const EdgeInsets paddingMedium = EdgeInsets.all(md);
  static const EdgeInsets paddingLarge = EdgeInsets.all(lg);

  // Common margins
  static const EdgeInsets marginSmall = EdgeInsets.all(sm);
  static const EdgeInsets marginMedium = EdgeInsets.all(md);
  static const EdgeInsets marginLarge = EdgeInsets.all(lg);

  // Symmetric padding
  static const EdgeInsets paddingHorizontal = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingVertical = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingHorizontalLarge = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingVerticalLarge = EdgeInsets.symmetric(vertical: lg);
}

/// LIV App Border Radius
class LivBorderRadius {
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double extraLarge = 20.0;

  static BorderRadius get smallRadius => BorderRadius.circular(small);
  static BorderRadius get mediumRadius => BorderRadius.circular(medium);
  static BorderRadius get largeRadius => BorderRadius.circular(large);
  static BorderRadius get extraLargeRadius => BorderRadius.circular(extraLarge);
}

/// LIV App Button Styles
class LivButtonStyles {
  // Primary Button (Pink)
  static ButtonStyle get primaryButton => ElevatedButton.styleFrom(
    backgroundColor: LivTheme.primaryPink,
    foregroundColor: Colors.white,
    elevation: 2,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    textStyle: GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );

  // Secondary Button (Purple)
  static ButtonStyle get secondaryButton => ElevatedButton.styleFrom(
    backgroundColor: LivTheme.secondaryPurple,
    foregroundColor: Colors.white,
    elevation: 2,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    textStyle: GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );

  // Success Button (Green)
  static ButtonStyle get successButton => ElevatedButton.styleFrom(
    backgroundColor: LivTheme.accentGreen,
    foregroundColor: Colors.white,
    elevation: 2,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    textStyle: GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );

  // Danger Button (Red)
  static ButtonStyle get dangerButton => ElevatedButton.styleFrom(
    backgroundColor: LivTheme.accentRed,
    foregroundColor: Colors.white,
    elevation: 2,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    textStyle: GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );

  // Warning Button (Orange)
  static ButtonStyle get warningButton => ElevatedButton.styleFrom(
    backgroundColor: LivTheme.accentOrange,
    foregroundColor: Colors.white,
    elevation: 2,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    textStyle: GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );

  // Glassmorphic Button Styles
  static ButtonStyle get glassmorphicEditProfileButton => ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    shadowColor: Colors.transparent,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    textStyle: GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      letterSpacing: 0.5,
    ),
  );

  static ButtonStyle get glassmorphicAvatarManagerButton => ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    shadowColor: Colors.transparent,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    textStyle: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      letterSpacing: 0.5,
    ),
  );

  static ButtonStyle get glassmorphicLogoutButton => ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    shadowColor: Colors.transparent,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    textStyle: GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      letterSpacing: 0.5,
    ),
  );

  static ButtonStyle get glassmorphicSaveButton => ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    shadowColor: Colors.transparent,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    textStyle: GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      letterSpacing: 0.5,
    ),
  );

  // Dialog Button Styles
  static ButtonStyle get dialogCancelButton => TextButton.styleFrom(
    backgroundColor: Colors.transparent,
    padding: const EdgeInsets.symmetric(vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    textStyle: GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.black54,
    ),
  );

  static ButtonStyle get dialogLogoutButton => ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    shadowColor: Colors.transparent,
    padding: const EdgeInsets.symmetric(vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    textStyle: GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  );
}

/// LIV App Input Field Styles
class LivInputStyles {
  // Glassmorphic Input Decoration
  static InputDecoration getGlassmorphicInputDecoration({
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) => InputDecoration(
    filled: true,
    fillColor: LivTheme.glassmorphicLightBackground,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: LivTheme.glassmorphicLightBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: LivTheme.glassmorphicLightBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Colors.black87, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: LivTheme.accentRed),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: LivTheme.accentRedLight, width: 2),
    ),
    errorStyle: GoogleFonts.roboto(
      color: Colors.black,
      fontWeight: FontWeight.w700,
      fontSize: 12,
      // shadows: [
      //   Shadow(color: Colors.white, blurRadius: 2, offset: Offset(0, 1)),
      // ],
    ),
    labelText: labelText,
    hintText: hintText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    labelStyle: const TextStyle(color: Colors.black87),
    hintStyle: const TextStyle(color: Colors.black54),
    prefixIconColor: Colors.black87,
  );

  // Standard Input Decoration
  static InputDecoration getStandardInputDecoration({
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
  }) => InputDecoration(
    filled: true,
    fillColor: Colors.grey[50],
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: LivTheme.primaryPink, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: LivTheme.accentRed),
    ),
    labelText: labelText,
    hintText: hintText,
    prefixIcon: prefixIcon,
    labelStyle: GoogleFonts.roboto(
      color: LivTheme.textTertiary,
      fontSize: 14,
    ),
    hintStyle: GoogleFonts.roboto(
      color: LivTheme.textTertiary,
      fontSize: 14,
    ),
  );
}

/// LIV App Animations
class LivAnimations {
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 300);
  static const Duration longDuration = Duration(milliseconds: 500);

  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve slideCurve = Curves.easeOutCubic;
}

/// LIV App Popup Messages (replaces snackbars)
class LivPopupMessage {
  /// Show a success popup message
  static void showSuccess(BuildContext context, String message) {
    _showPopup(context, message, isSuccess: true);
  }

  /// Show an error popup message
  static void showError(BuildContext context, String message) {
    _showPopup(context, message, isSuccess: false);
  }

  /// Show an info popup message
  static void showInfo(BuildContext context, String message) {
    _showPopup(context, message, isSuccess: null);
  }

  /// Internal method to show the popup
  static void _showPopup(BuildContext context, String message, {bool? isSuccess}) {
    final color = isSuccess == true 
        ? LivTheme.accentGreen 
        : isSuccess == false 
            ? LivTheme.accentRed 
            : LivTheme.accentBlue;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
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
              color: color.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 0,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      color,
                      color.withOpacity(0.7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  isSuccess == true 
                      ? Icons.check_circle 
                      : isSuccess == false 
                          ? Icons.error 
                          : Icons.info,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              // Message Text
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: LivTheme.textPrimary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'OK',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

