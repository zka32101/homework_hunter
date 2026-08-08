import 'package:flutter/foundation.dart';

/// Firebase Analytics 未接続のため、現状はデバッグ出力のみ。
/// Firebase 本設定後は flutter-firebase-setup スキルの手順で
/// firebase_analytics 呼び出しに差し替える。
class AnalyticsService {
  Future<void> logEvent(String name, {Map<String, Object?> parameters = const {}}) async {
    if (kDebugMode) {
      debugPrint('[analytics] $name $parameters');
    }
  }
}
