import 'package:shared_preferences/shared_preferences.dart';
/// Tuan 7 - Buoc 3+6 + bai tap 1: luu/xoa token dung cach.
/// Dang xuat = xoa token (khong chi pop ve man hinh dau).
class StorageService {
  static Future<void> saveToken(String t) async => (await SharedPreferences.getInstance()).setString('jwt_token', t);
  static Future<String?> getToken() async => (await SharedPreferences.getInstance()).getString('jwt_token');
  static Future<void> clearAll() async => (await SharedPreferences.getInstance()).clear();
  static Future<void> saveString(String k, String v) async => (await SharedPreferences.getInstance()).setString(k, v);
  static Future<String?> getString(String k) async => (await SharedPreferences.getInstance()).getString(k);
}
