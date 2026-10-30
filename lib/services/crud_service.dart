import 'dart:convert';
import '../models/models.dart';
import 'api_client.dart';
/// CRUD Tuan 6 qua API (Repository o backend) - KHONG co store local.
/// Moi ham deu goi ApiClient; loi mang tra ve danh sach rong + throw de man hinh hien loi.
class CrudService {
  final _api = ApiClient();
  Future<List<Employee>> employees({String? search}) async {
    final ep = search == null || search.isEmpty ? 'EmployeeApi' : 'EmployeeApi/search?name=${Uri.encodeComponent(search)}';
    final r = await _api.get(ep);
    if (r.statusCode != 200) throw Exception('Khong tai duoc danh sach nhan vien (${r.statusCode})');
    return (jsonDecode(r.body) as List).map((e) => Employee.fromJson(e)).toList();
  }
  Future<Employee?> me() async {
    final r = await _api.get('EmployeeApi/me');
    if (r.statusCode != 200) return null;
    return Employee.fromJson(jsonDecode(r.body));
  }
  Future<void> addEmployee(Employee e) async => _check(await _api.post('EmployeeApi', body: e.toJson()));
  Future<void> updateEmployee(Employee e) async => _check(await _api.put('EmployeeApi/${e.id}', body: e.toJson()));
  Future<void> deleteEmployee(String id) async => _check(await _api.delete('EmployeeApi/$id'));
  Future<List<Department>> departments() async {
    final r = await _api.get('DepartmentApi');
    if (r.statusCode != 200) throw Exception('Khong tai duoc phong ban (${r.statusCode})');
    return (jsonDecode(r.body) as List).map((e) => Department.fromJson(e)).toList();
  }
  Future<void> addDepartment(Department d) async => _check(await _api.post('DepartmentApi', body: d.toJson()));
  Future<void> updateDepartment(Department d) async => _check(await _api.put('DepartmentApi/${d.id}', body: d.toJson()));
  Future<void> deleteDepartment(String id) async => _check(await _api.delete('DepartmentApi/$id'));
  Future<List<Attendance>> attendances({String? employeeId}) async {
    final ep = employeeId == null ? 'AttendanceApi' : 'AttendanceApi?employeeId=$employeeId';
    final r = await _api.get(ep);
    if (r.statusCode != 200) throw Exception('Khong tai duoc cham cong (${r.statusCode})');
    return (jsonDecode(r.body) as List).map((e) => Attendance.fromJson(e)).toList();
  }
  Future<void> addAttendance(Attendance a) async => _check(await _api.post('AttendanceApi', body: a.toJson()));
  Future<void> updateAttendance(Attendance a) async => _check(await _api.put('AttendanceApi/${a.id}', body: a.toJson()));
  Future<void> deleteAttendance(String id) async => _check(await _api.delete('AttendanceApi/$id'));
  Future<List<LeaveRequest>> leaves({String? employeeId}) async {
    final ep = employeeId == null ? 'LeaveApi' : 'LeaveApi?employeeId=$employeeId';
    final r = await _api.get(ep);
    if (r.statusCode != 200) throw Exception('Khong tai duoc don nghi (${r.statusCode})');
    return (jsonDecode(r.body) as List).map((e) => LeaveRequest.fromJson(e)).toList();
  }
  Future<void> addLeave(LeaveRequest l) async => _check(await _api.post('LeaveApi', body: l.toJson()));
  Future<void> updateLeave(LeaveRequest l) async => _check(await _api.put('LeaveApi/${l.id}', body: l.toJson()));
  Future<void> deleteLeave(String id) async => _check(await _api.delete('LeaveApi/$id'));
  Future<List<Appointment>> appointments({String? email}) async {
    final ep = email == null || email.isEmpty ? 'AppointmentApi' : 'AppointmentApi?email=${Uri.encodeComponent(email)}';
    final r = await _api.get(ep);
    if (r.statusCode != 200) throw Exception('Khong tai duoc lich hen (${r.statusCode})');
    return (jsonDecode(r.body) as List).map((e) => Appointment.fromJson(e)).toList();
  }
  Future<void> addAppointment(Appointment a) async => _check(await _api.post('AppointmentApi', body: a.toJson()));
  Future<void> updateAppointment(Appointment a) async => _check(await _api.put('AppointmentApi/${a.id}', body: a.toJson()));
  Future<void> deleteAppointment(String id) async => _check(await _api.delete('AppointmentApi/$id'));
  void _check(dynamic r) { if (r.statusCode < 200 || r.statusCode >= 300) throw Exception('API loi ${r.statusCode}: ${r.body}'); }
  String deptName(List<Department> ds, String? id) { for (final d in ds) { if (d.id == id) return d.name; } return 'Chua phan phong'; }
}
