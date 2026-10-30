import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/models.dart';
import '../../services/attendance_check_service.dart';
import '../../services/crud_service.dart';
import '../../services/face_service.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
class CheckinScreen extends StatefulWidget { final Employee? me; const CheckinScreen({super.key, this.me}); @override State<CheckinScreen> createState() => _C(); }
class _C extends State<CheckinScreen> {
  CheckResult? _res; int _faces = -1; bool _busy = false; String _type = 'Vao ca'; bool _faceOk = false; String _faceReason = '';
  Future<void> _check() async {
    setState(() => _busy = true);
    final img = await FaceService.pickFaceImage(ImageSource.camera);
    if (img != null) { final check = await FaceService.checkFace(img); _faces = check.count; _faceOk = check.ok; _faceReason = check.reason; }
    _res = await AttendanceCheckService.verify();
    setState(() => _busy = false);
  }
  Future<void> _save() async {
    if (_res == null) { snack(context, 'Hãy bấm Kiểm tra trước'); return; }
    if (_faces == 0 || !_faceOk) { snack(context, _faceReason.isEmpty ? 'Không thấy khuôn mặt, không thể chấm công' : _faceReason); return; }
    var me = widget.me;
    me ??= await CrudService().me();
    final id = me?.id ?? await StorageService.getString('current_employee_id');
    if (id == null) { snack(context, 'Không xác định được nhân viên từ API'); return; }
    final now = DateTime.now();
    final status = _res!.verdict == 'Hop le' ? 'Di lam' : 'Can duyet';
    final note = 'Face: $_faces khuon mat | GPS: ${_res!.distanceM < 0 ? 'khong xac dinh' : '${_res!.distanceM.toStringAsFixed(0)}m'} | WiFi: ${_res!.wifiName} | ${_res!.verdict}';
    try {
      await CrudService().addAttendance(Attendance(id: '0', employeeId: id, employeeName: me?.name ?? '', date: now, checkIn: _type == 'Vao ca' ? now : null, checkOut: _type == 'Tan ca' ? now : null, status: status, note: note));
      if (mounted) { snack(context, 'Đã ghi nhận qua API: $status', ok: true); Navigator.pop(context); }
    } catch (e) { snack(context, '$e'); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Chấm công')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SectionTitle(title: 'Chấm công chống gian lận', subtitle: 'Bước 1: chụp mặt và kiểm tra GPS/WiFi. Bước 2: gửi bản chấm công lên API.'),
            DropdownButtonFormField<String>(initialValue: _type, decoration: const InputDecoration(labelText: 'Loại chấm công'), items: const [DropdownMenuItem(value: 'Vao ca', child: Text('Vào ca')), DropdownMenuItem(value: 'Tan ca', child: Text('Tan ca'))], onChanged: (v) => setState(() => _type = v ?? 'Vao ca')),
            const SizedBox(height: 16),
            AppButton(label: 'Chụp mặt & kiểm tra GPS/WiFi', icon: Icons.camera_alt_outlined, loading: _busy, onTap: _check),
            if (_faces >= 0) Padding(padding: const EdgeInsets.only(top: 14), child: StatusChip(label: _faceReason.isEmpty ? 'Khuôn mặt phát hiện: $_faces' : _faceReason, good: _faceOk, warn: !_faceOk)),
            if (_res != null) Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: AppCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [const Icon(Icons.location_on_outlined, color: AppTheme.teal, size: 20), const SizedBox(width: 8), Expanded(child: Text('GPS: ${_res!.gpsOk ? 'Trong văn phòng' : 'Ngoài văn phòng / không xác định'} (${_res!.distanceM < 0 ? '?' : '${_res!.distanceM.toStringAsFixed(0)}m'})'))]),
                      const SizedBox(height: 10),
                      Row(children: [const Icon(Icons.wifi_outlined, color: AppTheme.teal, size: 20), const SizedBox(width: 8), Expanded(child: Text('WiFi: ${_res!.wifiName} (${_res!.wifiOk ? 'Đúng WiFi công ty' : 'Chưa khớp'})'))]),
                      const SizedBox(height: 12),
                      StatusChip(label: 'Kết luận: ${_res!.verdict}', good: _res!.verdict == 'Hop le', warn: _res!.verdict != 'Hop le'),
                      if (_res!.wifiName == 'Không đọc được') const Padding(padding: EdgeInsets.only(top: 10), child: Text('Không đọc được tên WiFi: hãy bật Vị trí, kết nối đúng WiFi công ty rồi kiểm tra lại. Bản ghi vẫn lưu dạng Cần duyệt để Admin xác minh.', style: TextStyle(fontSize: 12, color: AppTheme.muted))),
                    ]),
                  ),
                ),
            const Spacer(),
            AppButton(label: 'Xác nhận chấm công', icon: Icons.check_circle_outline, onTap: _save),
            const SizedBox(height: 10),
            const Text('Lưu ý: nếu GPS/WiFi chưa khớp, bản ghi vẫn được lưu dạng "Cần duyệt" để Admin xác minh - không mất công oan.', style: TextStyle(fontSize: 12, color: AppTheme.muted), textAlign: TextAlign.center),
          ]),
        ),
      );
}
