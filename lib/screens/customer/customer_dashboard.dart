import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/auth.dart';
import '../../widgets/common.dart';
import '../auth/login_screen.dart';
import '../features/group_video_screen.dart';
import '../features/realtime_translate_screen.dart';
/// Role Khách hàng: không thấy dữ liệu nội bộ, chỉ xem thông báo, đặt lịch hẹn, họp video, dịch.
class CustomerDashboard extends StatelessWidget { const CustomerDashboard({super.key}); @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Trang khách hàng'), actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () async { await Auth.logout(); if (context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())); })]),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(gradient: AppTheme.gradient, borderRadius: BorderRadius.all(Radius.circular(24))),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.support_agent_outlined, size: 36, color: Colors.white),
              SizedBox(height: 12),
              Text('Chào mừng quý khách', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
              SizedBox(height: 4),
              Text('Dịch vụ hỗ trợ, họp video và dịch realtime khi trao đổi với nhân viên.', style: TextStyle(fontSize: 14, color: Colors.white70)),
            ]),
          ),
          const SizedBox(height: 14),
          const StatCard(title: 'Chào mừng quý khách', value: 'Dịch vụ hỗ trợ', icon: Icons.support_agent),
          const SizedBox(height: 12),
          const AppCard(child: Text('Thông báo: Lịch làm việc sẽ được nhân viên liên hệ xác nhận. Quý khách không có quyền xem bảng chấm công nội bộ.', style: TextStyle(color: AppTheme.muted))),
          const SizedBox(height: 14),
          AppButton(label: 'Vào phòng họp video với nhân viên', icon: Icons.video_call_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GroupVideoScreen()))),
          const SizedBox(height: 10),
          AppOutlineButton(label: 'Dịch realtime khi trao đổi', icon: Icons.translate_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RealtimeTranslateScreen()))),
        ]),
      );
}
