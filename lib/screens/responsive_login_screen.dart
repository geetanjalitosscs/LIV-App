import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/responsive_helper.dart';
import '../theme/liv_theme.dart';
import '../widgets/responsive_widgets.dart';

class ResponsiveLoginScreen extends StatefulWidget {
  const ResponsiveLoginScreen({super.key});

  @override
  State<ResponsiveLoginScreen> createState() => _ResponsiveLoginScreenState();
}

class _ResponsiveLoginScreenState extends State<ResponsiveLoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoginMode = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  late AnimationController _backgroundController;
  late AnimationController _logoController;
  late AnimationController _formController;
  
  late Animation<double> _backgroundOpacity;
  late Animation<double> _logoScale;
  late Animation<double> _formOpacity;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _formController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Initialize animations
    _backgroundOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));
    
    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
    
    _formOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _backgroundController.forward();
    _logoController.forward();
    _formController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _logoController.dispose();
    _formController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _formKey.currentState?.reset();
    });
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authService = Provider.of<AuthService>(context, listen: false);
    
    try {
      if (_isLoginMode) {
        await authService.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        await authService.signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: LivTheme.accentRed,
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    try {
      await authService.signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: LivTheme.accentRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundOpacity,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: LivTheme.primaryGradient.map(
                  (color) => color.withOpacity(_backgroundOpacity.value),
                ).toList(),
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: SafeArea(
              child: ResponsiveLayout(
                narrowWindow: _buildNarrowLayout(),
                mobile: _buildMobileLayout(),
                tablet: _buildTabletLayout(),
                desktop: _buildDesktopLayout(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNarrowLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: ResponsiveHelper.getPadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ResponsiveSpacing(isLarge: true),
            
            // Logo Section
            AnimatedBuilder(
              animation: _logoScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: _logoScale.value,
                  child: ResponsiveLogo(
                    icon: Icons.favorite,
                    isSmall: true,
                  ),
                );
              },
            ),
            
            ResponsiveSpacing(isMedium: true),
            
            // App Title
            ResponsiveText(
              'LIV',
              isHeading1: true,
              textAlign: TextAlign.center,
            ),
            
            ResponsiveSpacing(isSmall: true),
            
            // Subtitle
            ResponsiveText(
              'Connect with Friends',
              isBodyMedium: true,
              textAlign: TextAlign.center,
            ),
            
            ResponsiveSpacing(isLarge: true),
            
            // Form Section
            AnimatedBuilder(
              animation: _formOpacity,
              builder: (context, child) {
                return Opacity(
                  opacity: _formOpacity.value,
                  child: _buildForm(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: ResponsiveHelper.getPadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ResponsiveSpacing(isLarge: true),
            
            // Logo Section
            AnimatedBuilder(
              animation: _logoScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: _logoScale.value,
                  child: ResponsiveLogo(
                    icon: Icons.favorite,
                    isMedium: true,
                  ),
                );
              },
            ),
            
            ResponsiveSpacing(isLarge: true),
            
            // App Title
            ResponsiveText(
              'LIV',
              isHeading1: true,
              textAlign: TextAlign.center,
            ),
            
            ResponsiveSpacing(isMedium: true),
            
            // Subtitle
            ResponsiveText(
              'Connect with Friends',
              isBodyLarge: true,
              textAlign: TextAlign.center,
            ),
            
            ResponsiveSpacing(isLarge: true),
            
            // Form Section
            AnimatedBuilder(
              animation: _formOpacity,
              builder: (context, child) {
                return Opacity(
                  opacity: _formOpacity.value,
                  child: _buildForm(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        // Left side - Logo and branding
        Expanded(
          flex: 1,
          child: Container(
            padding: ResponsiveHelper.getPadding(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _logoScale,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScale.value,
                      child: ResponsiveLogo(
                        icon: Icons.favorite,
                        isLarge: true,
                      ),
                    );
                  },
                ),
                
                ResponsiveSpacing(isLarge: true),
                
                ResponsiveText(
                  'LIV',
                  isHeading1: true,
                  textAlign: TextAlign.center,
                ),
                
                ResponsiveSpacing(isMedium: true),
                
                ResponsiveText(
                  'Connect with Friends',
                  isBodyLarge: true,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        
        // Right side - Form
        Expanded(
          flex: 1,
          child: Container(
            padding: ResponsiveHelper.getPadding(context),
            child: AnimatedBuilder(
              animation: _formOpacity,
              builder: (context, child) {
                return Opacity(
                  opacity: _formOpacity.value,
                  child: _buildForm(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 1200,
          maxHeight: 800,
        ),
        child: Row(
          children: [
            // Left side - Logo and branding
            Expanded(
              flex: 1,
              child: Container(
                padding: ResponsiveHelper.getPadding(context),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _logoScale,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoScale.value,
                          child: ResponsiveLogo(
                            icon: Icons.favorite,
                            isLarge: true,
                          ),
                        );
                      },
                    ),
                    
                    ResponsiveSpacing(isLarge: true),
                    
                    ResponsiveText(
                      'LIV',
                      isHeading1: true,
                      textAlign: TextAlign.center,
                    ),
                    
                    ResponsiveSpacing(isMedium: true),
                    
                    ResponsiveText(
                      'Connect with Friends',
                      isBodyLarge: true,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            // Right side - Form
            Expanded(
              flex: 1,
              child: Container(
                padding: ResponsiveHelper.getPadding(context),
                child: AnimatedBuilder(
                  animation: _formOpacity,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _formOpacity.value,
                      child: _buildForm(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return ResponsiveCard(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mode Toggle
            _buildModeToggle(),
            
            ResponsiveSpacing(isLarge: true),
            
            // Email Field
            _buildEmailField(),
            
            ResponsiveSpacing(isMedium: true),
            
            // Password Field
            _buildPasswordField(),
            
            // Confirm Password Field (only for registration)
            if (!_isLoginMode) ...[
              ResponsiveSpacing(isMedium: true),
              _buildConfirmPasswordField(),
            ],
            
            ResponsiveSpacing(isLarge: true),
            
            // Login/Register Button
            _buildAuthButton(),
            
            ResponsiveSpacing(isMedium: true),
            
            // Divider
            _buildDivider(),
            
            ResponsiveSpacing(isMedium: true),
            
            // Google Sign-In Button
            _buildGoogleButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: LivTheme.neutralGrey100,
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getBorderRadius(context),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!_isLoginMode) _toggleMode();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: ResponsiveHelper.getVerticalPadding(context),
                decoration: BoxDecoration(
                  gradient: _isLoginMode 
                    ? const LinearGradient(colors: LivTheme.buttonGradient)
                    : null,
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getBorderRadius(context),
                  ),
                ),
                child: ResponsiveText(
                  'Sign In',
                  isBodyMedium: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isLoginMode ? Colors.white : LivTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_isLoginMode) _toggleMode();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: ResponsiveHelper.getVerticalPadding(context),
                decoration: BoxDecoration(
                  gradient: !_isLoginMode 
                    ? const LinearGradient(colors: LivTheme.buttonGradient)
                    : null,
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getBorderRadius(context),
                  ),
                ),
                child: ResponsiveText(
                  'Sign Up',
                  isBodyMedium: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: !_isLoginMode ? Colors.white : LivTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: ResponsiveIcon(Icons.email_outlined),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.getBorderRadius(context),
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: ResponsiveIcon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: ResponsiveIcon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.getBorderRadius(context),
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        prefixIcon: ResponsiveIcon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: ResponsiveIcon(
            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.getBorderRadius(context),
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your password';
        }
        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _buildAuthButton() {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return ResponsiveButton(
          text: _isLoginMode ? 'Sign In' : 'Sign Up',
          onPressed: authService.isLoading ? null : _handleEmailAuth,
          isLoading: authService.isLoading,
        );
      },
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: LivTheme.neutralGrey300,
            thickness: 1,
          ),
        ),
        Padding(
          padding: ResponsiveHelper.getHorizontalPadding(context),
          child: ResponsiveText(
            'OR',
            isCaption: true,
          ),
        ),
        Expanded(
          child: Divider(
            color: LivTheme.neutralGrey300,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return ResponsiveButton(
          text: 'Continue with Google',
          onPressed: authService.isLoading ? null : _handleGoogleSignIn,
          icon: Icons.g_mobiledata,
          backgroundColor: Colors.white,
          textColor: LivTheme.textPrimary,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: LivTheme.textPrimary,
            elevation: 2,
            side: BorderSide(color: LivTheme.neutralGrey300),
          ),
        );
      },
    );
  }
}

