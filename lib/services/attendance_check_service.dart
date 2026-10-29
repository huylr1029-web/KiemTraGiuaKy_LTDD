import 'package:geolocator/geolocator.dart';
import 'package:network_info_plus/network_info_plus.dart';
import '../config/config_url.dart';
/// TINH NANG MOI (de bai muc 6) - Cham cong chong gian lan 3 lop:
/// 1) GPS trong vong ban kinh van phong, 2) WiFi van phong, 3) Khuon mat (o face_service).
/// Khong chan cung: neu 1 lop fail thi ghi "Can duyet" de Admin xac minh, tranh
/// truong hop GPS lech / WiFi khong doc duoc tren iOS lam mat cong cua nhan vien.
class CheckResult { final bool gpsOk; final bool wifiOk; final String wifiName; final double distanceM; final String verdict; CheckResult(this.gpsOk, this.wifiOk, this.wifiName, this.distanceM, this.verdict); }
class AttendanceCheckService {
  static Future<CheckResult> verify() async {
    double dist = -1; bool gpsOk = false;
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm != LocationPermission.deniedForever && perm != LocationPermission.denied) {
        final pos = await Geolocator.getCurrentPosition();
        dist = Geolocator.distanceBetween(pos.latitude, pos.longitude, ConfigUrl.officeLat, ConfigUrl.officeLng);
        gpsOk = dist <= ConfigUrl.officeRadiusM;
      }
    } catch (_) {}
    String wifi = ''; bool wifiOk = false;
    try { wifi = (await NetworkInfo().getWifiName()) ?? ''; wifi = wifi.replaceAll('"', ''); wifiOk = wifi == ConfigUrl.officeWifi; } catch (_) {}
    final verdict = (gpsOk && wifiOk) ? 'Hop le' : (gpsOk || wifiOk) ? 'Can duyet (1 lop chua dat)' : 'Can duyet (GPS + WiFi chua dat)';
    return CheckResult(gpsOk, wifiOk, wifi.isEmpty ? 'Khong doc duoc' : wifi, dist, verdict);
  }
}
