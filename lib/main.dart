import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/doctor_booking_app.dart';
import 'features/home/presentation/pages/live_booking_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://tanptywgtvynkdqnjxgs.supabase.co',
    ),
    anonKey: const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'PASTE_YOUR_KEY_HERE',
    ),
  );
  await LiveBookingStore.instance.init();
  runApp(const DoctorBookingApp());
}
