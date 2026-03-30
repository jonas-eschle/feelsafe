import 'package:url_launcher/url_launcher.dart';

class PhoneService {
  /// Dial an emergency number (e.g. "112", "911").
  /// Uses tel: URI to initiate the call.
  Future<bool> callEmergency(String emergencyNumber) async {
    final uri = Uri(scheme: 'tel', path: emergencyNumber);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri);
    }
    return false;
  }

  /// Dial a specific phone number.
  Future<bool> call(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri);
    }
    return false;
  }
}
