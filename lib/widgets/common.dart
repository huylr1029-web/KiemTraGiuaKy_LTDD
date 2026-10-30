import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Widget dùng chung, đã làm lại cho đẹp và dễ dùng.
/// Giữ nguyên tên và tham số cũ (AppField, AppButton, StatCard) để
/// các màn hình cũ không phải đổi logic, chỉ thêm tham số tùy chọn.
class AppField extends StatelessWidget {
  final TextEditingController c;
  final String hint;
  final String? label;
  final IconData? prefixIcon;
  final bool obscure;
  final TextInputType? type;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final Iterable<String>? autofillHints;
  const AppField({super.key, required this.c, required this.hint, this.label, this.prefixIcon, this.obscure = false, this.type, this.suffix, this.onChanged, this.autofillHints});
  @override
  Widget build(BuildContext context) => TextField(
        controller: c,
        obscureText: obscure,
        keyboardType: type,
        onChanged: onChanged,
        autofillHints: autofillHints,
        decoration: InputDecoration(
          hintText: hint,
          labelText: label,
          prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, color: AppTheme.teal),
          suffixIcon: suffix,
        ),
      );
}

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final IconData? icon;
  const AppButton({super.key, required this.label, this.onTap, this.loading = false, this.icon});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: loading ? null : onTap,
          child: loading
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
              : Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                  if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
                  Text(label),
                ]),
        ),
      );
}

class AppOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  const AppOutlineButton({super.key, required this.label, this.onTap, this.icon});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon ?? Icons.arrow_forward, size: 20),
          label: Text(label),
        ),
      );
}

/// Thẻ thống kê: biểu tượng trong vòng màu nhạt, số lớn, tiêu đề nhỏ.
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const StatCard({super.key, required this.title, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: AppTheme.tealSoft, borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: AppTheme.teal),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                const SizedBox(height: 2),
                Text(title, style: const TextStyle(fontSize: 13, color: AppTheme.muted)),
              ]),
            ),
          ]),
        ),
      );
}

/// Tiêu đề nhóm nội dung trong một màn hình.
class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  const SectionTitle({super.key, required this.title, this.subtitle});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink)),
          if (subtitle != null) ...[const SizedBox(height: 2), Text(subtitle!, style: const TextStyle(fontSize: 13, color: AppTheme.muted))],
        ]),
      );
}

/// Nhãn trạng thái nhỏ, có màu theo ý nghĩa: xanh = tốt, đỏ = cần chú ý, vàng = chờ duyệt.
class StatusChip extends StatelessWidget {
  final String label;
  final bool good;
  final bool warn;
  const StatusChip({super.key, required this.label, this.good = false, this.warn = false});
  @override
  Widget build(BuildContext context) {
    final bg = good ? const Color(0xFFDCFCE7) : warn ? const Color(0xFFFEF3C7) : AppTheme.tealSoft;
    final fg = good ? AppTheme.success : warn ? const Color(0xFFB45309) : AppTheme.tealDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

/// Khung nội dung dạng thẻ, dùng cho danh sách để khỏi dính sát lề.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: padding, child: child));
}

void snack(BuildContext ctx, String msg, {bool ok = false}) => ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: ok ? AppTheme.success : AppTheme.danger),
    );
