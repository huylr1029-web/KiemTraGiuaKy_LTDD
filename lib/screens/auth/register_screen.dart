import 'package:flutter/material.dart';
import '../../services/oauth_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/auth.dart';
import '../../widgets/common.dart';
import '../employee/employee_dashboard.dart';
class RegisterScreen extends StatefulWidget { const RegisterScreen({super.key}); @override State<RegisterScreen> createState() => _R(); }
class _R extends State<RegisterScreen> {
  final _u = TextEditingController(); final _e = TextEditingController(); final _p = TextEditingController();
  String _role = 'Employee'; bool _loading = false, _obscure = true;
  Future<void> _reg() async {
    if (_u.text.isEmpty || _e.text.isEmpty || _p.text.length < 6) { snack(context, 'Nhập đầy đủ, mật khẩu tối thiểu 6 ký tự'); return; }
    setState(() => _loading = true);
    final r = await Auth.register(username: _u.text, email: _e.text, password: _p.text, role: _role);
    setState(() => _loading = false);
    if (!mounted) return;
    snack(context, '${r['message']}', ok: r['success'] == true);
    if (r['success'] == true) Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Đăng ký tài khoản')),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const SectionTitle(title: 'Tạo tài khoản mới', subtitle: 'Hồ sơ nhân viên sẽ được backend tạo tự động sau khi đăng ký.'),
              AppField(c: _u, hint: 'Tên đăng nhập', label: 'Tên đăng nhập', prefixIcon: Icons.person_outline),
              const SizedBox(height: 14),
              AppField(c: _e, hint: 'Email công ty', label: 'Email', prefixIcon: Icons.email_outlined, type: TextInputType.emailAddress),
              const SizedBox(height: 14),
              AppField(c: _p, hint: 'Mật khẩu (từ 6 ký tự)', label: 'Mật khẩu', prefixIcon: Icons.lock_outline, obscure: _obscure, suffix: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscure = !_obscure))),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _role,
                decoration: const InputDecoration(labelText: 'Bạn là'),
                items: const [DropdownMenuItem(value: 'Employee', child: Text('Nhân viên')), DropdownMenuItem(value: 'Customer', child: Text('Khách hàng'))],
                onChanged: (v) => setState(() => _role = v ?? 'Employee'),
              ),
              const SizedBox(height: 6),
              const Text('Backend sẽ ép về Employee/Customer; tài khoản Admin chỉ cấp tay từ server.', style: TextStyle(fontSize: 12, color: AppTheme.muted)),
              const SizedBox(height: 20),
              AppButton(label: 'Đăng ký', icon: Icons.person_add, loading: _loading, onTap: _reg),
              const SizedBox(height: 12),
              AppOutlineButton(
                label: 'Đăng ký bằng Google (OAuth2.0)',
                icon: Icons.language,
                onTap: () async {
                  final r = await OAuthService.loginWithGoogle();
                  if (!mounted) return;
                  if (r['success'] == true) {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const EmployeeDashboard()));
                  } else {
                    snack(context, '${r['message']}');
                  }
                },
              ),
            ]),
          ),
        ),
      );
}
