import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config_url.dart';
/// OTP 2 lop sau mat khau (de bai muc 2) - HOAN TOAN QUA API:
/// server tu sinh OTP, gui SMS/Email (ban dev: in ra console cua backend),
/// client CHI gui ma nguoi dung nhap len de verify, khong bao gio nhan OTP ve truoc.
class OtpService {
  static Future<Map<String, dynamic>> request(String username) async {
    if (!ConfigUrl.hasBaseUrl) return {'success': false, 'message': 'Chua cau hinh BASE_URL.'};
    try {
      final r = await http.post(Uri.parse('${ConfigUrl.baseUrl}Authenticate/request-otp'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'username': username}));
      return r.statusCode == 200 ? {'success': true} : {'success': false, 'message': 'Khong gui duoc OTP: ${r.body}'};
    } catch (e) { return {'success': false, 'message': 'Khong goi duoc API: $e'}; }
  }
  static Future<Map<String, dynamic>> verify(String username, String code) async {
    if (!ConfigUrl.hasBaseUrl) return {'success': false, 'message': 'Chua cau hinh BASE_URL.'};
    try {
      final r = await http.post(Uri.parse('${ConfigUrl.baseUrl}Authenticate/verify-otp'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'username': username, 'code': code}));
      if (r.statusCode != 200) return {'success': false, 'message': 'OTP sai hoac het han (5 phut).'};
      final d = jsonDecode(r.body);
      return {'success': true, 'token': '${d['token']}'};
    } catch (e) { return {'success': false, 'message': 'Khong goi duoc API: $e'}; }
  }
}
