import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/crud_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/auth.dart';
import '../../widgets/common.dart';
import '../auth/login_screen.dart';
class AdminDashboard extends StatefulWidget { const AdminDashboard({super.key}); @override State<AdminDashboard> createState() => _A(); }
class _A extends State<AdminDashboard> {
  final _crud = CrudService(); int _tab = 0; final _search = TextEditingController();
  bool _loading = true; String? _error;
  List<Employee> _emps = []; List<Department> _depts = []; List<Attendance> _atts = []; List<LeaveRequest> _leaves = []; List<Appointment> _appts = [];
  @override void initState() { super.initState(); _load(); }
  Future<void> _load({String? search}) async {
    setState(() { _loading = true; _error = null; });
    try {
      _emps = await _crud.employees(search: search ?? _search.text);
      _depts = await _crud.departments(); _atts = await _crud.attendances(); _leaves = await _crud.leaves(); _appts = await _crud.appointments();
    } catch (e) { _error = '$e'; }
    if (mounted) setState(() => _loading = false);
  }
  Future<void> _logout() async { await Auth.logout(); if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())); }
  String _empName(String id) { for (final e in _emps) { if (e.id == id) return e.name; } return 'NV $id'; }
  void _editEmployee([Employee? e]) {
    final name = TextEditingController(text: e?.name ?? ''); final email = TextEditingController(text: e?.email ?? ''); String role = e?.role ?? 'Employee'; String? dept = e?.departmentId;
    showDialog(context: context, builder: (_) => AlertDialog(title: Text(e == null ? 'Thêm nhân viên' : 'Sửa nhân viên'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      AppField(c: name, hint: 'Họ tên', label: 'Họ tên'), const SizedBox(height: 10), AppField(c: email, hint: 'Email', label: 'Email', type: TextInputType.emailAddress),
      const SizedBox(height: 10),
      DropdownButtonFormField<String>(initialValue: role, decoration: const InputDecoration(labelText: 'Vai trò'), items: const [DropdownMenuItem(value: 'Employee', child: Text('Nhân viên')), DropdownMenuItem(value: 'Admin', child: Text('Admin')), DropdownMenuItem(value: 'Customer', child: Text('Khách hàng'))], onChanged: (v) => role = v ?? 'Employee'),
      const SizedBox(height: 10),
      DropdownButtonFormField<String?>(initialValue: dept, decoration: const InputDecoration(labelText: 'Phòng ban'), items: [const DropdownMenuItem(value: null, child: Text('Chưa phân phòng')), ..._depts.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name)))], onChanged: (v) => dept = v),
    ])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')), ElevatedButton(onPressed: () async { try { if (e == null) { await _crud.addEmployee(Employee(id: '0', name: name.text, email: email.text, role: role, departmentId: dept)); } else { await _crud.updateEmployee(Employee(id: e.id, name: name.text, email: email.text, role: role, departmentId: dept, position: e.position)); } if (mounted) Navigator.pop(context); await _load(); } catch (err) { snack(context, '$err'); } }, child: const Text('Lưu'))]));
  }
  void _editDept([Department? d]) {
    final name = TextEditingController(text: d?.name ?? '');
    showDialog(context: context, builder: (_) => AlertDialog(title: Text(d == null ? 'Thêm phòng ban' : 'Sửa phòng ban'), content: AppField(c: name, hint: 'Tên phòng ban', label: 'Tên phòng ban'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')), ElevatedButton(onPressed: () async { try { if (d == null) await _crud.addDepartment(Department(id: '0', name: name.text)); else await _crud.updateDepartment(Department(id: d.id, name: name.text)); if (mounted) Navigator.pop(context); await _load(); } catch (err) { snack(context, '$err'); } }, child: const Text('Lưu'))]));
  }
  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) => Container(
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
        child: IconButton(icon: Icon(icon, color: color, size: 20), onPressed: onTap),
      );
  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_loading) { body = const Center(child: CircularProgressIndicator()); }
    else if (_error != null) { body = Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.cloud_off_outlined, size: 48, color: AppTheme.muted), const SizedBox(height: 12), Text('Lỗi tải dữ liệu từ API:\n$_error', textAlign: TextAlign.center), const SizedBox(height: 12), ElevatedButton(onPressed: () => _load(), child: const Text('Thử lại'))]))); }
    else if (_tab == 0) {
      final pending = _atts.where((a) => a.status == 'Can duyet').toList();
      body = ListView(padding: const EdgeInsets.all(16), children: [
        const SectionTitle(title: 'Tổng quan hôm nay', subtitle: 'Số liệu lấy trực tiếp từ API backend.'),
        StatCard(title: 'Nhân viên', value: '${_emps.length}', icon: Icons.people),
        const SizedBox(height: 10),
        StatCard(title: 'Bản chấm công', value: '${_atts.length}', icon: Icons.fingerprint),
        const SizedBox(height: 10),
        StatCard(title: 'Đơn nghỉ chờ duyệt', value: '${_leaves.where((l) => l.status == 'Cho duyet').length}', icon: Icons.event_note),
        const SizedBox(height: 20),
        SectionTitle(title: 'Chấm công cần duyệt', subtitle: pending.isEmpty ? 'Hiện không có bản ghi nào chờ duyệt.' : '${pending.length} bản ghi đang chờ bạn xác minh.'),
        ...pending.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(child: ListTile(title: Text('${a.employeeName.isNotEmpty ? a.employeeName : _empName(a.employeeId)} - ${a.date.day}/${a.date.month}'), subtitle: Text(a.note), trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                _actionBtn(Icons.check, AppTheme.success, () async { await _crud.updateAttendance(Attendance(id: a.id, employeeId: a.employeeId, employeeName: a.employeeName, date: a.date, checkIn: a.checkIn, checkOut: a.checkOut, status: 'Di lam', note: '${a.note} | Admin duyet')); await _load(); }),
                const SizedBox(width: 6),
                _actionBtn(Icons.close, AppTheme.danger, () async { await _crud.deleteAttendance(a.id); await _load(); }),
              ]))),
            )),
      ]);
    } else if (_tab == 1) {
      body = Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: AppField(c: _search, hint: 'Tìm nhân viên theo tên', label: 'Tìm kiếm', prefixIcon: Icons.search, onChanged: (_) => _load())),
        Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: _emps.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(child: ListTile(leading: CircleAvatar(backgroundColor: AppTheme.tealSoft, child: Text(e.name.isNotEmpty ? e.name[0].toUpperCase() : '?', style: const TextStyle(color: AppTheme.tealDark, fontWeight: FontWeight.w800))), title: Text(e.name), subtitle: Text('${e.email} - ${e.role} - ${_crud.deptName(_depts, e.departmentId)}'), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _editEmployee(e)), IconButton(icon: const Icon(Icons.delete_outline, color: AppTheme.danger), onPressed: () async { await _crud.deleteEmployee(e.id); await _load(); })]))),
            )).toList())),
        Padding(padding: const EdgeInsets.all(16), child: AppButton(label: 'Thêm nhân viên', icon: Icons.person_add, onTap: () => _editEmployee())),
      ]);
    } else if (_tab == 2) {
      body = Column(children: [
        Expanded(child: ListView(padding: const EdgeInsets.all(16), children: _depts.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(child: ListTile(leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: AppTheme.tealSoft, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.business_outlined, color: AppTheme.teal)), title: Text(d.name), subtitle: const Text('Xóa phòng -> nhân viên về "Chưa phân phòng" (không xóa nhân viên)'), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _editDept(d)), IconButton(icon: const Icon(Icons.delete_outline, color: AppTheme.danger), onPressed: () async { await _crud.deleteDepartment(d.id); await _load(); })]))),
            )).toList())),
        Padding(padding: const EdgeInsets.all(16), child: AppButton(label: 'Thêm phòng ban', icon: Icons.add_business, onTap: () => _editDept())),
      ]);
    } else if (_tab == 4) {
      body = ListView(padding: const EdgeInsets.all(16), children: [
        const SectionTitle(title: 'Lịch hẹn của khách hàng', subtitle: 'Admin xác nhận hoặc từ chối lịch hẹn.'),
        ..._appts.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(child: ListTile(title: Text('${a.customerName}: ${a.reason}'), subtitle: Text('${a.date.day}/${a.date.month}/${a.date.year} - ${a.customerEmail}'), trailing: a.status == 'Cho xac nhan' ? Row(mainAxisSize: MainAxisSize.min, children: [
                _actionBtn(Icons.check, AppTheme.success, () async { await _crud.updateAppointment(Appointment(id: a.id, customerName: a.customerName, customerEmail: a.customerEmail, date: a.date, reason: a.reason, status: 'Da xac nhan')); await _load(); }),
                const SizedBox(width: 6),
                _actionBtn(Icons.close, AppTheme.danger, () async { await _crud.updateAppointment(Appointment(id: a.id, customerName: a.customerName, customerEmail: a.customerEmail, date: a.date, reason: a.reason, status: 'Tu choi')); await _load(); }),
              ]) : StatusChip(label: a.status, good: a.status == 'Da xac nhan'))),
            )),
      ]);
    } else {
      body = ListView(padding: const EdgeInsets.all(16), children: _leaves.map((l) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(child: ListTile(title: Text('${l.employeeName.isNotEmpty ? l.employeeName : _empName(l.employeeId)}: ${l.reason}'), subtitle: Text('${l.from.day}/${l.from.month} - ${l.status}'), trailing: l.status == 'Cho duyet' ? Row(mainAxisSize: MainAxisSize.min, children: [
              _actionBtn(Icons.check, AppTheme.success, () async { await _crud.updateLeave(LeaveRequest(id: l.id, employeeId: l.employeeId, employeeName: l.employeeName, from: l.from, to: l.to, reason: l.reason, status: 'Da duyet')); await _load(); }),
              const SizedBox(width: 6),
              _actionBtn(Icons.close, AppTheme.danger, () async { await _crud.updateLeave(LeaveRequest(id: l.id, employeeId: l.employeeId, employeeName: l.employeeName, from: l.from, to: l.to, reason: l.reason, status: 'Tu choi')); await _load(); }),
            ]) : StatusChip(label: l.status, good: l.status == 'Da duyet'))),
          )).toList());
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Trang quản trị'), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => _load()), IconButton(icon: const Icon(Icons.logout), onPressed: _logout, tooltip: 'Đăng xuất (xóa token)')]),
      body: body,
      bottomNavigationBar: BottomNavigationBar(currentIndex: _tab, onTap: (i) => setState(() => _tab = i), items: const [BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Tổng quan'), BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Nhân viên'), BottomNavigationBarItem(icon: Icon(Icons.business_outlined), label: 'Phòng ban'), BottomNavigationBarItem(icon: Icon(Icons.event_note_outlined), label: 'Đơn nghỉ'), BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Lịch hẹn')]),
    );
  }
}
