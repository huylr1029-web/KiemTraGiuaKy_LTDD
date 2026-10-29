import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/crud_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
class LeaveScreen extends StatefulWidget { final Employee? me; const LeaveScreen({super.key, this.me}); @override State<LeaveScreen> createState() => _Lv(); }
class _Lv extends State<LeaveScreen> {
  final _crud = CrudService(); final _reason = TextEditingController(); List<LeaveRequest> _list = []; bool _loading = true;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async { try { _list = await _crud.leaves(employeeId: widget.me?.id); } catch (e) { if (mounted) snack(context, '$e'); } if (mounted) setState(() => _loading = false); }
  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return ListView(padding: const EdgeInsets.all(16), children: [
      const SectionTitle(title: 'Gửi đơn nghỉ phép', subtitle: 'Đơn sẽ gửi lên API để Admin duyệt.'),
      AppField(c: _reason, hint: 'Ví dụ: Nghỉ ốm, việc gia đình...', label: 'Lý do nghỉ phép', prefixIcon: Icons.event_note_outlined),
      const SizedBox(height: 12),
      AppButton(label: 'Gửi đơn nghỉ (ngày hôm nay)', icon: Icons.send_outlined, onTap: () async { if (_reason.text.isEmpty || widget.me == null) { snack(context, 'Nhập lý do và đợi tải hồ sơ'); return; } final now = DateTime.now(); try { await _crud.addLeave(LeaveRequest(id: '0', employeeId: widget.me!.id, employeeName: widget.me!.name, from: now, to: now, reason: _reason.text)); _reason.clear(); await _load(); snack(context, 'Đã gửi đơn', ok: true); } catch (e) { snack(context, '$e'); } }),
      const SizedBox(height: 20),
      const SectionTitle(title: 'Đơn của tôi'),
      ..._list.map((l) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(child: ListTile(title: Text(l.reason), subtitle: Text('${l.from.day}/${l.from.month}'), trailing: Row(mainAxisSize: MainAxisSize.min, children: [StatusChip(label: l.status, good: l.status == 'Da duyet', warn: l.status == 'Cho duyet'), const SizedBox(width: 6), IconButton(icon: const Icon(Icons.delete_outline, color: AppTheme.danger), onPressed: () async { try { await _crud.deleteLeave(l.id); await _load(); } catch (e) { snack(context, '$e'); } })]))),
          )),
    ]);
  }
}
