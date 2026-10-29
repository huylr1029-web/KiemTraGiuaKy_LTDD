import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
/// 5f - Dịch realtime: nói -> dịch -> đọc; ảnh chụp -> OCR -> dịch.
/// Dịch bằng GoogleTranslator (cần mạng). Không mạng: dùng cụm từ mẫu bên dưới.
class RealtimeTranslateScreen extends StatefulWidget { const RealtimeTranslateScreen({super.key}); @override State<RealtimeTranslateScreen> createState() => _T(); }
class _T extends State<RealtimeTranslateScreen> {
  final _in = TextEditingController(); String _out = ''; String _to = 'en'; bool _busy = false;
  final _stt = SpeechToText(); final _tts = FlutterTts(); bool _listening = false;
  Future<void> _translate() async {
    if (_in.text.isEmpty) return; setState(() => _busy = true);
    try { final r = await GoogleTranslator().translate(_in.text, from: 'auto', to: _to); setState(() => _out = r.text); } catch (_) { setState(() => _out = 'Không dịch được (cần mạng). Thử: Hello -> Xin chào, Good morning -> Chào buổi sáng.'); }
    setState(() => _busy = false);
  }
  Future<void> _listen() async {
    if (_listening) { await _stt.stop(); setState(() => _listening = false); return; }
    final ok = await _stt.initialize(); if (!ok) { snack(context, 'Không khởi động được microphone'); return; }
    setState(() => _listening = true);
    await _stt.listen(onResult: (r) => setState(() => _in.text = r.recognizedWords));
  }
  Future<void> _ocr() async {
    final x = await ImagePicker().pickImage(source: ImageSource.camera); if (x == null) return;
    final rec = TextRecognizer(); final res = await rec.processImage(InputImage.fromFile(File(x.path))); await rec.close();
    setState(() => _in.text = res.text); await _translate();
  }
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Dịch realtime')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SectionTitle(title: 'Nói, chụp ảnh rồi dịch', subtitle: 'Nói vào micro, hoặc chụp ảnh văn bản để OCR rồi dịch và đọc lên.'),
            Row(children: [
              const Text('Dịch sang: ', style: TextStyle(fontWeight: FontWeight.w700)),
              Expanded(child: DropdownButton<String>(value: _to, isExpanded: true, items: const [DropdownMenuItem(value: 'en', child: Text('Tiếng Anh')), DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')), DropdownMenuItem(value: 'zh-cn', child: Text('Tiếng Trung')), DropdownMenuItem(value: 'ja', child: Text('Tiếng Nhật'))], onChanged: (v) => setState(() => _to = v ?? 'en'))),
            ]),
            const SizedBox(height: 12),
            AppField(c: _in, hint: 'Nhập, nói hoặc chụp ảnh văn bản...', label: 'Văn bản cần dịch', prefixIcon: Icons.translate_outlined),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: AppButton(label: 'Dịch ngay', icon: Icons.translate, loading: _busy, onTap: _translate)),
              const SizedBox(width: 8),
              Container(decoration: BoxDecoration(color: _listening ? const Color(0xFFFEE2E2) : AppTheme.tealSoft, borderRadius: BorderRadius.circular(14)), child: IconButton(onPressed: _listen, icon: Icon(_listening ? Icons.mic_off : Icons.mic, color: AppTheme.danger))),
              const SizedBox(width: 8),
              Container(decoration: BoxDecoration(color: AppTheme.tealSoft, borderRadius: BorderRadius.circular(14)), child: IconButton(onPressed: _ocr, icon: const Icon(Icons.camera_alt_outlined, color: AppTheme.teal))),
            ]),
            const SizedBox(height: 16),
            if (_out.isNotEmpty) AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_out, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)), const SizedBox(height: 8), TextButton.icon(onPressed: () => _tts.speak(_out), icon: const Icon(Icons.volume_up_outlined), label: const Text('Đọc bản dịch'))])),
          ]),
        ),
      );
}
