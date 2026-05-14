import 'package:flutter/material.dart';

import 'app/doctor_booking_app.dart';
import 'features/home/presentation/pages/live_booking_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiveBookingStore.instance.init();
  runApp(const DoctorBookingApp());
}
