import 'package:flutter/material.dart';

import '../../../../core/l10n/app_locale_controller.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/animated_health_background.dart';
import '../../data/repositories/local_auth_repository.dart';
import '../../../splash/presentation/widgets/app_logo.dart';
import '../widgets/auth_card.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // Admin credentials
  static const String adminUsername = 'alshifa';
  static const String adminPassword = 'alshifa@#321';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _adminLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final loc = AppLocalizations.of(context);

    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // Verify admin credentials
    if (_usernameController.text.trim() == adminUsername &&
        _passwordController.text == adminPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.adminLoginSuccess)),
      );

      // Store admin session
      await LocalAuthRepository.instance.setAdminSession();

      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.adminHome, (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.invalidAdminCredentials)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width < 360;

    return ValueListenableBuilder<Locale>(
      valueListenable: AppLocaleController.localeNotifier,
      builder: (context, locale, _) {
        final loc = AppLocalizations.of(context);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              PopupMenuButton<Locale>(
                icon: const Icon(Icons.language),
                tooltip: loc.language,
                onSelected: AppLocaleController.setLocale,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: const Locale('en'),
                    child: Text(loc.english),
                  ),
                  PopupMenuItem(
                    value: const Locale('ml'),
                    child: Text(loc.malayalam),
                  ),
                ],
              ),
            ],
          ),
          body: AnimatedHealthBackground(
            child: Center(
              child: SingleChildScrollView(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 850),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - value) * 28),
                        child: child,
                      ),
                    );
                  },
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Align(
                          alignment: Alignment.center,
                          child: AppLogo(size: 90),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          loc.adminLogin,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter your admin credentials',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 22),
                        AuthCard(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextFormField(
                                  controller: _usernameController,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    labelText: loc.userName,
                                    prefixIcon: const Icon(Icons.admin_panel_settings),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter admin username';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  textInputAction: TextInputAction.done,
                                  decoration: InputDecoration(
                                    labelText: loc.password,
                                    prefixIcon: const Icon(Icons.lock_outline),
                                  ),
                                  validator: (value) {
                                    final text = value ?? '';
                                    if (text.isEmpty) return loc.pleaseEnterPassword;
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOut,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow:
                                        _isLoading
                                            ? const []
                                            : const [
                                              BoxShadow(
                                                color: Color(0x3362B6F7),
                                                blurRadius: 18,
                                                offset: Offset(0, 8),
                                              ),
                                            ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _adminLogin,
                                    child:
                                        _isLoading
                                            ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                            : Text(isSmall ? loc.signIn : loc.adminLogin),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Back to User Login'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
