import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
/// Face login / face check-in (de bai muc 5a).
/// ML Kit chi dem + dinh vi khuon mat tren anh, KHONG phai so khop sinh trac 1-1.
/// Ban nay chat hon ban dem don thuan: yeu cau dung 1 khuon mat, nhin thang
/// (goc xoay dau nho), mo mat (neu ML Kit do duoc). Day la buoc loc anh chat luong
/// + chong anh mo / anh nghieng don gian, KHONG phai chong gia mao chuyen nghiep.
/// So khop sinh trac day du (FaceNet embedding + server) van la buoc nang cap,
/// da ghi ro trong README de khong "nhan vo" la nhan dien that khi demo.
class FaceCheck {
  final int count;
  final bool ok;
  final String reason;
  const FaceCheck(this.count, this.ok, this.reason);
}
class FaceService {
  static Future<File?> pickFaceImage(ImageSource src) async {
    final x = await ImagePicker().pickImage(source: src, imageQuality: 80);
    return x == null ? null : File(x.path);
  }
  static Future<int> countFaces(File img) async => (await checkFace(img)).count;
  static Future<FaceCheck> checkFace(File img) async {
    final input = InputImage.fromFile(img);
    final detector = FaceDetector(options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableClassification: true,
      enableLandmarks: true,
      minFaceSize: 0.15,
    ));
    try {
      final faces = await detector.processImage(input);
      if (faces.isEmpty) return const FaceCheck(0, false, 'Không thấy khuôn mặt, hãy chụp lại rõ mặt hơn');
      if (faces.length != 1) return FaceCheck(faces.length, false, 'Ảnh phải có đúng 1 khuôn mặt, hiện có ${faces.length} khuôn mặt');
      final f = faces.first;
      if (f.headEulerAngleY != null && f.headEulerAngleY!.abs() > 20) return const FaceCheck(1, false, 'Hãy nhìn thẳng vào camera, đừng quay mặt sang bên');
      if (f.headEulerAngleZ != null && f.headEulerAngleZ!.abs() > 20) return const FaceCheck(1, false, 'Hãy giữ đầu thẳng, đừng nghiêng đầu');
      if (f.leftEyeOpenProbability != null && f.leftEyeOpenProbability! < 0.5) return const FaceCheck(1, false, 'Hãy mở mắt khi chụp');
      if (f.rightEyeOpenProbability != null && f.rightEyeOpenProbability! < 0.5) return const FaceCheck(1, false, 'Hãy mở mắt khi chụp');
      return const FaceCheck(1, true, 'Khuôn mặt hợp lệ');
    } finally { await detector.close(); }
  }
}
