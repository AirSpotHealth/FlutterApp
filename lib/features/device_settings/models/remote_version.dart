import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/core/utils/app_utils.dart';

class RemoteVersion {
  final String id;
  final String versionName;
  final String availableFor;
  final bool isActive;
  final String fileUrl;
  final String createdAt;
  final String? changeLog;
  final bool requireErase;
  final String? deviceModel;
  final String? fileFormat;

  RemoteVersion({
    required this.id,
    required this.versionName,
    required this.availableFor,
    required this.isActive,
    required this.fileUrl,
    required this.createdAt,
    required this.requireErase,
    this.changeLog,
    this.deviceModel,
    this.fileFormat,
  });

  factory RemoteVersion.fromJson(Map<String, dynamic> json) {
    for (final key in [
      'id',
      'version_name',
      'available_for',
      'file_url',
      'created_at'
    ]) {
      if (json[key] is! String || (json[key] as String).trim().isEmpty) {
        throw FormatException('Invalid firmware response: $key');
      }
    }
    for (final key in ['is_active', 'require_erase']) {
      if (json[key] is! bool) {
        throw FormatException('Invalid firmware response: $key');
      }
    }
    for (final key in ['device_model', 'file_format', 'change_log']) {
      if (json[key] != null && json[key] is! String) {
        throw FormatException('Invalid firmware response: $key');
      }
    }
    return RemoteVersion(
      id: json['id'],
      versionName: json['version_name'],
      availableFor: json['available_for'],
      isActive: json['is_active'],
      fileUrl: json['file_url'],
      createdAt: json['created_at'],
      changeLog: json['change_log'],
      requireErase: json['require_erase'],
      deviceModel: json['device_model'],
      fileFormat: json['file_format'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version_name': versionName,
      'available_for': availableFor,
      'is_active': isActive,
      'file_url': fileUrl,
      'created_at': createdAt,
      'change_log': changeLog,
      'require_erase': requireErase,
      if (deviceModel != null) 'device_model': deviceModel,
      if (fileFormat != null) 'file_format': fileFormat,
    };
  }

  RemoteVersion copyWith({
    String? id,
    String? versionName,
    String? availableFor,
    bool? isActive,
    String? fileUrl,
    String? createdAt,
    String? changeLog,
    bool? requireErase,
    String? deviceModel,
    String? fileFormat,
  }) {
    return RemoteVersion(
      id: id ?? this.id,
      versionName: versionName ?? this.versionName,
      availableFor: availableFor ?? this.availableFor,
      isActive: isActive ?? this.isActive,
      fileUrl: fileUrl ?? this.fileUrl,
      createdAt: createdAt ?? this.createdAt,
      changeLog: changeLog ?? this.changeLog,
      requireErase: requireErase ?? this.requireErase,
      deviceModel: deviceModel ?? this.deviceModel,
      fileFormat: fileFormat ?? this.fileFormat,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RemoteVersion &&
        other.id == id &&
        other.versionName == versionName &&
        other.availableFor == availableFor &&
        other.isActive == isActive &&
        other.fileUrl == fileUrl &&
        other.createdAt == createdAt &&
        other.changeLog == changeLog &&
        other.requireErase == requireErase &&
        other.deviceModel == deviceModel &&
        other.fileFormat == fileFormat;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        versionName.hashCode ^
        availableFor.hashCode ^
        isActive.hashCode ^
        fileUrl.hashCode ^
        createdAt.hashCode ^
        changeLog.hashCode ^
        requireErase.hashCode ^
        deviceModel.hashCode ^
        fileFormat.hashCode;
  }

  @override
  String toString() {
    return 'RemoteVersion(id: $id, versionName: $versionName, availableFor: $availableFor, isActive: $isActive, fileUrl: $fileUrl, createdAt: $createdAt, changeLog: $changeLog, requireErase: $requireErase)';
  }

  String get downloadUrl => fileUrl;

  void validateForDevice(DeviceModel model) {
    final slim = model == DeviceModel.airspotSlim;
    if (slim
        ? deviceModel != 'slim'
        : deviceModel != null && deviceModel != 'screen') {
      throw const FormatException('Firmware does not match this device model');
    }
    final uri = Uri.tryParse(fileUrl);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      throw const FormatException(
          'Firmware download URL is missing or invalid');
    }
    if (slim) {
      if (fileFormat != 'bin' && fileFormat != 'zip') {
        throw const FormatException(
            'Slim firmware requires BIN or ZIP format metadata');
      }
      slimVersionParts(versionName);
    }
  }

  // MCUboot exposes major.minor.revision. Reject ambiguous release labels.
  static List<int> slimVersionParts(String version) {
    final match = RegExp(r'^v?(\d+)\.(\d+)\.(\d+)$').firstMatch(version);
    if (match == null) {
      throw const FormatException('Invalid Slim firmware version');
    }
    final parts = [for (var i = 1; i <= 3; i++) int.parse(match.group(i)!)];
    if (parts[0] > 255 || parts[1] > 255 || parts[2] > 65535) {
      throw const FormatException('Invalid Slim firmware version');
    }
    return parts;
  }

  bool isVersionGreaterThanCurrentVersion(String? currentVersion) {
    if (currentVersion == null) {
      return false;
    }

    if (deviceModel == 'slim') {
      try {
        final current = slimVersionParts(currentVersion);
        final target = slimVersionParts(versionName);
        for (var i = 0; i < 3; i++) {
          if (target[i] != current[i]) return target[i] > current[i];
        }
        return false;
      } on FormatException {
        return false;
      }
    }
    return AppUtils.isVersionGreater(currentVersion, versionName);
  }
}
