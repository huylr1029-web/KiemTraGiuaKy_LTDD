// Model Tuan 6 (Product) -> anh xa sang bai cham cong:
// Product/CRUD + Category  ==>  Employee/CRUD + Department (xoa phong ban -> nhan vien ve "Chua phan phong")
class Employee {
  final String id; String name; String email; String role; String? departmentId; String position;
  Employee({required this.id, required this.name, required this.email, required this.role, this.departmentId, this.position = 'Nhan vien'});
  factory Employee.fromJson(Map<String, dynamic> j) => Employee(id: '${j['id']}', name: j['name'] ?? '', email: j['email'] ?? '', role: j['role'] ?? 'Employee', departmentId: j['departmentId']?.toString(), position: j['position'] ?? 'Nhan vien');
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email, 'role': role, 'departmentId': departmentId, 'position': position};
}
class Department {
  final String id; String name;
  Department({required this.id, required this.name});
  factory Department.fromJson(Map<String, dynamic> j) => Department(id: '${j['id']}', name: j['name'] ?? '');
  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
class Attendance {
  final String id; String employeeId; String employeeName; DateTime date; DateTime? checkIn; DateTime? checkOut; String status; String note;
  Attendance({required this.id, required this.employeeId, required this.employeeName, required this.date, this.checkIn, this.checkOut, this.status = 'Di lam', this.note = ''});
  factory Attendance.fromJson(Map<String, dynamic> j) => Attendance(id: '${j['id']}', employeeId: '${j['employeeId']}', employeeName: j['employeeName'] ?? '', date: DateTime.tryParse('${j['date']}') ?? DateTime.now(), checkIn: j['checkIn'] == null ? null : DateTime.tryParse('${j['checkIn']}'), checkOut: j['checkOut'] == null ? null : DateTime.tryParse('${j['checkOut']}'), status: j['status'] ?? 'Di lam', note: j['note'] ?? '');
  Map<String, dynamic> toJson() => {'id': id, 'employeeId': employeeId, 'employeeName': employeeName, 'date': date.toIso8601String(), 'checkIn': checkIn?.toIso8601String(), 'checkOut': checkOut?.toIso8601String(), 'status': status, 'note': note};
  double get hours => (checkIn != null && checkOut != null) ? checkOut!.difference(checkIn!).inMinutes / 60 : 0;
}
class Appointment {
  final String id; String customerName; String customerEmail; DateTime date; String reason; String status;
  Appointment({required this.id, required this.customerName, required this.customerEmail, required this.date, required this.reason, this.status = 'Cho xac nhan'});
  factory Appointment.fromJson(Map<String, dynamic> j) => Appointment(id: '${j['id']}', customerName: j['customerName'] ?? '', customerEmail: j['customerEmail'] ?? '', date: DateTime.tryParse('${j['date']}') ?? DateTime.now(), reason: j['reason'] ?? '', status: j['status'] ?? 'Cho xac nhan');
  Map<String, dynamic> toJson() => {'id': id, 'customerName': customerName, 'customerEmail': customerEmail, 'date': date.toIso8601String(), 'reason': reason, 'status': status};
}
class LeaveRequest {
  final String id; String employeeId; String employeeName; DateTime from; DateTime to; String reason; String status;
  LeaveRequest({required this.id, required this.employeeId, required this.employeeName, required this.from, required this.to, required this.reason, this.status = 'Cho duyet'});
  factory LeaveRequest.fromJson(Map<String, dynamic> j) => LeaveRequest(id: '${j['id']}', employeeId: '${j['employeeId']}', employeeName: j['employeeName'] ?? '', from: DateTime.tryParse('${j['from']}') ?? DateTime.now(), to: DateTime.tryParse('${j['to']}') ?? DateTime.now(), reason: j['reason'] ?? '', status: j['status'] ?? 'Cho duyet');
  Map<String, dynamic> toJson() => {'id': id, 'employeeId': employeeId, 'employeeName': employeeName, 'from': from.toIso8601String(), 'to': to.toIso8601String(), 'reason': reason, 'status': status};
}
