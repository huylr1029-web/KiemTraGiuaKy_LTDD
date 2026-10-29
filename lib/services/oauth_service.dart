import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import '../config/config_url.dart';
import 'auth_service.dart';
/// OAuth2.0 ben thu 3 (de bai muc 1): Authorization Code qua backend.
/// Backend mo Google (Challenge) -> callback cua backend cap JWT noi bo roi
/// redirect ve scheme lethanhhuy0827://auth?token=... ; app bat token do.
/// Can cau hinh Google:ClientId/Secret o backend (xem backend/README.md).
/// Neu backend chua cau hinh Google, nut nay se bao loi chu khong tao user local.
class OAuthService {
  static Future<Map<String, dynamic>> loginWithGoogle() async {
    if (!ConfigUrl.hasBaseUrl) return {'success': false, 'message': 'Chua cau hinh BASE_URL.'};
    try {
      final url = '${ConfigUrl.baseUrl}Authenticate/external?provider=Google';
      final result = await FlutterWebAuth2.authenticate(url: url, callbackUrlScheme: ConfigUrl.oauthScheme);
      final uri = Uri.parse(result);
      final token = uri.queryParameters['token'];
      if (token == null || token.isEmpty) return {'success': false, 'message': 'Google dang nhap that bai hoac backend chua cau hinh.'};
      final saved = await AuthService().saveTokenAndLoadMe(token);
      return saved;
    } catch (e) { return {'success': false, 'message': 'Dang nhap Google bi huy hoac loi: $e'}; }
  }
}
