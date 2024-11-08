class RemoteVersion {
  final String id;
  final String versionName;
  final String availableFor;
  final bool isActive;
  final String fileUrl;
  final String createdAt;
  final String? changeLog;

  RemoteVersion({
    required this.id,
    required this.versionName,
    required this.availableFor,
    required this.isActive,
    required this.fileUrl,
    required this.createdAt,
    this.changeLog,
  });

  factory RemoteVersion.fromJson(Map<String, dynamic> json) {
    return RemoteVersion(
      id: json['id'],
      versionName: json['version_name'],
      availableFor: json['available_for'],
      isActive: json['is_active'],
      fileUrl: json['file_url'],
      createdAt: json['created_at'],
      changeLog: json['change_log'],
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
  }) {
    return RemoteVersion(
      id: id ?? this.id,
      versionName: versionName ?? this.versionName,
      availableFor: availableFor ?? this.availableFor,
      isActive: isActive ?? this.isActive,
      fileUrl: fileUrl ?? this.fileUrl,
      createdAt: createdAt ?? this.createdAt,
      changeLog: changeLog ?? this.changeLog,
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
        other.changeLog == changeLog;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        versionName.hashCode ^
        availableFor.hashCode ^
        isActive.hashCode ^
        fileUrl.hashCode ^
        createdAt.hashCode ^
        changeLog.hashCode;
  }

  @override
  String toString() {
    return 'RemoteVersion(id: $id, versionName: $versionName, availableFor: $availableFor, isActive: $isActive, fileUrl: $fileUrl, createdAt: $createdAt, changeLog: $changeLog)';
  }

  String get downloadUrl => fileUrl;
}
