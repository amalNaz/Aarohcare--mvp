import 'booking_details_downloader_stub.dart'
    if (dart.library.html) 'booking_details_downloader_web.dart';

Future<bool> downloadBookingDetails(String fileName, String content) {
  return downloadBookingDetailsImpl(fileName, content);
}
