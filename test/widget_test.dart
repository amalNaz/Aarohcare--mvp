import 'package:flutter_test/flutter_test.dart';

import 'package:doctor_booking_app/app/doctor_booking_app.dart';

void main() {
  testWidgets('Splash screen appears first', (WidgetTester tester) async {
    await tester.pumpWidget(const DoctorBookingApp());
    await tester.pump();

    expect(find.text('HealthBridge'), findsOneWidget);
    expect(find.text('Doctor Booking Made Easy'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 400));
    final loginFound = find.text('Login').evaluate().isNotEmpty;
    final loginMalayalamFound = find.text('ലോഗിൻ').evaluate().isNotEmpty;
    expect(loginFound || loginMalayalamFound, isTrue);
  });
}
