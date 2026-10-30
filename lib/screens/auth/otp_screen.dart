import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/otp_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/jwt_helper.dart';
import '../../widgets/common.dart';
import '../admin/admin_dashboard.dart';
import '../customer/customer_dashboard.dart';
import '../employee/employee_dashboard.dart';
/// OTP qua API: backend đã gửi OTP ở bước đăng nhập. Màn hình này CHỈ verify.
class OtpScreen extends StatefulWidget {
  final String username;
  const OtpScreen({super.key, required this.username});
  @override State<OtpScreen> createState() => _O();
}
class _O extends State<OtpScreen> {
  final _c = TextEditingController(); bool _loading = false;
  Future<void> _verify() async {
    setState(() => _loading = true);
    final r = await OtpService.verify(widget.username, _c.text);
    if (r['success'] != true) { setState(() => _loading = false); snack(context, '${r['message']}'); return; }
    await AuthService().saveTokenAndLoadMe('${r['token']}');
    setState(() => _loading = false);
    if (!mounted) return;
    final role = JwtHelper.roleFromToken('${r['token']}');
    Widget next = role == 'Admin' ? const AdminDashboard() : role == 'Customer' ? const CustomerDashboard() : const EmployeeDashboard();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => next));
  }
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Xác thực OTP')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(color: AppTheme.tealSoft, borderRadius: BorderRadius.circular(22)),
              child: const Icon(Icons.sms_outlined, size: 36, color: AppTheme.teal),
            ),
            const SizedBox(height: 20),
            const SectionTitle(title: 'Nhập mã OTP', subtitle: 'Mã có hiệu lực 5 phút.'),
            Text('Mã OTP đã được backend gửi qua SMS/Email tới ${widget.username}.', style: const TextStyle(fontSize: 15, color: AppTheme.ink)),
            const SizedBox(height: 12),
            const AppCard(
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.info_outline, color: AppTheme.amber),
                SizedBox(width: 10),
                Expanded(child: Text('Bản dev: xem mã trong log của backend. App không bao giờ nhận OTP về trước.', style: TextStyle(fontSize: 13, color: AppTheme.muted))),
              ]),
            ),
            const SizedBox(height: 20),
            AutofillGroup(child: AppField(c: _c, hint: 'Ví dụ: 123456', label: 'Mã OTP 6 số', prefixIcon: Icons.pin_outlined, type: TextInputType.number, autofillHints: const [AutofillHints.oneTimeCode])),
            const SizedBox(height: 20),
            AppButton(label: 'Xác nhận OTP', icon: Icons.check_circle_outline, loading: _loading, onTap: _verify),
            TextButton(
              onPressed: () async {
                final r = await OtpService.request(widget.username);
                if (mounted) snack(context, r['success'] == true ? 'Đã gửi lại OTP' : '${r['message']}');
              },
              child: const Text('Gửi lại mã'),
            ),
          ]),
        ),
      );
}
