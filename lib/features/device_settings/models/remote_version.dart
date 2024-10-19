// {"code":1,"msg":"Operation completed","time":"1729074121","data":{"id":20,"version_id":"1.2.5","system_type":"2","update_type":"1","notice_type":"1","createtime":"2024-07-23 10:55:23","createid":1,"updatetime":"2024-09-11 00:14:21","updateid":1,"status":1,"img":"\/uploads\/20240911\/0c490bf087f83a583c074c7501b908fb.zip","update_content":"修改airgraph\r\n修改ppm不及时的问题"}}

class RemoteVersion {
  final int id;
  final String versionId;
  final String systemType;
  final String updateType;
  final String noticeType;
  final String createTime;
  final int createId;
  final String updateTime;
  final int updateId;
  final int status;
  final String img;
  final String updateContent;

  RemoteVersion({
    required this.id,
    required this.versionId,
    required this.systemType,
    required this.updateType,
    required this.noticeType,
    required this.createTime,
    required this.createId,
    required this.updateTime,
    required this.updateId,
    required this.status,
    required this.img,
    required this.updateContent,
  });

  factory RemoteVersion.fromJson(Map<String, dynamic> json) {
    return RemoteVersion(
      id: json['id'],
      versionId: json['version_id'],
      systemType: json['system_type'],
      updateType: json['update_type'],
      noticeType: json['notice_type'],
      createTime: json['createtime'],
      createId: json['createid'],
      updateTime: json['updatetime'],
      updateId: json['updateid'],
      status: json['status'],
      img: json['img'],
      updateContent: json['update_content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version_id': versionId,
      'system_type': systemType,
      'update_type': updateType,
      'notice_type': noticeType,
      'createtime': createTime,
      'createid': createId,
      'updatetime': updateTime,
      'updateid': updateId,
      'status': status,
      'img': img,
      'update_content': updateContent,
    };
  }

  RemoteVersion copyWith({
    int? id,
    String? versionId,
    String? systemType,
    String? updateType,
    String? noticeType,
    String? createTime,
    int? createId,
    String? updateTime,
    int? updateId,
    int? status,
    String? img,
    String? updateContent,
  }) {
    return RemoteVersion(
      id: id ?? this.id,
      versionId: versionId ?? this.versionId,
      systemType: systemType ?? this.systemType,
      updateType: updateType ?? this.updateType,
      noticeType: noticeType ?? this.noticeType,
      createTime: createTime ?? this.createTime,
      createId: createId ?? this.createId,
      updateTime: updateTime ?? this.updateTime,
      updateId: updateId ?? this.updateId,
      status: status ?? this.status,
      img: img ?? this.img,
      updateContent: updateContent ?? this.updateContent,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RemoteVersion &&
        other.id == id &&
        other.versionId == versionId &&
        other.systemType == systemType &&
        other.updateType == updateType &&
        other.noticeType == noticeType &&
        other.createTime == createTime &&
        other.createId == createId &&
        other.updateTime == updateTime &&
        other.updateId == updateId &&
        other.status == status &&
        other.img == img &&
        other.updateContent == updateContent;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        versionId.hashCode ^
        systemType.hashCode ^
        updateType.hashCode ^
        noticeType.hashCode ^
        createTime.hashCode ^
        createId.hashCode ^
        updateTime.hashCode ^
        updateId.hashCode ^
        status.hashCode ^
        img.hashCode ^
        updateContent.hashCode;
  }

  @override
  String toString() {
    return 'RemoteVersion(id: $id, versionId: $versionId, systemType: $systemType, updateType: $updateType, noticeType: $noticeType, createTime: $createTime, createId: $createId, updateTime: $updateTime, updateId: $updateId, status: $status, img: $img, updateContent: $updateContent)';
  }
}
