import 'package:flutter/material.dart';

import '../../../../core/l10n/app_locale_controller.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/widgets/animated_health_background.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/local_auth_repository.dart';
import '../../../home/presentation/pages/live_booking_store.dart';
import '../widgets/auth_card.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _placeController = TextEditingController();
  final _ageController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _placeController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final loc = AppLocalizations.of(context);

    setState(() {
      _isLoading = true;
    });

    final created = await LocalAuthRepository.instance.registerUser(
      UserProfile(
        userName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
        place: _placeController.text.trim(),
        age: int.parse(_ageController.text.trim()),
      ),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (!created) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.phoneExistsLogin)),
      );
      return;
    }

    LiveBookingStore.instance.seedBookings(const []);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.registrationSuccess)),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLocaleController.localeNotifier,
      builder: (context, locale, _) {
        final loc = AppLocalizations.of(context);
        return Scaffold(
          appBar: AppBar(
            title: Text(loc.createAccount),
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
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutQuart,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - value) * 26),
                        child: child,
                      ),
                    );
                  },
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: AuthCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              loc.freshUserRegistration,
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 18),
                            TextFormField(
                              controller: _nameController,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: loc.userName,
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return loc.pleaseEnterUserName;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: loc.phoneNumber,
                                prefixIcon: Icon(Icons.phone_outlined),
                              ),
                              validator: (value) {
                                final text = value?.trim() ?? '';
                                if (text.isEmpty) return loc.pleaseEnterPhoneNumber;
                                if (!RegExp(r'^\d{10}$').hasMatch(text)) {
                                  return loc.invalidTenDigitPhone;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _placeController,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: loc.place,
                                prefixIcon: Icon(Icons.location_on_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return loc.pleaseEnterPlace;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: loc.age,
                                prefixIcon: Icon(Icons.cake_outlined),
                              ),
                              validator: (value) {
                                final text = value?.trim() ?? '';
                                if (text.isEmpty) return loc.pleaseEnterAge;
                                final age = int.tryParse(text);
                                if (age == null || age < 1 || age > 120) {
                                  return loc.enterValidAge;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: loc.password,
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                final text = value ?? '';
                                if (text.isEmpty) return loc.pleaseEnterPassword;
                                if (text.length < 6) {
                                  return loc.passwordMinLength;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                labelText: loc.confirmPassword,
                                prefixIcon: const Icon(Icons.lock_reset_outlined),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                final text = value ?? '';
                                if (text.isEmpty) return loc.pleaseConfirmPassword;
                                if (text != _passwordController.text) {
                                  return loc.passwordsDoNotMatch;
                                }
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
                                onPressed: _isLoading ? null : _register,
                                child:
                                    _isLoading
                                        ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : Text(loc.register),
                              ),
                            ),
                          ],
                        ),
                      ),
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
