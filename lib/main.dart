import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'services/theme_service.dart';
import 'services/activity_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_back_screen.dart';
import 'theme/liv_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase removed
  
  runApp(const LIVApp());
}

class LIVApp extends StatelessWidget {
  const LIVApp({super.key});

  @override
  Widget build(BuildContext context) {
                return MultiProvider(
                  providers: [
                    ChangeNotifierProvider(create: (_) => AuthService.instance),
                    ChangeNotifierProvider(create: (_) => UserService.instance),
                    ChangeNotifierProvider(create: (_) => ThemeService.instance),
                    ChangeNotifierProvider(create: (_) => ActivityService.instance),
                  ],
                  child: Consumer<ThemeService>(
                    builder: (context, themeService, child) {
                      return MaterialApp(
                        title: 'LIV App',
                        theme: LivTheme.lightTheme, // Use new responsive theme
                        darkTheme: themeService.darkTheme,
                        themeMode: themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                        home: const AuthWrapper(),
                        debugShowCheckedModeBanner: false,
                      );
                    },
                  ),
                );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: AuthService.instance.onAuthStateChanged,
      initialData: AuthService.instance.isSignedIn,
      builder: (context, snapshot) {
        // Show loading only during connection state waiting (not during auth loading)
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
              ),
            ),
          );
        }
        
        final isSignedIn = snapshot.data ?? false;
        
        if (isSignedIn) {
          // User is signed in
          return const HomeScreen();
        } else {
          // User is not signed in
          return const LoginScreen();
        }
      },
    );
  }
}
