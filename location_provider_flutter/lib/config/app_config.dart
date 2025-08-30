import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get hubUrl {
    final url = Platform.isAndroid
        ? dotenv.env['HUB_URL_ANDROID']
        : dotenv.env['HUB_URL_OTHERS'];

    if (url == null || url.isEmpty) {
      throw Exception("HUB_URL is not set. Check your .env or dart-define.");
    }
    return url;
  }
}
