import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/jwt_helper.dart';
import '../admin/admin_dashboard.dart';
import '../customer/customer_dashboard.dart';
import '../employee/employee_dashboard.dart';
import 'login_screen.dart';
/// SỬA LỖI TUẦN 7 bài tập 3: mở lại app -> đọc token, kiểm tra hết hạn,
/// rồi điều hướng ĐÚNG role trong token (Admin -> Admin, Employee -> Employee...).
class SplashScreen extends StatefulWidget { const SplashScreen({super.key}); @override State<SplashScreen> createState() => _S(); }
class _S extends State<SplashScreen> {
  @override void initState() { super.initState(); _go(); }
  Future<void> _go() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    final token = await StorageService.getToken();
    Widget next = const LoginScreen();
    if (JwtHelper.isValid(token)) {
      final role = JwtHelper.roleFromToken(token!);
      next = role == 'Admin' ? const AdminDashboard() : role == 'Customer' ? const CustomerDashboard() : const EmployeeDashboard();
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => next));
  }
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.gradient),
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 96, height: 96,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.22), borderRadius: BorderRadius.circular(28)),
                child: const Icon(Icons.fingerprint, size: 56, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text('Chấm công', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 6),
              const Text('Nhanh - Chính xác - Minh bạch', style: TextStyle(fontSize: 15, color: Colors.white70)),
              const SizedBox(height: 32),
              const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white)),
              const SizedBox(height: 24),
              const Text('le_thanh_huy_0827', style: TextStyle(fontSize: 13, color: Colors.white70)),
            ]),
          ),
        ),
      );
}
