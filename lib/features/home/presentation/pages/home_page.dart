import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/l10n/app_locale_controller.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/animated_health_background.dart';
import '../../../splash/presentation/widgets/app_logo.dart';
import '../../../auth/data/models/user_profile.dart';
import '../../../auth/data/repositories/local_auth_repository.dart';
import 'booking_confirmation_page.dart';
import 'live_booking_store.dart';
import 'live_token_status_page.dart';
import 'booking_record.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<UserProfile?> _userFuture;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedDoctor = 'Dr. Midhun Raj (Skin)';

  ImageProvider<Object>? _avatarProviderFromBase64(String? base64) {
    if (base64 == null || base64.isEmpty) return null;
    try {
      return MemoryImage(base64Decode(base64));
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _userFuture = LocalAuthRepository.instance.getCurrentUser();
  }


  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await LocalAuthRepository.instance.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;
        if (user == null) {
          // No user found, go to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          });
          return const SizedBox.shrink();
        }

        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                AppLogo(size: 28),
                SizedBox(width: 10),
                Text('AarohCare'),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    );
                    if (!mounted) return;
                    setState(() {
                      _userFuture = LocalAuthRepository.instance.getCurrentUser();
                    });
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                    backgroundImage: _avatarProviderFromBase64(user.avatarBase64),
                    child: _avatarProviderFromBase64(user.avatarBase64) == null
                        ? Icon(Icons.person, color: Theme.of(context).colorScheme.primary)
                        : null,
                  ),
                ),
              ),
              ValueListenableBuilder<Locale>(
                valueListenable: AppLocaleController.localeNotifier,
                builder: (context, locale, _) {
                  return PopupMenuButton<Locale>(
                    tooltip: AppLocalizations.of(context).language,
                    icon: const Icon(Icons.language),
                    onSelected: (loc) => AppLocaleController.setLocale(loc),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: const Locale('en'),
                        child: Text(AppLocalizations.of(context).english),
                      ),
                      PopupMenuItem(
                        value: const Locale('ml'),
                        child: Text(AppLocalizations.of(context).malayalam),
                      ),
                    ],
                  );
                },
              ),
              IconButton(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          body: AnimatedHealthBackground(
            padding: EdgeInsets.zero,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 700),
                        builder: (context, value, child) => Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, (1 - value) * 18),
                            child: child,
                          ),
                        ),
                        child: Column(
                          children: [
                            const AppLogo(size: 96),
                            const SizedBox(height: 12),
                            Text(
                              'Welcome, ${user.userName}',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 18),
                            // Live OP number card
                            ValueListenableBuilder<int>(
                              valueListenable: LiveBookingStore.instance.currentOpNumberNotifier,
                              builder: (context, currentOp, _) {
                                final hasOp = currentOp > 0;
                                final opLabel = hasOp ? 'OP-$currentOp' : AppLocalizations.of(context).liveTokenStatus;
                                // Non-clickable, visually prominent Live OP card
                                final opNumber = currentOp.toString();
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Theme.of(context).colorScheme.primary.withOpacity(0.08),
                                          Colors.white,
                                        ],
                                      ),
                                      border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.12)),
                                      boxShadow: const [
                                        BoxShadow(color: Color(0x0F3A7BC8), blurRadius: 10, offset: Offset(0, 6)),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(Icons.local_hospital, color: Theme.of(context).colorScheme.primary, size: 28),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Live OP',
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    'OP-',
                                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black54, fontWeight: FontWeight.w700),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    hasOp ? opNumber : '-',
                                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                      color: const Color(0xFF235B8E),
                                                      fontWeight: FontWeight.w900,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // intentionally no action icon — display-only
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0F3A7BC8),
                              blurRadius: 14,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                AppLocalizations.of(context).bookAppointment,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _nameController..text = user.userName,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context).name,
                                  prefixIcon: const Icon(Icons.person),
                                ),
                                validator: (v) => (v == null || v.trim().isEmpty)
                                    ? AppLocalizations.of(context).pleaseEnterName
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _ageController..text = user.age.toString(),
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context).age,
                                  prefixIcon: const Icon(Icons.calendar_today),
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return AppLocalizations.of(context).pleaseEnterAge;
                                  final n = int.tryParse(v);
                                  if (n == null || n < 1 || n > 120) return AppLocalizations.of(context).enterValidAge;
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _phoneController..text = user.phoneNumber,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context).phoneNumber,
                                  prefixIcon: const Icon(Icons.phone),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(Icons.medical_services, color: Theme.of(context).colorScheme.primary),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(AppLocalizations.of(context).selectDoctor,
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
                                          const SizedBox(height: 4),
                                          Text(_selectedDoctor ?? 'Dr. Midhun Raj (Skin)',
                                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(28),
                                      onTap: () async {
                                        final now = DateTime.now();
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: _selectedDate ?? now,
                                          firstDate: now,
                                          lastDate: now.add(const Duration(days: 365)),
                                        );
                                        if (picked != null) setState(() => _selectedDate = picked);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(28),
                                          border: Border.all(color: Colors.grey.shade300),
                                          color: Colors.white,
                                        ),
                                        child: Center(
                                          child: Text(
                                            _selectedDate == null
                                                ? AppLocalizations.of(context).bookingDate
                                                : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Material(
                                    color: Colors.white,
                                    shape: const CircleBorder(),
                                    child: IconButton(
                                      onPressed: () async {
                                        final now = DateTime.now();
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: _selectedDate ?? now,
                                          firstDate: now,
                                          lastDate: now.add(const Duration(days: 365)),
                                        );
                                        if (picked != null) setState(() => _selectedDate = picked);
                                      },
                                      icon: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (!_formKey.currentState!.validate()) return;
                                    if (_selectedDate == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(AppLocalizations.of(context).pleaseSelectDate)),
                                      );
                                      return;
                                    }

                                    final booking = LiveBookingStore.instance.addBooking(
                                      patientName: _nameController.text.trim(),
                                      phoneNumber: _phoneController.text.trim(),
                                      age: int.parse(_ageController.text.trim()),
                                      bookingDate: _selectedDate!,
                                      clinic: AppLocalizations.of(context).clinicName,
                                      doctor: _selectedDoctor ?? 'Dr. Midhun Raj (Skin)',
                                    );

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BookingConfirmationPage(
                                          bookingRecord: booking,
                                          bookedRecords: LiveBookingStore.instance.bookings,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(AppLocalizations.of(context).bookAppointment),
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
