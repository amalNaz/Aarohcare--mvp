import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/widgets/animated_health_background.dart';
import '../../../splash/presentation/widgets/app_logo.dart';
import 'booking_record.dart';
import 'live_token_status_page.dart';
import 'booking_details_downloader.dart';

class BookingConfirmationPage extends StatelessWidget {
  const BookingConfirmationPage({
    super.key,
    required this.bookingRecord,
    required this.bookedRecords,
  });

  final BookingRecord bookingRecord;
  final List<BookingRecord> bookedRecords;

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _downloadDetails(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final details =
        StringBuffer()
          ..writeln(loc.bookingConfirmation)
          ..writeln('------------------------------')
          ..writeln('${loc.tokenNumber}: ${bookingRecord.tokenNumber}')
          ..writeln('${loc.patientName}: ${bookingRecord.patientName}')
          ..writeln('${loc.age}: ${bookingRecord.age} ${loc.years}')
          ..writeln(
            '${loc.bookingDate}: ${_formatDate(bookingRecord.bookingDate)}',
          )
          ..writeln('${loc.clinic}: ${bookingRecord.clinic}');

    final ok = await downloadBookingDetails(
      'booking_details_${bookingRecord.tokenNumber}.txt',
      details.toString(),
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? loc.downloadSuccess : loc.downloadNotSupported),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final loc = AppLocalizations.of(context);

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
      ),
      body: AnimatedHealthBackground(
        padding: EdgeInsets.zero,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                      offset: Offset(0, (1 - value) * 24),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      loc.bookingSuccessful,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.appointmentConfirmed,
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.assignment, color: primary),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  loc.appointmentDetails,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _DetailRow(
                              label: loc.tokenNumber,
                              value: bookingRecord.tokenNumber,
                            ),
                            _DetailRow(
                              label: loc.patientName,
                              value: bookingRecord.patientName,
                            ),
                            _DetailRow(
                              label: loc.age,
                              value: '${bookingRecord.age} ${loc.years}',
                            ),
                            _DetailRow(
                              label: loc.bookingDate,
                              value: _formatDate(bookingRecord.bookingDate),
                            ),
                            _DetailRow(
                              label: loc.clinic,
                              value: bookingRecord.clinic,
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    loc.yourTokenNumber,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    bookingRecord.tokenNumber,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(color: primary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFF8FBFF), Color(0xFFEAF5FF)],
                        ),
                        border: Border.all(
                          color: primary.withValues(alpha: 0.16),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x123A7BC8),
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.flash_on_rounded,
                                  color: primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Quick Actions',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0A3D62),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => LiveTokenStatusPage(
                                          currentRecord: bookingRecord,
                                          bookedRecords: bookedRecords,
                                        ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.published_with_changes_rounded,
                              ),
                              label: Text(loc.viewLiveTokenStatus),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                backgroundColor: const Color(0xFF2B8CFF),
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: () => _downloadDetails(context),
                              icon: const Icon(Icons.download_rounded),
                              label: Text(loc.downloadBookingDetails),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: primary.withValues(alpha: 0.45),
                                  width: 1.3,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                foregroundColor: const Color(0xFF235B8E),
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.85,
                                ),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: TextButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.add_circle_outline_rounded,
                              ),
                              label: Text(loc.bookAnotherAppointment),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF2B5F88),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final valueStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.w600,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.black54),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              ': $value',
              style: valueStyle,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
