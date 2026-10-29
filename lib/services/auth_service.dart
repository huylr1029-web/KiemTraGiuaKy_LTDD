import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config_url.dart';
import '../utils/jwt_helper.dart';
import 'api_client.dart';
import 'storage_service.dart';
/// Tuan 7: register/login JWT - CHI GOI API, khong co tai khoan/dulieu local.
/// Luong moi: login (mat khau) -> server gui OTP -> verify OTP moi nhan JWT.
/// SharedPreferences CHI luu JWT token + employeeId (theo Tuan 7), khong luu du lieu nghiep vu.
class AuthService {
  final _api = ApiClient();
  String? get _base => ConfigUrl.hasBaseUrl ? ConfigUrl.baseUrl : null;
  /// Buoc 1: kiem tra mat khau, server gui OTP. Tra ve requiresOtp=true, KHONG co token.
  Future<Map<String, dynamic>> login(String username, String password) async {
    if (_base == null) return {'success': false, 'message': 'Chua cau hinh BASE_URL trong file .env (xem README).'};
    try {
      final r = await http.post(Uri.parse('${_base!}Authenticate/login'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'username': username, 'password': password}));
      if (r.statusCode != 200) return {'success': false, 'message': 'Sai tai khoan hoac mat khau.'};
      return {'success': true, 'requiresOtp': true, 'username': username};
    } catch (e) { return {'success': false, 'message': 'Khong goi duoc API: $e'}; }
  }
  Future<Map<String, dynamic>> register({required String username, required String email, required String password, required String role}) async {
    if (_base == null) return {'success': false, 'message': 'Chua cau hinh BASE_URL trong file .env.'};
    try {
      final r = await _api.post('Authenticate/register', body: {'username': username, 'email': email, 'password': password, 'initials': username.length >= 3 ? username.substring(0, 3) : username, 'role': role});
      return r.statusCode == 200 ? {'success': true, 'message': 'Dang ky thanh cong. Hay dang nhap.'} : {'success': false, 'message': 'Dang ky that bai: ${r.body}'};
    } catch (e) { return {'success': false, 'message': 'Khong goi duoc API: $e'}; }
  }
  /// Sau khi verify OTP thanh cong, luu token + lay thong tin Employee hien tai tu API.
  Future<Map<String, dynamic>> saveTokenAndLoadMe(String token) async {
    await StorageService.saveToken(token);
    final role = JwtHelper.roleFromToken(token);
    try {
      final me = await _api.get('EmployeeApi/me');
      if (me.statusCode == 200) {
        final d = jsonDecode(me.body);
        await StorageService.saveString('current_employee_id', '${d['id']}');
        await StorageService.saveString('current_employee_name', '${d['name'] ?? ''}');
      }
    } catch (_) {}
    return {'success': true, 'token': token, 'role': role};
  }
  Future<void> logout() async => StorageService.clearAll();
}
