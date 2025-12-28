import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/auth_provider.dart';
import '../../../home/presentation/screens/main_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  // Sign In Controllers
  final _signInEmailController = TextEditingController();
  final _signInPasswordController = TextEditingController();

  // Sign Up Controllers
  final _signUpNameController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();
  final _signUpConfirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _signUpNameController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    _signUpConfirmPasswordController.dispose();
    super.dispose();
  }

  void _navigateToMain() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  Future<void> _handleSignIn() async {
    if (!_signInFormKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithEmail(
      _signInEmailController.text.trim(),
      _signInPasswordController.text,
    );

    if (success && mounted) {
      _navigateToMain();
    } else if (mounted) {
      _showErrorSnackBar(authProvider.errorMessage ?? 'Sign in failed');
    }
  }

  Future<void> _handleSignUp() async {
    if (!_signUpFormKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUpWithEmail(
      _signUpEmailController.text.trim(),
      _signUpPasswordController.text,
      _signUpNameController.text.trim(),
    );

    if (success && mounted) {
      _navigateToMain();
    } else if (mounted) {
      _showErrorSnackBar(authProvider.errorMessage ?? 'Sign up failed');
    }
  }

  Future<void> _handleGuestLogin() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInAnonymously();

    if (success && mounted) {
      _navigateToMain();
    } else if (mounted) {
      _showErrorSnackBar(authProvider.errorMessage ?? 'Failed to continue as guest');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              // Header
              _buildHeader(isDark),
              const SizedBox(height: 40),
              // Tab Bar
              _buildTabBar(l10n),
              const SizedBox(height: 24),
              // Tab Content
              SizedBox(
                height: 380,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSignInForm(l10n),
                    _buildSignUpForm(l10n),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),
              // Guest Button
              _buildGuestButton(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.monetization_on,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome to Paid Surveys',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Earn coins by sharing your opinions',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondaryLight,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: [
          Tab(text: l10n.signIn),
          Tab(text: l10n.signUp),
        ],
      ),
    );
  }

  Widget _buildSignInForm(AppLocalizations l10n) {
    return Form(
      key: _signInFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _signInEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: l10n.email,
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _signInPasswordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: l10n.password,
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
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
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Implement forgot password
              },
              child: Text(l10n.forgotPassword),
            ),
          ),
          const SizedBox(height: 16),
          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: auth.status == AuthStatus.loading
                      ? null
                      : _handleSignIn,
                  child: auth.status == AuthStatus.loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(l10n.signIn),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm(AppLocalizations l10n) {
    return Form(
      key: _signUpFormKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: _signUpNameController,
              decoration: InputDecoration(
                labelText: l10n.name,
                prefixIcon: const Icon(Icons.person_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _signUpEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: l10n.email,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _signUpPasswordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: l10n.password,
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _signUpConfirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: l10n.confirmPassword,
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() =>
                        _obscureConfirmPassword = !_obscureConfirmPassword);
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _signUpPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Consumer<AuthProvider>(
              builder: (context, auth, child) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: auth.status == AuthStatus.loading
                        ? null
                        : _handleSignUp,
                    child: auth.status == AuthStatus.loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(l10n.signUp),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestButton(AppLocalizations l10n) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return OutlinedButton.icon(
          onPressed:
              auth.status == AuthStatus.loading ? null : _handleGuestLogin,
          icon: const Icon(Icons.person_outline),
          label: Text(l10n.continueAsGuest),
        );
      },
    );
  }
}
