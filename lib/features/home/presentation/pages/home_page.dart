import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../core/l10n/app_locale_controller.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/animated_health_background.dart';
import '../../../auth/data/models/user_profile.dart';
import '../../../auth/data/repositories/local_auth_repository.dart';
import 'live_booking_store.dart';
import 'booking_record.dart';
import 'booking_confirmation_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _dateController = TextEditingController();
  late final AnimationController _titleAnimationController;
  DateTime? _selectedBookingDate;

  @override
  void initState() {
    super.initState();
    _titleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
  }

  final List<String> _doctorOptions = const ['Dr. Midhun Raj (Skin)'];

  String? _selectedDoctor = 'Dr. Midhun Raj (Skin)';

  @override
  void dispose() {
    _titleAnimationController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickBookingDate() async {
    final now = DateTime.now();
    final initialDate = _selectedBookingDate ?? now;
    final colorScheme = Theme.of(context).colorScheme;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: colorScheme.copyWith(
              primary: const Color(0xFF2B8CFF),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2B8CFF),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      _selectedBookingDate = picked;
      _dateController.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    });
  }

  Future<void> _logout(BuildContext context) async {
    await LocalAuthRepository.instance.logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  void _onProfileTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    ).then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  void _bookAppointment(UserProfile? user) {
    if (!_formKey.currentState!.validate()) return;

    final loc = AppLocalizations.of(context);
    final name = _nameController.text.trim();
    final age = int.parse(_ageController.text.trim());
    final bookingDate = _selectedBookingDate!;
    final bookingRecord = LiveBookingStore.instance.addBooking(
      patientName: name,
      phoneNumber: (user?.phoneNumber ?? '').trim(),
      age: age,
      bookingDate: bookingDate,
      clinic: loc.clinicName,
      doctor: _selectedDoctor ?? _doctorOptions.first,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => BookingConfirmationPage(
              bookingRecord: bookingRecord,
              bookedRecords: LiveBookingStore.instance.bookings,
            ),
      ),
    ).then((_) {
      if (!mounted) return;
      _clearBookingForm();
    });
  }

  void _clearBookingForm() {
    setState(() {
      _nameController.clear();
      _ageController.clear();
      _dateController.clear();
      _selectedBookingDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return FutureBuilder<UserProfile?>(
      future: LocalAuthRepository.instance.getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            leadingWidth: 190,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    backgroundImage: user?.avatarBase64.isNotEmpty == true
                        ? MemoryImage(base64Decode(user!.avatarBase64))
                        : null,
                    child: user?.avatarBase64.isEmpty == true
                        ? const Icon(Icons.person, size: 16)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user?.userName ?? loc.guest,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ],
              ),
            ),
            title: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.92, end: 1),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(scale: value, child: child),
                );
              },
              child: AnimatedBuilder(
                animation: _titleAnimationController,
                builder: (context, child) {
                  final pulse = 1 + (_titleAnimationController.value * 0.035);
                  return Transform.scale(scale: pulse, child: child);
                },
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) {
                    final t = _titleAnimationController.value;
                    return LinearGradient(
                      begin: Alignment(-1 + t * 2, -0.2),
                      end: Alignment(1 + t * 2, 0.2),
                      colors: const [
                        Color(0xFF0E6BA8),
                        Color(0xFF4BD1C8),
                        Color(0xFF1DA1A8),
                      ],
                    ).createShader(bounds);
                  },
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Alshifa Medicals (Staffs)',
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              PopupMenuButton<Locale>(
                icon: const Icon(Icons.language),
                tooltip: loc.language,
                onSelected: AppLocaleController.setLocale,
                itemBuilder:
                    (context) => [
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
              IconButton(
                onPressed: _onProfileTap,
                icon: const Icon(Icons.account_circle_outlined),
                tooltip: loc.profile,
              ),
              IconButton(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
                tooltip: loc.logout,
              ),
            ],
          ),
          body: AnimatedHealthBackground(
            padding: EdgeInsets.zero,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
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
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Stack(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 110),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              loc.bookAppointment,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium
                                                  ?.copyWith(fontSize: 26),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        const Align(
                                          alignment: Alignment.topRight,
                                          child: _LiveOpBadge(),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    ValueListenableBuilder<
                                      List<BookingRecord>
                                    >(
                                      valueListenable:
                                          LiveBookingStore
                                              .instance
                                              .bookingsNotifier,
                                      builder: (context, bookings, _) {
                                        final phone =
                                            (user?.phoneNumber ?? '').trim();
                                        if (phone.isEmpty) {
                                          return const SizedBox.shrink();
                                        }

                                        final userBookings =
                                            bookings
                                                .where(
                                                  (booking) =>
                                                      booking.phoneNumber
                                                          .trim() ==
                                                      phone,
                                                )
                                                .toList();
                                        userBookings.sort((a, b) {
                                          final aTime =
                                              a.createdAt ??
                                              DateTime.fromMillisecondsSinceEpoch(
                                                0,
                                              );
                                          final bTime =
                                              b.createdAt ??
                                              DateTime.fromMillisecondsSinceEpoch(
                                                0,
                                              );
                                          return aTime.compareTo(bTime);
                                        });

                                        if (userBookings.isEmpty) {
                                          return const SizedBox.shrink();
                                        }

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            const SizedBox(height: 18),
                                            _buildBookedOpSection(
                                              context,
                                              userBookings,
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    TextFormField(
                                      controller: _nameController,
                                      textInputAction: TextInputAction.next,
                                      style: const TextStyle(fontSize: 18),
                                      decoration: InputDecoration(
                                        labelText: loc.name,
                                        prefixIcon: Icon(
                                          Icons.person_outline,
                                          size: 28,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return loc.pleaseEnterName;
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _ageController,
                                      keyboardType: TextInputType.number,
                                      textInputAction: TextInputAction.next,
                                      style: const TextStyle(fontSize: 18),
                                      decoration: InputDecoration(
                                        labelText: loc.age,
                                        prefixIcon: Icon(
                                          Icons.cake_outlined,
                                          size: 28,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                        ),
                                      ),
                                      validator: (value) {
                                        final text = value?.trim() ?? '';
                                        if (text.isEmpty) {
                                          return loc.pleaseEnterAge;
                                        }
                                        final age = int.tryParse(text);
                                        if (age == null ||
                                            age < 1 ||
                                            age > 120) {
                                          return loc.enterValidAge;
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    DropdownButtonFormField<String>(
                                      value: _selectedDoctor,
                                      style: const TextStyle(fontSize: 18),
                                      decoration: InputDecoration(
                                        labelText: loc.selectDoctor,
                                        prefixIcon: Icon(
                                          Icons.medical_services_outlined,
                                          size: 28,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                        ),
                                      ),
                                      items:
                                          _doctorOptions.map((doctor) {
                                            return DropdownMenuItem<String>(
                                              value: doctor,
                                              child: Text(
                                                doctor,
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedDoctor = value;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return loc.pleaseSelectDoctor;
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _dateController,
                                      readOnly: true,
                                      onTap: _pickBookingDate,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: loc.bookingDate,
                                        helperText:
                                            'Tap to choose your visit day',
                                        filled: true,
                                        fillColor: Colors.lightBlue.withValues(
                                          alpha: 0.06,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.calendar_today_rounded,
                                          size: 24,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                        ),
                                        suffixIcon: Container(
                                          margin: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.auto_awesome,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                            size: 18,
                                          ),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            22,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            22,
                                          ),
                                          borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.4),
                                            width: 1.8,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            22,
                                          ),
                                          borderSide: BorderSide(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                            width: 2.4,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (_selectedBookingDate == null) {
                                          return loc.pleaseSelectDate;
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () => _bookAppointment(user),
                                      child: Text(loc.bookAppointment),
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookedOpSection(
    BuildContext context,
    List<BookingRecord> bookedOps,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE7F4FF), Color(0xFFF2FAFF)],
        ),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.22),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_hospital_outlined,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Booked OP Numbers',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0A3D62),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(bookedOps.length, (index) {
              final entry = bookedOps[index];
              return _BookedOpBox(
                serial: index + 1,
                tokenNumber: entry.tokenNumber,
                patientName: entry.patientName,
                isLatest: index == bookedOps.length - 1,
                animationDelayMs: index * 90,
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _BookedOpBox extends StatelessWidget {
  const _BookedOpBox({
    required this.serial,
    required this.tokenNumber,
    required this.patientName,
    required this.isLatest,
    required this.animationDelayMs,
  });

  final int serial;
  final String tokenNumber;
  final String patientName;
  final bool isLatest;
  final int animationDelayMs;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isToken15 = tokenNumber.replaceAll(RegExp(r'[^0-9]'), '') == '15';
    final shouldHighlight = isToken15 || isLatest;

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      constraints: const BoxConstraints(minWidth: 170, maxWidth: 230),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              shouldHighlight
                  ? [const Color(0xFFE8F2FF), const Color(0xFFF7FBFF)]
                  : [Colors.white, const Color(0xFFF9FCFF)],
        ),
        boxShadow: [
          BoxShadow(
            color:
                shouldHighlight
                    ? const Color(0x2A3A7BC8)
                    : const Color(0x143A7BC8),
            blurRadius: shouldHighlight ? 16 : 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color:
              shouldHighlight
                  ? colorScheme.primary.withValues(alpha: 0.34)
                  : colorScheme.primary.withValues(alpha: 0.18),
          width: shouldHighlight ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primary.withValues(alpha: 0.12),
            ),
            alignment: Alignment.center,
            child: Text(
              '$serial',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isToken15
                            ? const Color(0xFFFFEBEE)
                            : colorScheme.primary.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    tokenNumber,
                    style: TextStyle(
                      fontSize: isToken15 ? 23 : 19,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                      color:
                          isToken15
                              ? const Color(0xFFC62828)
                              : const Color(0xFF0A3D62),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  patientName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4D5D70),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 480 + animationDelayMs),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 18),
            child: Transform.scale(scale: 0.92 + (0.08 * value), child: child),
          ),
        );
      },
      child: card,
    );
  }
}

class _LiveOpBadge extends StatelessWidget {
  const _LiveOpBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ValueListenableBuilder<int>(
      valueListenable: LiveBookingStore.instance.currentOpNumberNotifier,
      builder: (context, currentOp, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: colorScheme.primaryContainer.withValues(alpha: 0.6),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.22),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Live OP',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$currentOp',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
