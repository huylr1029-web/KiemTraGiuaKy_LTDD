import '../services/auth_service.dart';
import '../services/oauth_service.dart';
class Auth {
  static final _s = AuthService();
  static Future<Map<String, dynamic>> login(String u, String p) => _s.login(u, p);
  static Future<Map<String, dynamic>> register({required String username, required String email, required String password, required String role}) => _s.register(username: username, email: email, password: password, role: role);
  static Future<Map<String, dynamic>> loginWithGoogle() => OAuthService.loginWithGoogle();
  static Future<void> logout() => _s.logout();
}
