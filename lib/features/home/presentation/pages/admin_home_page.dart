import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n/app_locale_controller.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/animated_health_background.dart';
import '../../../splash/presentation/widgets/app_logo.dart';
import '../../../auth/data/models/user_profile.dart';
import '../../../auth/data/repositories/local_auth_repository.dart';
import 'booking_record.dart';
import 'live_booking_store.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage>
    with SingleTickerProviderStateMixin {
  late Timer _refreshTimer;
  late AnimationController _titleAnimationController;
  late Animation<double> _titleFadeAnimation;
  late Animation<double> _titleScaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeUsers();
    // Refresh user list every 2 seconds to catch new registrations
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) {
        _refreshUsers();
      }
    });

    // Initialize title animations
    _titleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleAnimationController, curve: Curves.easeIn),
    );

    _titleScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _titleAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    _titleAnimationController.forward();
  }

  Future<void> _initializeUsers() async {
    try {
      await LocalAuthRepository.instance.getUsers();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing users: $e');
      }
    }
  }

  Future<void> _refreshUsers() async {
    try {
      await LocalAuthRepository.instance.getUsers();
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing users: $e');
      }
    }
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    _titleAnimationController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await LocalAuthRepository.instance.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  void _showRecordsSheet({
    required String title,
    required List<BookingRecord> records,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.78,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 54,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child:
                          records.isEmpty
                              ? Center(
                                child: Text(
                                  'No records yet',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              )
                              : ListView.separated(
                                controller: scrollController,
                                itemBuilder: (context, index) {
                                  final record = records[index];
                                  return _RecordTile(
                                    record: record,
                                    isToday: _isToday(record.bookingDate),
                                  );
                                },
                                separatorBuilder:
                                    (_, __) => const SizedBox(height: 10),
                                itemCount: records.length,
                              ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showUsersSheet(List<UserProfile> users) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.78,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 54,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'All Users',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child:
                          users.isEmpty
                              ? Center(
                                child: Text(
                                  'No registered users yet',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              )
                              : ListView.separated(
                                controller: scrollController,
                                itemBuilder: (context, index) {
                                  final user = users[index];
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Name: ${user.userName}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Phone: ${user.phoneNumber}',
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Place: ${user.place}',
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Age: ${user.age}',
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (_, __) => const SizedBox(height: 10),
                                itemCount: users.length,
                              ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openPatientPanel(
    List<UserProfile> users,
    List<BookingRecord> bookings,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => PatientPanelPage(
              users: users,
              bookings: bookings,
              isToday: _isToday,
              onOpenUsers: () => _showUsersSheet(users),
              onOpenBooked:
                  () => _showRecordsSheet(
                    title: 'Booked Users',
                    records:
                        bookings
                            .where(
                              (booking) =>
                                  booking.status != BookingStatus.cancelled,
                            )
                            .toList(),
                  ),
              onOpenToday:
                  () => _showRecordsSheet(
                    title: 'Today\'s Patients',
                    records:
                        bookings
                            .where((booking) => _isToday(booking.bookingDate))
                            .toList(),
                  ),
            ),
      ),
    );
  }

  void _openTokenPanel(List<BookingRecord> bookings) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TokenPanelPage(bookings: bookings)),
    );
  }

  void _openSlotPanel(List<BookingRecord> bookings) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SlotPanelPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      extendBody: false,
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 28),
            const SizedBox(width: 10),
            AnimatedBuilder(
              animation: _titleAnimationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _titleScaleAnimation.value,
                  child: Opacity(
                    opacity: _titleFadeAnimation.value,
                    child: const Text(
                      'Alshifa Medicals - Admin Side',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          ValueListenableBuilder<Locale>(
            valueListenable: AppLocaleController.localeNotifier,
            builder: (context, locale, _) {
              return PopupMenuButton<Locale>(
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
              );
            },
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: loc.logout,
          ),
        ],
      ),

      body: AnimatedHealthBackground(
        padding: EdgeInsets.zero,
        child: SafeArea(
          child: ValueListenableBuilder<List<UserProfile>>(
            valueListenable: LocalAuthRepository.instance.usersNotifier,
            builder: (context, users, _) {
              return ValueListenableBuilder<List<BookingRecord>>(
                valueListenable: LiveBookingStore.instance.bookingsNotifier,
                builder: (context, bookings, _) {
                  final width = MediaQuery.sizeOf(context).width;
                  final crossAxisCount = width >= 1100 ? 4 : 2;

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Center(child: AppLogo(size: 120)),
                      const SizedBox(height: 16),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: _CurrentOpEditor(),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: width >= 1100 ? 1.45 : 1.1,
                        children: [
                          _MainBox(
                            title: 'Patient',
                            subtitle:
                                'All users, booked users and today\'s patients',
                            icon: Icons.people_alt_rounded,
                            color: const Color(0xFF2B8CFF),
                            onTap: () => _openPatientPanel(users, bookings),
                          ),
                          _MainBox(
                            title: 'Token',
                            subtitle: 'Live token and current patient status',
                            icon: Icons.confirmation_number_rounded,
                            color: const Color(0xFF1DAA7A),
                            onTap: () => _openTokenPanel(bookings),
                          ),
                          _MainBox(
                            title: 'Slot',
                            subtitle: 'FCFS live slots, edit patient details',
                            icon: Icons.view_day_rounded,
                            color: const Color(0xFF8E44AD),
                            onTap: () => _openSlotPanel(bookings),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 560;
                          final buttonWidth = isWide ? 440.0 : double.infinity;
                          final buttonStyle = ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 8,
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          );

                          Widget buildPreviousButton() {
                            return SizedBox(
                              height: 64,
                              child: ElevatedButton.icon(
                                style: buttonStyle,
                                onPressed:
                                    LiveBookingStore.instance.backwardOpNumber,
                                icon: const Icon(
                                  Icons.skip_previous_rounded,
                                  size: 28,
                                ),
                                label: const Text('Previous OP'),
                              ),
                            );
                          }

                          Widget buildNextButton() {
                            return SizedBox(
                              height: 64,
                              child: ElevatedButton.icon(
                                style: buttonStyle,
                                onPressed:
                                    LiveBookingStore.instance.advanceOpNumber,
                                icon: const Icon(
                                  Icons.skip_next_rounded,
                                  size: 28,
                                ),
                                label: const Text('Next OP'),
                              ),
                            );
                          }

                          return Center(
                            child: SizedBox(
                              width: buttonWidth,
                              child:
                                  isWide
                                      ? Row(
                                        children: [
                                          Expanded(
                                            child: buildPreviousButton(),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(child: buildNextButton()),
                                        ],
                                      )
                                      : Column(
                                        children: [
                                          buildPreviousButton(),
                                          const SizedBox(height: 12),
                                          buildNextButton(),
                                        ],
                                      ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CurrentOpEditor extends StatelessWidget {
  const _CurrentOpEditor();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<int>(
      valueListenable: LiveBookingStore.instance.currentOpNumberNotifier,
      builder: (context, currentOp, _) {
        return Container(
          width: 260,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF1DAA7A).withValues(alpha: 0.18),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x163A7BC8),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF1DAA7A).withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.confirmation_number_rounded,
                  color: Color(0xFF1DAA7A),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Current OP',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Visible on user home',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$currentOp',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: const Color(0xFF0A6B50),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MainBox extends StatelessWidget {
  const _MainBox({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withValues(alpha: 0.12), Colors.white],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record, required this.isToday});

  final BookingRecord record;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final color =
        record.status == BookingStatus.arrived ? Colors.green : Colors.blue;
    final bookedDate =
        '${record.bookingDate.day.toString().padLeft(2, '0')}/${record.bookingDate.month.toString().padLeft(2, '0')}/${record.bookingDate.year}';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.person, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.patientName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text('OP ${record.opNumber} • Token ${record.tokenNumber}'),
                Text('${record.age} yrs'),
                Text(
                  'Booked: $bookedDate',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isToday)
                  Text(
                    'Today',
                    style: TextStyle(color: color, fontWeight: FontWeight.w700),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PatientPanelPage extends StatelessWidget {
  const PatientPanelPage({
    required this.users,
    required this.bookings,
    required this.isToday,
    required this.onOpenUsers,
    required this.onOpenBooked,
    required this.onOpenToday,
    super.key,
  });

  final List<UserProfile> users;
  final List<BookingRecord> bookings;
  final bool Function(DateTime) isToday;
  final VoidCallback onOpenUsers;
  final VoidCallback onOpenBooked;
  final VoidCallback onOpenToday;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ActionCard(
            title: 'All Users',
            subtitle: 'Registered users with signup details',
            color: const Color(0xFF2B8CFF),
            onTap: onOpenUsers,
          ),
          const SizedBox(height: 12),
          _ActionCard(
            title: 'Booked Users',
            subtitle: 'Booked patients and OP numbers',
            color: const Color(0xFFF39C12),
            onTap: onOpenBooked,
          ),
          const SizedBox(height: 12),
          _ActionCard(
            title: 'Today\'s Patients',
            subtitle: 'Patients booked today',
            color: const Color(0xFF1DAA7A),
            onTap: onOpenToday,
          ),
        ],
      ),
    );
  }
}

class TokenPanelPage extends StatelessWidget {
  const TokenPanelPage({required this.bookings, super.key});

  final List<BookingRecord> bookings;

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  int? _opDigitsToInt(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    final digits =
        RegExp(r'\d+').allMatches(trimmed).map((m) => m.group(0)!).join();
    final normalized = digits.isEmpty ? trimmed : digits;
    return int.tryParse(normalized);
  }

  BookingRecord? _findBookingForLiveOp(int liveOp) {
    for (final booking in bookings) {
      final opValue = _opDigitsToInt(booking.opNumber);
      if (opValue == null) continue;
      if (opValue == liveOp && booking.status != BookingStatus.cancelled) {
        return booking;
      }
    }
    return null;
  }

  Future<void> _showLiveOpDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Live OP'),
          content: ValueListenableBuilder<int>(
            valueListenable: LiveBookingStore.instance.currentOpNumberNotifier,
            builder: (context, op, _) {
              return Text(
                '$op',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLiveOpPatientDetails(BuildContext context) async {
    final liveOp = LiveBookingStore.instance.currentOpNumberNotifier.value;
    final record = _findBookingForLiveOp(liveOp);
    if (record == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No booking found for Live OP $liveOp')),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final primary = theme.colorScheme.primary;
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: primary.withValues(alpha: 0.15)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.person,
                        color: primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Live OP $liveOp Details',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _DetailLine(label: 'Patient', value: record.patientName),
                _DetailLine(label: 'Phone', value: record.phoneNumber),
                _DetailLine(label: 'Age', value: '${record.age} yrs'),
                _DetailLine(label: 'OP', value: record.opNumber),
                _DetailLine(label: 'Token', value: record.tokenNumber),
                _DetailLine(
                  label: 'Booked Date',
                  value: _formatDate(record.bookingDate),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final current =
        bookings
            .where((booking) => booking.status == BookingStatus.arrived)
            .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Token')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ActionCard(
            title: 'Current Token',
            subtitle:
                current.isEmpty
                    ? 'No patient currently active'
                    : 'Token ${current.first.tokenNumber} - ${current.first.patientName}',
            color: const Color(0xFF1DAA7A),
            onTap: () => _showLiveOpDialog(context),
          ),
          const SizedBox(height: 12),
          _ActionCard(
            title: 'Live Status',
            subtitle: 'Updates automatically when admin advances the token',
            color: const Color(0xFF2B8CFF),
            onTap: () => _showLiveOpPatientDetails(context),
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SlotPanelPage extends StatefulWidget {
  const SlotPanelPage({super.key});

  @override
  State<SlotPanelPage> createState() => _SlotPanelPageState();
}

class _SlotPanelPageState extends State<SlotPanelPage> {
  final ScrollController _scrollController = ScrollController();

  int _gridCrossAxisCount = 1;
  double _gridTileHeight = 0;
  static const double _gridMainAxisSpacing = 12;
  static const double _gridPadding = 16;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSlotIndex(int slotIndex) {
    if (!_scrollController.hasClients) return;
    if (_gridTileHeight <= 0) return;

    final rowIndex = slotIndex ~/ _gridCrossAxisCount;
    final offset = rowIndex * (_gridTileHeight + _gridMainAxisSpacing);

    final clamped = offset.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      clamped,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Slot')),
      body: ValueListenableBuilder<List<SlotEntry?>>(
        valueListenable: LiveBookingStore.instance.slotsNotifier,
        builder: (context, slots, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount =
                  width >= 1200
                      ? 4
                      : (width >= 850 ? 3 : (width >= 520 ? 2 : 1));

              final childAspectRatio =
                  width >= 1200
                      ? 1.85
                      : (width >= 850 ? 1.75 : (width >= 520 ? 1.55 : 1.9));

              // Cache sizing info for scroll-to-slot.
              _gridCrossAxisCount = crossAxisCount;
              final tileWidth =
                  (width - (_gridPadding * 2) - (12 * (crossAxisCount - 1))) /
                  crossAxisCount;
              _gridTileHeight = tileWidth / childAspectRatio;

              return Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(_gridPadding),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: _gridMainAxisSpacing,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemBuilder: (context, index) {
                    final slot = index < slots.length ? slots[index] : null;
                    final active = slot != null;

                    return InkWell(
                      onTap: () async {
                        await _showEditDialog(
                          context: context,
                          slotIndex: index,
                          slot: slot,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              active
                                  ? Colors.orange.withValues(alpha: 0.10)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.black12),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Slot ${index + 1}',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            Text(active ? slot.patientName : 'Available'),
                            if (active && slot.phoneNumber.trim().isNotEmpty)
                              Text(slot.phoneNumber),
                            if (active) Text('OP ${slot.opNumber}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _normalizeOpNumber(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';
    final digits =
        RegExp(r'\d+').allMatches(trimmed).map((m) => m.group(0)!).join();
    return digits.isNotEmpty ? digits : trimmed;
  }

  int? _opToSlotIndex(String rawOp) {
    final normalized = _normalizeOpNumber(rawOp);
    if (normalized.isEmpty) return null;
    final op = int.tryParse(normalized);
    if (op == null || op <= 0) return null;
    return op - 1;
  }

  Future<void> _showEditDialog({
    required BuildContext context,
    required int slotIndex,
    required SlotEntry? slot,
  }) async {
    final nameController = TextEditingController(text: slot?.patientName ?? '');
    final phoneController = TextEditingController(
      text: slot?.phoneNumber ?? '',
    );
    final ageController = TextEditingController(
      text: slot == null ? '' : slot.age.toString(),
    );
    final opController = TextEditingController(text: slot?.opNumber ?? '');

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(slot == null ? 'Add slot patient' : 'Edit slot patient'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: opController,
                decoration: const InputDecoration(labelText: 'OP Number'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            if (slot != null)
              TextButton(
                onPressed: () {
                  LiveBookingStore.instance.clearSlot(slotIndex);
                  Navigator.pop(context);
                },
                child: const Text('Delete'),
              ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final phoneNumber = phoneController.text.trim();
                final age = int.tryParse(ageController.text.trim()) ?? 0;
                final opNumber = _normalizeOpNumber(opController.text);
                final targetIndex = _opToSlotIndex(opNumber);

                if (name.isEmpty || opNumber.isEmpty || targetIndex == null) {
                  Navigator.pop(context);
                  return;
                }

                // Assign by OP number (OP 7 -> Slot 7) regardless of tapped slot.
                LiveBookingStore.instance.reserveSlot(
                  targetIndex,
                  SlotEntry(
                    patientName: name,
                    phoneNumber: phoneNumber,
                    age: age,
                    opNumber: opNumber,
                  ),
                );

                // If user edited an existing slot and changed OP number, move it.
                if (slot != null && targetIndex != slotIndex) {
                  LiveBookingStore.instance.clearSlot(slotIndex);
                }

                Navigator.pop(context);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToSlotIndex(targetIndex);
                });
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(subtitle),
            ],
          ),
        ),
      ),
    );
  }
}
