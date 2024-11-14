import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_version_plus/new_version_plus.dart';

final appVersionProvider = FutureProvider<VersionStatus?>(
    (ref) async => NewVersionPlus().getVersionStatus());
