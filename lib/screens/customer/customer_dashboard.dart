import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/crud_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/auth.dart';
import '../../widgets/common.dart';
import '../auth/login_screen.dart';
import '../features/group_video_screen.dart';
import '../features/realtime_translate_screen.dart';
/// Role Khách hàng: không thấy dữ liệu nội bộ, chỉ đặt lịch hẹn qua API,
/// xem trạng thái lịch hẹn của mình, họp video và dịch.
class CustomerDashboard extends StatefulWidget { const CustomerDashboard({super.key}); @override State<CustomerDashboard> createState() => _Cu(); }
class _Cu extends State<CustomerDashboard> {
  final _crud = CrudService(); final _reason = TextEditingController();
  Employee? _me; List<Appointment> _list = []; bool _loading = true; DateTime _date = DateTime.now();
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try {
      _me = await _crud.me();
      if (_me != null) _list = await _crud.appointments(email: _me!.email);
    } catch (e) { if (mounted) snack(context, '$e'); }
    if (mounted) setState(() => _loading = false);
  }
  Future<void> _logout() async { await Auth.logout(); if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())); }
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Trang khách hàng'), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load), IconButton(icon: const Icon(Icons.logout), onPressed: _logout)]),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(padding: const EdgeInsets.all(16), children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(gradient: AppTheme.gradient, borderRadius: BorderRadius.all(Radius.circular(24))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.support_agent_outlined, size: 36, color: Colors.white),
                    const SizedBox(height: 12),
                    Text('Chào mừng ${_me?.name ?? 'quý khách'}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 4),
                    const Text('Đặt lịch hẹn để nhân viên liên hệ xác nhận. Quý khách không xem được bảng chấm công nội bộ.', style: TextStyle(fontSize: 14, color: Colors.white70)),
                  ]),
                ),
                const SizedBox(height: 16),
                const SectionTitle(title: 'Đặt lịch hẹn', subtitle: 'Lịch hẹn gửi lên API, Admin sẽ xác nhận hoặc từ chối.'),
                AppField(c: _reason, hint: 'Ví dụ: Tư vấn dịch vụ, gặp nhân viên hỗ trợ...', label: 'Nội dung cần hỗ trợ', prefixIcon: Icons.event_note_outlined),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: Text('Ngày hẹn: ${_date.day}/${_date.month}/${_date.year}', style: const TextStyle(fontWeight: FontWeight.w700))),
                  TextButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 90)));
                      if (picked != null) setState(() => _date = picked);
                    },
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: const Text('Chọn ngày'),
                  ),
                ]),
                const SizedBox(height: 10),
                AppButton(
                  label: 'Gửi lịch hẹn',
                  icon: Icons.send_outlined,
                  onTap: () async {
                    if (_reason.text.isEmpty || _me == null) { snack(context, 'Nhập nội dung và đợi tải hồ sơ'); return; }
                    try {
                      await _crud.addAppointment(Appointment(id: '0', customerName: _me!.name, customerEmail: _me!.email, date: _date, reason: _reason.text));
                      _reason.clear();
                      await _load();
                      if (mounted) snack(context, 'Đã gửi lịch hẹn', ok: true);
                    } catch (e) { snack(context, '$e'); }
                  },
                ),
                const SizedBox(height: 20),
                const SectionTitle(title: 'Lịch hẹn của tôi'),
                ..._list.map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Card(child: ListTile(title: Text(a.reason), subtitle: Text('${a.date.day}/${a.date.month}/${a.date.year}'), trailing: StatusChip(label: a.status, good: a.status == 'Da xac nhan', warn: a.status == 'Cho xac nhan'))),
                    )),
                const SizedBox(height: 10),
                AppOutlineButton(label: 'Vào phòng họp video với nhân viên', icon: Icons.video_call_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GroupVideoScreen()))),
                const SizedBox(height: 10),
                AppOutlineButton(label: 'Dịch realtime khi trao đổi', icon: Icons.translate_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RealtimeTranslateScreen()))),
              ]),
      );
}
