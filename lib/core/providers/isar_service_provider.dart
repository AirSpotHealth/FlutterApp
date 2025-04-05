import 'package:airspothealth/core/services/isar_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final isarServiceProvider = Provider<IsarService>((ref) {
  final isarService = IsarService();
  return isarService;
});
