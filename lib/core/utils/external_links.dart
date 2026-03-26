import 'package:url_launcher/url_launcher.dart';

class ExternalLinks {
  static const String instagramUrl =
      'https://www.instagram.com/driversandbusinessclub?igsh=MWliZnViMHA1M3g0OA==';

  static Future<void> openInstagram() async {
    final uri = Uri.parse(instagramUrl);
    final launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
    if (launched) return;

    await launchUrl(uri, mode: LaunchMode.inAppWebView);
  }
}
