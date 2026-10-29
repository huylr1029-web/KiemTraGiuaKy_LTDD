import 'package:flutter_dotenv/flutter_dotenv.dart';
/// Tuan 7 - Buoc 2: tach BASE_URL ra .env, khong hard-code tung man hinh.
/// KHONG CON DEMO MODE: moi du lieu deu qua API backend. Neu BASE_URL rong,
/// cac service tra loi "Chua cau hinh BASE_URL" thay vi dung du lieu local.
class ConfigUrl {
  static String get baseUrl {
    final url = dotenv.env['BASE_URL'] ?? '';
    return url.isEmpty ? '' : (url.endsWith('/') ? url : '$url/');
  }
  static bool get hasBaseUrl => baseUrl.isNotEmpty;
  static double get officeLat => double.tryParse(dotenv.env['OFFICE_LAT'] ?? '') ?? 10.7769;
  static double get officeLng => double.tryParse(dotenv.env['OFFICE_LNG'] ?? '') ?? 106.7009;
  static double get officeRadiusM => double.tryParse(dotenv.env['OFFICE_RADIUS_M'] ?? '') ?? 200;
  static String get officeWifi => dotenv.env['OFFICE_WIFI_SSID'] ?? 'CongTy-WiFi';
  // Scheme nhan callback OAuth2 tu backend (dang ky trong AndroidManifest / Info.plist).
  static const oauthScheme = 'lethanhhuy0827';
}
