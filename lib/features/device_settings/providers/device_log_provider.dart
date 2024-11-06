import 'package:airspothealth/core/services/data_logger_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deviceLogProvider = FutureProvider.family<String, String>(
    (ref, arg) => DataLoggerService().readLogData(arg));
