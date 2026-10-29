import 'package:jwt_decoder/jwt_decoder.dart';
/// SUA LOI TUAN 7 (bai tap ve nha 2+3):
/// Ban goc: AuthService chi tra {success, token, decodedToken} nhung LoginScreen
/// lai doc result['role'] -> role luon null -> Admin cung vao MainScreen,
/// va _checkToken() cu khi mo lai app cung cu day ve MainScreen.
/// Fix: lay role TU TOKEN, khong doan tu man hinh.
class JwtHelper {
  static bool isValid(String? token) {
    if (token == null || token.isEmpty) return false;
    try { return !JwtDecoder.isExpired(token); } catch (_) { return false; }
  }
  static String roleFromToken(String token) {
    try {
      final d = JwtDecoder.decode(token);
      final raw = d['role'] ?? d['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ?? d['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/role'];
      if (raw is List && raw.isNotEmpty) return '${raw.first}';
      if (raw != null) return '$raw';
    } catch (_) {}
    return 'Employee';
  }
  static String nameFromToken(String token) {
    try {
      final d = JwtDecoder.decode(token);
      return '${d['unique_name'] ?? d['name'] ?? d['sub'] ?? 'Nhan vien'}';
    } catch (_) { return 'Nhan vien'; }
  }
}
