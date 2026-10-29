import 'package:flutter/material.dart';
import '../../services/oauth_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/auth.dart';
import '../../widgets/common.dart';
import '../admin/admin_dashboard.dart';
import '../customer/customer_dashboard.dart';
import '../employee/employee_dashboard.dart';
import 'otp_screen.dart';
import 'register_screen.dart';
import '../features/face_login_screen.dart';
class LoginScreen extends StatefulWidget { const LoginScreen({super.key}); @override State<LoginScreen> createState() => _L(); }
class _L extends State<LoginScreen> {
  final _u = TextEditingController(); final _p = TextEditingController();
  bool _loading = false, _obscure = true;
  Widget _go(String role) => role == 'Admin' ? const AdminDashboard() : role == 'Customer' ? const CustomerDashboard() : const EmployeeDashboard();
  Future<void> _login() async {
    if (_u.text.isEmpty || _p.text.isEmpty) { snack(context, 'Vui lòng nhập đầy đủ thông tin'); return; }
    setState(() => _loading = true);
    final r = await Auth.login(_u.text, _p.text);
    setState(() => _loading = false);
    if (r['success'] != true) { snack(context, '${r['message']}'); return; }
    if (!mounted) return;
    // Mật khẩu đúng -> server đã gửi OTP, sang màn hình OTP (chưa có token).
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OtpScreen(username: _u.text)));
  }
  Future<void> _google() async {
    setState(() => _loading = true);
    final r = await OAuthService.loginWithGoogle();
    setState(() => _loading = false);
    if (r['success'] != true) { snack(context, '${r['message']}'); return; }
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => _go('${r['role']}')));
  }
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
                decoration: const BoxDecoration(gradient: AppTheme.gradient, borderRadius: BorderRadius.vertical(bottom: Radius.circular(32))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.22), borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.fingerprint, size: 36, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text('Chào mừng trở lại', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 4),
                  const Text('Đăng nhập để chấm công và xem lịch làm việc của bạn.', style: TextStyle(fontSize: 15, color: Colors.white70)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  AppField(c: _u, hint: 'Ví dụ: nhanvien@congty.vn', label: 'Email / tên đăng nhập', prefixIcon: Icons.person_outline, type: TextInputType.emailAddress),
                  const SizedBox(height: 14),
                  AppField(c: _p, hint: 'Nhập mật khẩu của bạn', label: 'Mật khẩu', prefixIcon: Icons.lock_outline, obscure: _obscure, suffix: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscure = !_obscure))),
                  const SizedBox(height: 20),
                  AppButton(label: 'Đăng nhập', icon: Icons.login, loading: _loading, onTap: _login),
                  const SizedBox(height: 12),
                  AppOutlineButton(label: 'Đăng nhập bằng Google (OAuth2.0)', icon: Icons.language, onTap: _loading ? null : _google),
                  TextButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FaceLoginScreen())), icon: const Icon(Icons.face), label: const Text('Đăng nhập bằng khuôn mặt')),
                  const SizedBox(height: 8),
                  const AppCard(
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(Icons.shield_outlined, color: AppTheme.teal),
                      SizedBox(width: 10),
                      Expanded(child: Text('Mọi dữ liệu đều qua API backend. OTP do backend sinh và gửi SMS/Email; bản dev xem mã trong log của backend, mã không hiện trên app.', style: TextStyle(fontSize: 13, color: AppTheme.muted))),
                    ]),
                  ),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('Chưa có tài khoản? '),
                    TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())), child: const Text('Đăng ký ngay')),
                  ]),
                ]),
              ),
            ]),
          ),
        ),
      );
}
