import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/face_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../auth/login_screen.dart';
/// 5a - Đăng nhập bằng khuôn mặt, KHÔNG bypass API:
/// Khuôn mặt là bước xác minh thiết bị trước khi đăng nhập bằng mật khẩu + OTP qua API.
/// (So khớp sinh trắc 1-1 thật cần server FaceNet - đã ghi rõ trong README.)
class FaceLoginScreen extends StatefulWidget { const FaceLoginScreen({super.key}); @override State<FaceLoginScreen> createState() => _F(); }
class _F extends State<FaceLoginScreen> {
  File? _img; int _faces = -1; bool _busy = false;
  Future<void> _capture() async { setState(() => _busy = true); final f = await FaceService.pickFaceImage(ImageSource.camera); if (f != null) { _img = f; _faces = await FaceService.countFaces(f); } setState(() => _busy = false); }
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Đăng nhập bằng khuôn mặt')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SectionTitle(title: 'Bước 1: chụp khuôn mặt', subtitle: 'Ảnh phải có đúng 1 khuôn mặt. Bước 2 vẫn đăng nhập bằng mật khẩu + OTP qua API như bình thường.'),
            if (_img != null) ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.file(_img!, height: 240, fit: BoxFit.cover)) else Container(height: 200, decoration: BoxDecoration(color: AppTheme.tealSoft, borderRadius: BorderRadius.circular(20)), child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.face_outlined, size: 56, color: AppTheme.teal), SizedBox(height: 8), Text('Chưa có ảnh khuôn mặt', style: TextStyle(color: AppTheme.muted))])),
            if (_faces >= 0) Padding(padding: const EdgeInsets.only(top: 14), child: StatusChip(label: 'Phát hiện: $_faces khuôn mặt', good: _faces == 1, warn: _faces != 1)),
            const SizedBox(height: 16),
            AppButton(label: 'Chụp khuôn mặt', icon: Icons.camera_alt_outlined, loading: _busy, onTap: _capture),
            const SizedBox(height: 10),
            AppOutlineButton(label: 'Tiếp tục đăng nhập (mật khẩu + OTP)', icon: Icons.login_outlined, onTap: () { if (_faces != 1) { snack(context, 'Cần đúng 1 khuôn mặt mới tiếp tục'); return; } Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())); }),
            const SizedBox(height: 12),
            const Text('Giới hạn trung thực: ML Kit đếm khuôn mặt, chưa phải so khớp sinh trắc 1-1. Bản thật cần FaceNet embedding + đối chiếu server, kèm chống giả mạo.', style: TextStyle(fontSize: 12, color: AppTheme.muted), textAlign: TextAlign.center),
          ]),
        ),
      );
}
