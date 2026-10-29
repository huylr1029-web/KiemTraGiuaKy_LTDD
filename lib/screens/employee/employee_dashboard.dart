import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/crud_service.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/auth.dart';
import '../../widgets/common.dart';
import '../auth/login_screen.dart';
import '../features/group_video_screen.dart';
import '../features/realtime_translate_screen.dart';
import 'checkin_screen.dart';
import 'leave_screen.dart';
class EmployeeDashboard extends StatefulWidget { const EmployeeDashboard({super.key}); @override State<EmployeeDashboard> createState() => _E(); }
class _E extends State<EmployeeDashboard> {
  final _crud = CrudService(); int _tab = 0; bool _loading = true; String? _error;
  Employee? _me; List<Attendance> _my = [];
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _me = await _crud.me();
      final id = _me?.id ?? await StorageService.getString('current_employee_id');
      _my = id == null ? [] : await _crud.attendances(employeeId: id);
    } catch (e) { _error = '$e'; }
    if (mounted) setState(() => _loading = false);
  }
  Future<void> _logout() async { await Auth.logout(); if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())); }
  @override
  Widget build(BuildContext context) {
    final today = _my.where((a) => a.date.day == DateTime.now().day && a.date.month == DateTime.now().month).toList();
    final hours = _my.fold<double>(0, (s, a) => s + a.hours);
    Widget body;
    if (_loading) { body = const Center(child: CircularProgressIndicator()); }
    else if (_error != null) { body = Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.cloud_off_outlined, size: 48, color: AppTheme.muted), const SizedBox(height: 12), Text('Lỗi tải dữ liệu từ API:\n$_error', textAlign: TextAlign.center), const SizedBox(height: 12), ElevatedButton(onPressed: _load, child: const Text('Thử lại'))]))); }
    else if (_tab == 0) {
      body = ListView(children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(gradient: AppTheme.gradient, borderRadius: BorderRadius.all(Radius.circular(24))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Xin chào, ${_me?.name ?? 'bạn'}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 4),
            Text(today.isEmpty ? 'Hôm nay bạn chưa chấm công.' : 'Hôm nay: ${today.first.status}', style: const TextStyle(fontSize: 14, color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 14),
        StatCard(title: 'Giờ làm (từ API)', value: '${hours.toStringAsFixed(1)} giờ', icon: Icons.access_time),
        const SizedBox(height: 10),
        StatCard(title: 'Hôm nay', value: today.isEmpty ? 'Chưa chấm công' : today.first.status, icon: Icons.today),
        const SizedBox(height: 16),
        AppButton(label: 'Chấm công ngay (Mặt + GPS + WiFi)', icon: Icons.fingerprint, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CheckinScreen(me: _me))).then((_) => _load())),
        const SizedBox(height: 10),
        AppOutlineButton(label: 'Họp video nhóm', icon: Icons.video_call_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GroupVideoScreen()))),
        const SizedBox(height: 10),
        AppOutlineButton(label: 'Dịch realtime / dịch ảnh', icon: Icons.translate_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RealtimeTranslateScreen()))),
        const SizedBox(height: 20),
        SectionTitle(title: 'Lịch sử chấm công', subtitle: _me?.name ?? ''),
        ..._my.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(child: ListTile(leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: AppTheme.tealSoft, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.event_available_outlined, color: AppTheme.teal)), title: Text('${a.date.day}/${a.date.month} - ${a.status}'), subtitle: Text('${a.note}\n${a.hours.toStringAsFixed(1)} giờ'))),
            )),
      ]);
    }
    else if (_tab == 1) { body = LeaveScreen(me: _me); }
    else {
      body = Center(
        child: AppCard(
          child: Column(children: [
            CircleAvatar(radius: 36, backgroundColor: AppTheme.tealSoft, child: Text((_me?.name ?? '').isNotEmpty ? _me!.name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.tealDark))),
            const SizedBox(height: 14),
            Text(_me?.name ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(_me?.email ?? '', style: const TextStyle(color: AppTheme.muted)),
            const SizedBox(height: 8),
            StatusChip(label: _me?.role ?? ''),
          ]),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard nhân viên'), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load), IconButton(icon: const Icon(Icons.logout), onPressed: _logout, tooltip: 'Đăng xuất (xóa token)')]),
      body: Padding(padding: const EdgeInsets.all(16), child: body),
      bottomNavigationBar: BottomNavigationBar(currentIndex: _tab, onTap: (i) => setState(() => _tab = i), items: const [BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Tổng quan'), BottomNavigationBarItem(icon: Icon(Icons.event_note_outlined), label: 'Đơn nghỉ'), BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Hồ sơ')]),
    );
  }
}
