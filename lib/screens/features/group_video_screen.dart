import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
/// 5c - Gọi video nhóm: phòng Jitsi thật, không cần key/token.
/// Nhập tên phòng -> mở Jitsi (app hoặc trình duyệt), cả nhóm vào cùng tên phòng là gặp nhau.
class GroupVideoScreen extends StatefulWidget { const GroupVideoScreen({super.key}); @override State<GroupVideoScreen> createState() => _V(); }
class _V extends State<GroupVideoScreen> {
  final _room = TextEditingController(text: 'lethanhhuy0827-hop-sang');
  Future<void> _join() async {
    final room = _room.text.trim().replaceAll(RegExp(r'[^a-zA-Z0-9\-]'), '-');
    if (room.isEmpty) { snack(context, 'Nhập tên phòng'); return; }
    final uri = Uri.parse('https://meet.jit.si/$room');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) snack(context, 'Không mở được phòng họp');
  }
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Gọi video nhóm')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SectionTitle(title: 'Phòng họp Jitsi Meet', subtitle: 'Mọi thành viên nhập CÙNG tên phòng rồi bấm Vào phòng - không cần tài khoản, không cần key.'),
            AppField(c: _room, hint: 'Ví dụ: lethanhhuy0827-hop-sang', label: 'Tên phòng', prefixIcon: Icons.video_call_outlined),
            const SizedBox(height: 16),
            AppButton(label: 'Vào phòng video nhóm', icon: Icons.videocam_outlined, onTap: _join),
            const SizedBox(height: 14),
            const AppCard(
              child: Text('Thuyết trình nói rõ: đây là Jitsi Meet (WebRTC) như Zoom/Meet, khác với "video giả lập" chỉ hiện camera của mình. Nếu muốn nhúng video trong app thì dùng jitsi_meet_flutter_sdk hoặc Agora (cần token).', style: TextStyle(fontSize: 13, color: AppTheme.muted)),
            ),
          ]),
        ),
      );
}
