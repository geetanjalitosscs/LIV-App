import 'package:flutter/material.dart';

/// Responsive Helper for LIV App
/// Provides responsive design utilities similar to Apatkal app
class ResponsiveHelper {
  // Breakpoints
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1200;
  
  // Window size detection for LIV app (500x715 window)
  static const double narrowWindowBreakpoint = 550;
  static const double smallWindowBreakpoint = 600;
  static const double mediumWindowBreakpoint = 800;
  
  /// Check if current screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Check if current screen is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  /// Check if current window is narrow (for 500px window)
  static bool isNarrowWindow(BuildContext context) {
    return MediaQuery.of(context).size.width < narrowWindowBreakpoint;
  }

  /// Check if current window is small
  static bool isSmallWindow(BuildContext context) {
    return MediaQuery.of(context).size.width < smallWindowBreakpoint;
  }

  /// Check if current window is medium
  static bool isMediumWindow(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= smallWindowBreakpoint && width < mediumWindowBreakpoint;
  }

  /// Check if current window is large
  static bool isLargeWindow(BuildContext context) {
    return MediaQuery.of(context).size.width >= mediumWindowBreakpoint;
  }

  /// Get screen width
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getPadding(BuildContext context) {
    if (isNarrowWindow(context)) {
      return const EdgeInsets.all(12.0);
    } else if (isSmallWindow(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  /// Get responsive horizontal padding
  static EdgeInsets getHorizontalPadding(BuildContext context) {
    if (isNarrowWindow(context)) {
      return const EdgeInsets.symmetric(horizontal: 12.0);
    } else if (isSmallWindow(context)) {
      return const EdgeInsets.symmetric(horizontal: 16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24.0);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32.0);
    }
  }

  /// Get responsive vertical padding
  static EdgeInsets getVerticalPadding(BuildContext context) {
    if (isNarrowWindow(context)) {
      return const EdgeInsets.symmetric(vertical: 8.0);
    } else if (isSmallWindow(context)) {
      return const EdgeInsets.symmetric(vertical: 12.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(vertical: 16.0);
    } else {
      return const EdgeInsets.symmetric(vertical: 20.0);
    }
  }

  /// Get responsive card elevation
  static double getCardElevation(BuildContext context) {
    if (isNarrowWindow(context)) {
      return 2.0;
    } else if (isSmallWindow(context)) {
      return 4.0;
    } else if (isTablet(context)) {
      return 6.0;
    } else {
      return 8.0;
    }
  }

  /// Get responsive border radius
  static double getBorderRadius(BuildContext context) {
    if (isNarrowWindow(context)) {
      return 8.0;
    } else if (isSmallWindow(context)) {
      return 12.0;
    } else if (isTablet(context)) {
      return 16.0;
    } else {
      return 20.0;
    }
  }

  /// Get responsive font size
  static double getFontSize(BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
    double? narrowWindow,
  }) {
    if (isNarrowWindow(context) && narrowWindow != null) {
      return narrowWindow;
    } else if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile * 1.1;
    } else {
      return desktop ?? mobile * 1.2;
    }
  }

  /// Get responsive icon size
  static double getIconSize(BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
    double? narrowWindow,
  }) {
    if (isNarrowWindow(context) && narrowWindow != null) {
      return narrowWindow;
    } else if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile * 1.1;
    } else {
      return desktop ?? mobile * 1.2;
    }
  }

  /// Get responsive button height
  static double getButtonHeight(BuildContext context) {
    if (isNarrowWindow(context)) {
      return 40.0;
    } else if (isSmallWindow(context)) {
      return 48.0;
    } else if (isTablet(context)) {
      return 52.0;
    } else {
      return 56.0;
    }
  }

  /// Get responsive spacing
  static double getSpacing(BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
    double? narrowWindow,
  }) {
    if (isNarrowWindow(context) && narrowWindow != null) {
      return narrowWindow;
    } else if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile * 1.2;
    } else {
      return desktop ?? mobile * 1.5;
    }
  }

  /// Get responsive grid columns
  static int getGridColumns(BuildContext context) {
    if (isNarrowWindow(context)) {
      return 1;
    } else if (isSmallWindow(context)) {
      return 2;
    } else if (isTablet(context)) {
      return 3;
    } else {
      return 4;
    }
  }

  /// Get responsive card width
  static double getCardWidth(BuildContext context, {double? maxWidth}) {
    final screenWidth = getScreenWidth(context);
    final calculatedWidth = screenWidth * 0.9; // 90% of screen width
    
    if (maxWidth != null && calculatedWidth > maxWidth) {
      return maxWidth;
    }
    
    return calculatedWidth;
  }

  /// Get responsive container constraints
  static BoxConstraints getContainerConstraints(BuildContext context, {
    double? maxWidth,
    double? maxHeight,
  }) {
    final screenWidth = getScreenWidth(context);
    final screenHeight = getScreenHeight(context);
    
    return BoxConstraints(
      maxWidth: maxWidth ?? screenWidth * 0.95,
      maxHeight: maxHeight ?? screenHeight * 0.9,
    );
  }

  /// Check if screen is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get responsive text scale factor
  static double getTextScaleFactor(BuildContext context) {
    if (isNarrowWindow(context)) {
      return 0.9;
    } else if (isSmallWindow(context)) {
      return 1.0;
    } else if (isTablet(context)) {
      return 1.1;
    } else {
      return 1.2;
    }
  }

  /// Get responsive image size
  static double getImageSize(BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
    double? narrowWindow,
  }) {
    if (isNarrowWindow(context) && narrowWindow != null) {
      return narrowWindow;
    } else if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile * 1.2;
    } else {
      return desktop ?? mobile * 1.4;
    }
  }

  /// Get responsive avatar size
  static double getAvatarSize(BuildContext context) {
    if (isNarrowWindow(context)) {
      return 40.0;
    } else if (isSmallWindow(context)) {
      return 50.0;
    } else if (isTablet(context)) {
      return 60.0;
    } else {
      return 70.0;
    }
  }

  /// Get responsive logo size
  static double getLogoSize(BuildContext context) {
    if (isNarrowWindow(context)) {
      return 60.0;
    } else if (isSmallWindow(context)) {
      return 80.0;
    } else if (isTablet(context)) {
      return 100.0;
    } else {
      return 120.0;
    }
  }
}

/// Responsive Widget Builder
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ResponsiveBreakpoint breakpoint) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveBreakpoint breakpoint;
    
    if (ResponsiveHelper.isNarrowWindow(context)) {
      breakpoint = ResponsiveBreakpoint.narrowWindow;
    } else if (ResponsiveHelper.isSmallWindow(context)) {
      breakpoint = ResponsiveBreakpoint.smallWindow;
    } else if (ResponsiveHelper.isMobile(context)) {
      breakpoint = ResponsiveBreakpoint.mobile;
    } else if (ResponsiveHelper.isTablet(context)) {
      breakpoint = ResponsiveBreakpoint.tablet;
    } else {
      breakpoint = ResponsiveBreakpoint.desktop;
    }

    return builder(context, breakpoint);
  }
}

/// Responsive Breakpoint Enum
enum ResponsiveBreakpoint {
  narrowWindow,
  smallWindow,
  mobile,
  tablet,
  desktop,
}

/// Responsive Layout Widget
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? narrowWindow;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.narrowWindow,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isNarrowWindow(context) && narrowWindow != null) {
      return narrowWindow!;
    } else if (ResponsiveHelper.isMobile(context)) {
      return mobile;
    } else if (ResponsiveHelper.isTablet(context) && tablet != null) {
      return tablet!;
    } else if (ResponsiveHelper.isDesktop(context) && desktop != null) {
      return desktop!;
    } else {
      return mobile;
    }
  }
}

