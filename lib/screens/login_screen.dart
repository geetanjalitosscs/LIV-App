import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/liv_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _buttonController;
  late AnimationController _backgroundController;
  late Animation<double> _logoScale;
  late Animation<double> _buttonOpacity;
  late Animation<double> _backgroundOpacity;
  
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoginMode = true;
  
  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
    
    _buttonOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));
    
    _backgroundOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));
    
    _startAnimations();
  }
  
  void _startAnimations() {
    _backgroundController.forward();
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 1000), () {
      _buttonController.forward();
    });
  }
  
  @override
  void dispose() {
    _logoController.dispose();
    _buttonController.dispose();
    _backgroundController.dispose();
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: LivInputStyles.getGlassmorphicInputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isVerySmallScreen = screenSize.height < 700;
    
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundOpacity,
        builder: (context, child) {
          return Container(
            decoration: LivDecorations.mainAppBackground,
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 20.0 : 40.0,
                            vertical: isVerySmallScreen ? 10.0 : 20.0,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Logo Section
                              AnimatedBuilder(
                                animation: _logoScale,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _logoScale.value,
                                    child: Container(
                                      width: isSmallScreen ? 100 : 140,
                                      height: isSmallScreen ? 100 : 140,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LivTheme.mainAppGradient,
                                        boxShadow: [
                                          BoxShadow(
                                            color: LivTheme.primaryPink.withOpacity(0.3),
                                            blurRadius: 30,
                                            spreadRadius: 5,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.favorite,
                                        size: 60,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              
                              SizedBox(height: isSmallScreen ? 20 : 30),
                              
                              // App Title with Gradient
                              ShaderMask(
                                shaderCallback: (bounds) => LivTheme.mainAppGradient.createShader(bounds),
                                child: Text(
                                  'LIV',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 42 : 56,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 4,
                                    color: Colors.black,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        offset: const Offset(0, 4),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              SizedBox(height: isSmallScreen ? 12 : 16),
                              
                              // Subtitle with better styling
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                                ),
                                  child: Text(
                                    'Connect with friends and build meaningful relationships',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 16 : 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                    letterSpacing: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              
                              SizedBox(height: isSmallScreen ? 30 : 40),
                              
                              // Main Card Container
                              AnimatedBuilder(
                                animation: _buttonOpacity,
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: _buttonOpacity.value,
                                    child: Transform.translate(
                                      offset: Offset(0, 20 * (1 - _buttonOpacity.value)),
                                      child: Container(
                                        width: double.infinity,
                                        constraints: BoxConstraints(
                                          maxWidth: isSmallScreen ? double.infinity : 400,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.white.withOpacity(0.25),
                                              Colors.white.withOpacity(0.1),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(28),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.3),
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 40,
                                              spreadRadius: 0,
                                              offset: const Offset(0, 20),
                                            ),
                                            BoxShadow(
                                              color: Colors.white.withOpacity(0.1),
                                              blurRadius: 20,
                                              spreadRadius: 0,
                                              offset: const Offset(0, -10),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(32.0),
                                          child: Form(
                                            key: _formKey,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Mode Toggle
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withOpacity(0.15),
                                                    borderRadius: BorderRadius.circular(20),
                                                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: MouseRegion(
                                                          cursor: SystemMouseCursors.click,
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              if (!_isLoginMode) _toggleMode();
                                                            },
                                                          child: AnimatedContainer(
                                                            duration: const Duration(milliseconds: 300),
                                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                                            decoration: BoxDecoration(
                                                              gradient: _isLoginMode 
                                                                ? LivTheme.mainAppGradient
                                                                : null,
                                                              borderRadius: BorderRadius.circular(18),
                                                              boxShadow: _isLoginMode ? [
                                                                BoxShadow(
                                                                  color: LivTheme.primaryPink.withOpacity(0.4),
                                                                  blurRadius: 15,
                                                                  offset: const Offset(0, 6),
                                                                ),
                                                              ] : null,
                                                            ),
                                                            child: Text(
                                                              'Sign In',
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                color: _isLoginMode ? Colors.white : Colors.black,
                                                                fontWeight: FontWeight.w600,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      ),
                                                      Expanded(
                                                        child: MouseRegion(
                                                          cursor: SystemMouseCursors.click,
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              if (_isLoginMode) _toggleMode();
                                                            },
                                                          child: AnimatedContainer(
                                                            duration: const Duration(milliseconds: 300),
                                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                                            decoration: BoxDecoration(
                                                              gradient: !_isLoginMode 
                                                                ? LivTheme.mainAppGradient
                                                                : null,
                                                              borderRadius: BorderRadius.circular(18),
                                                              boxShadow: !_isLoginMode ? [
                                                                BoxShadow(
                                                                  color: LivTheme.primaryPink.withOpacity(0.4),
                                                                  blurRadius: 15,
                                                                  offset: const Offset(0, 6),
                                                                ),
                                                              ] : null,
                                                            ),
                                                            child: Text(
                                                              'Sign Up',
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                color: !_isLoginMode ? Colors.white : Colors.black,
                                                                fontWeight: FontWeight.w600,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                
                                                const SizedBox(height: 32),
                                                
                                                // Email Field
                                                _buildInputField(
                                                  controller: _emailController,
                                                  label: 'Email',
                                                  icon: Icons.email_outlined,
                                                  keyboardType: TextInputType.emailAddress,
                                                  validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                      return 'Please enter email';
                                                    }
                                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                                      return 'Please enter a valid email';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                
                                                const SizedBox(height: 20),
                                                
                                                // Password Field
                                                _buildInputField(
                                                  controller: _passwordController,
                                                  label: 'Password',
                                                  icon: Icons.lock_outline,
                                                  obscureText: _obscurePassword,
                                                  suffixIcon: IconButton(
                                                    icon: Icon(
                                                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                                      color: Colors.black,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        _obscurePassword = !_obscurePassword;
                                                      });
                                                    },
                                                  ),
                                                  validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                      return 'Please enter password';
                                                    }
                                                    if (value.length < 6) {
                                                      return 'Password must be at least 6 characters';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                
                                                // Confirm Password Field (only for registration)
                                                if (!_isLoginMode) ...[
                                                  const SizedBox(height: 20),
                                                  _buildInputField(
                                                    controller: _confirmPasswordController,
                                                    label: 'Confirm Password',
                                                    icon: Icons.lock_outline,
                                                    obscureText: _obscureConfirmPassword,
                                                    suffixIcon: IconButton(
                                                      icon: Icon(
                                                        _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                                        color: Colors.black,
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          _obscureConfirmPassword = !_obscureConfirmPassword;
                                                        });
                                                      },
                                                    ),
                                                    validator: (value) {
                                                      if (value == null || value.isEmpty) {
                                                        return 'Please confirm password';
                                                      }
                                                      if (value != _passwordController.text) {
                                                        return 'Passwords do not match';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ],
                                                
                                                const SizedBox(height: 32),
                                                
                                                // Login/Register Button
                                                Consumer<AuthService>(
                                                  builder: (context, authService, child) {
                                                    return Container(
                                                      width: double.infinity,
                                                      height: 56,
                                                      decoration: BoxDecoration(
                                                        gradient: LivTheme.mainAppGradient,
                                                        borderRadius: BorderRadius.circular(20),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: LivTheme.primaryPink.withOpacity(0.4),
                                                            blurRadius: 20,
                                                            offset: const Offset(0, 8),
                                                          ),
                                                        ],
                                                      ),
                                                      child: ElevatedButton(
                                                        onPressed: authService.isLoading ? null : _handleEmailAuth,
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.transparent,
                                                          shadowColor: Colors.transparent,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(20),
                                                          ),
                                                        ),
                                                        child: authService.isLoading
                                                            ? const SizedBox(
                                                                width: 24,
                                                                height: 24,
                                                                child: CircularProgressIndicator(
                                                                  strokeWidth: 2,
                                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                                ),
                                                              )
                                                            : Text(
                                                                _isLoginMode ? 'Sign In' : 'Sign Up',
                                                                style: const TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight: FontWeight.w600,
                                                                  color: Colors.white,
                                                                ),
                                                              ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                                
                                                // Forgot Password (only for login)
                                                if (_isLoginMode) ...[
                                                  const SizedBox(height: 20),
                                                  TextButton(
                                                    onPressed: _showForgotPasswordDialog,
                                                    child: Text(
                                                      'Forgot Password?',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 14,
                                                        decoration: TextDecoration.underline,
                                                        decorationColor: Colors.black.withOpacity(0.7),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                
                                                const SizedBox(height: 24),
                                                
                                                // Divider
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        height: 1,
                                                        color: Colors.black.withOpacity(0.3),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                                      child: Text(
                                                        'OR',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        height: 1,
                                                        color: Colors.black.withOpacity(0.3),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                
                                                const SizedBox(height: 24),
                                                
                                                // Google Sign-In Button
                                                Consumer<AuthService>(
                                                  builder: (context, authService, child) {
                                                    return Container(
                                                      width: double.infinity,
                                                      height: 56,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white.withOpacity(0.9),
                                                        borderRadius: BorderRadius.circular(20),
                                                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black.withOpacity(0.1),
                                                            blurRadius: 20,
                                                            offset: const Offset(0, 8),
                                                          ),
                                                        ],
                                                      ),
                                                      child: OutlinedButton.icon(
                                                        onPressed: authService.isLoading ? null : _handleGoogleSignIn,
                                                        style: OutlinedButton.styleFrom(
                                                          backgroundColor: Colors.transparent,
                                                          side: BorderSide.none,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(16),
                                                          ),
                                                        ),
                                                        icon: Image.asset(
                                                          'assets/images/pngtree-google.png',
                                                          width: 24,
                                                          height: 24,
                                                        ),
                                                        label: const Text(
                                                          'Continue with Google',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w600,
                                                            color: Color(0xFF2C2C2C),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
  
  Future<void> _handleEmailAuth() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      bool success = false;
      
      if (_isLoginMode) {
        success = await authService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        success = await authService.createUserWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isLoginMode ? 'Login successful! Welcome!' : 'Account created successfully! Welcome!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isLoginMode ? 'Login failed. Please try again.' : 'Registration failed. Please try again.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }
  
  Future<void> _handleGoogleSignIn() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.signInWithGoogle();
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google Sign-In successful! Welcome!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google Sign-In failed. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email address to receive a password reset link.'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty) {
                final authService = Provider.of<AuthService>(context, listen: false);
                final success = await authService.resetPassword(emailController.text.trim());
                
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success 
                        ? 'Password reset email sent! Check your inbox.' 
                        : 'Failed to send reset email. Please try again.'),
                      backgroundColor: success ? Colors.green : Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
            },
            child: const Text('Send Reset Email'),
          ),
        ],
      ),
    );
  }
}