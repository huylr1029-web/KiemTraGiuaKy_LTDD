import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
/// Face login / face check-in (de bai muc 5a).
/// ML Kit chi dem + dinh vi khuon mat tren anh. Ban nay:
/// - Dang ky khuon mat: chup anh, yeu cau co dung 1 khuon mat, luu duong dan anh.
/// - Dang nhap/check-in: chup anh moi, yeu cau co khuon mat; so khop sinh trac
///   day du (FaceNet embedding + server) la buoc nang cap, da ghi ro trong README
///   de khong "nhan vo" la nhan dien that khi demo.
class FaceService {
  static Future<File?> pickFaceImage(ImageSource src) async {
    final x = await ImagePicker().pickImage(source: src, imageQuality: 80);
    return x == null ? null : File(x.path);
  }
  static Future<int> countFaces(File img) async {
    final input = InputImage.fromFile(img);
    final detector = FaceDetector(options: FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate));
    try { final faces = await detector.processImage(input); return faces.length; } finally { await detector.close(); }
  }
}
