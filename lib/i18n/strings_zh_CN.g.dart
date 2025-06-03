///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsZhCn extends Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsZhCn({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.zhCn,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver);

	/// Metadata for the translations of <zh-CN>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	late final TranslationsZhCn _root = this; // ignore: unused_field

	@override 
	TranslationsZhCn $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsZhCn(meta: meta ?? this.$meta);

	// Translations
	@override late final TranslationsAppZhCn app = TranslationsAppZhCn._(_root);
	@override late final TranslationsCommonZhCn common = TranslationsCommonZhCn._(_root);
	@override late final TranslationsDevicesZhCn devices = TranslationsDevicesZhCn._(_root);
	@override late final TranslationsHomeZhCn home = TranslationsHomeZhCn._(_root);
	@override late final TranslationsDeviceSettingsZhCn deviceSettings = TranslationsDeviceSettingsZhCn._(_root);
	@override late final TranslationsAppSetupZhCn appSetup = TranslationsAppSetupZhCn._(_root);
	@override late final TranslationsSolutionsZhCn solutions = TranslationsSolutionsZhCn._(_root);
	@override late final TranslationsDeviceGraphZhCn deviceGraph = TranslationsDeviceGraphZhCn._(_root);
	@override late final TranslationsFindMyDeviceZhCn findMyDevice = TranslationsFindMyDeviceZhCn._(_root);
	@override late final TranslationsAdvancedAlarmSettingsZhCn advancedAlarmSettings = TranslationsAdvancedAlarmSettingsZhCn._(_root);
	@override late final TranslationsAlertsZhCn alerts = TranslationsAlertsZhCn._(_root);
	@override late final TranslationsErrorsZhCn errors = TranslationsErrorsZhCn._(_root);
	@override late final TranslationsBluetoothZhCn bluetooth = TranslationsBluetoothZhCn._(_root);
	@override late final TranslationsNotificationsZhCn notifications = TranslationsNotificationsZhCn._(_root);
	@override late final TranslationsUnitsZhCn units = TranslationsUnitsZhCn._(_root);
	@override late final TranslationsTimeFormatZhCn timeFormat = TranslationsTimeFormatZhCn._(_root);
	@override String get devModeEnabled => '开发者模式已启用。';
	@override String get devModeDisabled => '开发者模式已禁用';
	@override String get deviceDisconnected => '设备已断开连接。';
	@override String get deviceIsNotConnected => '设备未连接';
	@override String get deviceRemovedSuccessfully => '设备移除成功';
	@override String get deviceDataErasedSuccessfully => '设备数据擦除成功';
	@override String firmwareUpdateFailed({required Object error}) => '固件更新失败，${error}';
	@override String get firmwareUpdatedSuccessfully => '固件更新成功';
	@override String get firmwareUpdateInProgress => '固件更新中...';
	@override String calibrationTargetUpdated({required Object value}) => '校准目标已更新为 ${value}';
	@override String get invalidScalingValue => '无效的缩放值。设置未保存。';
	@override String get settingsSaved => '设置已保存';
	@override String get deviceFactoryResetSuccessfully => '设备恢复出厂设置成功';
	@override String get noFileSelected => '未选择文件';
	@override String errorSelectingFile({required Object error}) => '选择文件时出错：${error}';
	@override String get sensorResetSuccessfully => '传感器重置成功';
	@override String get latestVersionLabel => '最新版本：';
	@override String get autoCalibration => '自动校准';
	@override String get resetSensor => '重置传感器';
	@override String get fetchConfiguration => '获取配置';
	@override String get doNotDisturb => '勿扰模式';
	@override String get connected => '已连接';
	@override String get calibratingStatus => '正在校准';
	@override String get initialisingStatus => '正在初始化...';
	@override String remainingTime({required Object seconds}) => '剩余时间：${seconds} 秒';
	@override String get calibrationCompleted => '校准完成';
	@override String correctionValue({required Object value}) => '校正值：${value}';
	@override String get calibrationFailed => '校准失败';
	@override String errorLabel({required Object error}) => '错误：${error}';
	@override String failedToResetSensor({required Object error}) => '重置传感器失败：${error}';
	@override String get autoCalibrationDescription => '基于过去 7 天内最低的 CO₂ 读数自动校准传感器。';
	@override String get autoCalibrationWarning => '如果启用自动校准，AirSpot 将假设每周至少在新鲜空气中进行一次测量来校准自己。除非您确定 AirSpot 至少每隔几天就会测量新鲜空气，否则通常最好将其关闭。详情请参阅完整手册。';
	@override String get resetSensorDescription => '如果您的 AirSpot 精度出现问题，可以将传感器重置为出厂设置。这将擦除所有校准数据和设置。';
	@override String get noNickname => '无昵称';
	@override String get changeDeviceNickname => '更改设备昵称';
	@override String get enterNickname => '输入昵称';
	@override String get notConnected => '未连接';
	@override String get unavailable => '不可用';
	@override String get sensorConfigurationNotLoaded => '传感器配置未加载。';
	@override String get loadingSensorData => '正在加载传感器数据...';
	@override String get retry => '重试';
	@override String get graphMaxValue => '图表最大值';
	@override String get graphMinValue => '图表最小值';
	@override String graphMaxValueSet({required Object value}) => '图表最大值设置为 ${value}';
	@override String graphMinValueSet({required Object value}) => '图表最小值设置为 ${value}';
	@override String get selectValueBetween400And5000 => '选择 400 到 5000 ppm 之间的值';
	@override String get tapToUpdateFirmware => '点击更新固件';
	@override String get forgetDevice => '忘记设备';
	@override String get areYouSureFactoryReset => '您确定要恢复出厂设置此设备吗？';
	@override String get factoryResetWarning => '恢复出厂设置将擦除设备上的所有设置和数据。此操作无法撤销。';
	@override String get importCsvData => '导入 CSV 数据';
	@override String get sensorConfiguration => '传感器配置';
	@override String get airspotDeviceFirmwareUpdate => 'Airspot 设备固件更新';
	@override String get firmwareUpdateWarning => '警告：此设备更新将擦除存储在设备上的 CO2 历史记录。如果您想保留它，请先下载。它将保存为 .csv（电子表格）。';
	@override String get failedToReadFirmwareVersion => '读取已安装固件版本失败。';
	@override String get updateAnyway => '仍然更新！';
	@override String get updateNow => '立即更新';
	@override String get screenMode => '屏幕模式';
	@override String get plain => '纯文本';
	@override String get graph => '图表';
	@override String get colourBars => '彩色条';
	@override String get flightMode => '飞行模式';
	@override String get altitudePressure => '海拔高度/气压';
	@override String get altitudePressureDescription => '为了最准确的校准，请在此设置海拔高度或气压或缩放（可选高级功能，请参阅手册）。';
	@override String get flightModeTurnedOff => '飞行模式已关闭。现在您可以设置缩放。';
	@override String get flightModeActive => '飞行模式已激活。无法更改缩放。点击关闭。';
	@override String get required => '必填';
	@override String get invalid => '无效';
	@override String get learnMore => '了解更多';
	@override String get co2PpmZones => 'CO₂ PPM 区域';
	@override String get tapToStartCalibration => '点击开始校准';
	@override String get settings => '设置';
	@override String get resettingDevice => '正在重置设备....';
	@override String get advanced => '高级';
	@override String get calibrationTarget => '校准目标';
	@override String get pleaseEnterCalibrationTarget => '请输入校准目标';
	@override String get pleaseEnterValidNumber => '请输入有效数字';
	@override String get pleaseEnterPositiveNumber => '请输入大于 0 的正数';
	@override String get pleaseEnterNumberLessThan1000 => '请输入小于 1000 的数字';
	@override String get calibrationTargetDescription => '您可以设置校准场所的空气 CO2 浓度。如果未知，室外典型值为 420-450。此值用于手动或自动校准。';
	@override String get eraseDeviceData => '擦除设备数据';
	@override String get areYouSureEraseData => '您确定要擦除此设备的所有数据吗？';
	@override String get eraseDataWarning => '擦除数据将删除设备中存储的所有 CO2 历史记录。此操作无法撤销。';
	@override String get erasingDeviceData => '正在擦除设备数据....';
	@override String get noChangeLogAvailable => '无可用更新日志';
	@override String get doNotDisturbSettings => '勿扰模式设置';
	@override String get startTime => '开始时间';
	@override String get endTime => '结束时间';
	@override String get notSet => '未设置';
	@override String get selectStartTime => '选择开始时间';
	@override String get selectEndTime => '选择结束时间';
	@override String get na => '不适用';
	@override String get command => '命令';
	@override String get enterCommand => '输入命令';
	@override String get powerOffDevice => '关闭设备电源';
	@override String get areYouSurePowerOff => '您确定要关闭设备电源吗？';
	@override String get powerOffDescription => '这将使设备进入睡眠模式，您需要按设备上的按钮才能重新打开。如果您长时间不使用设备并希望节省电池电量，这很有用。';
	@override String get powerOff => '关闭电源';
	@override String get manualCalibrationDescription => '要校准此 AirSpot，请将设备放置在室外至少 5 分钟，远离任何人员或 CO2 源，然后点击下面的图标。详情请参阅完整手册。';
	@override String get deviceVariant => '设备变体';
	@override String failedToGetAscData({required Object error}) => '获取 ASC 数据失败：${error}';
	@override String lastCorrectionApplied({required Object correction}) => '上次应用的校正值为 ${correction}。';
	@override String get tapToGetLatestValues => '点击获取最新值';
	@override String get downloading => '正在下载...';
	@override String get csvDataExported => 'CSV 数据已导出';
	@override String get exportCsvData => '导出 CSV 数据';
	@override String get updateAvailable => '有可用更新';
	@override String get bluetoothIsDisabled => '蓝牙已禁用';
	@override String get bluetoothEnableInfo => '设置 > 蓝牙 > 打开蓝牙';
	@override String get pleaseEnableBluetoothService => '请启用蓝牙服务以继续：';
	@override String get done => '完成';
}

// Path: app
class TranslationsAppZhCn extends TranslationsAppEn {
	TranslationsAppZhCn._(TranslationsZhCn root) : this._root = root, super.internal(root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get name => 'AirSpot Health';
	@override String get title => 'AirSpot Health 应用';
}

// Path: common
class TranslationsCommonZhCn extends TranslationsCommonEn {
	TranslationsCommonZhCn._(TranslationsZhCn root) : this._root = root, super.internal(root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get ok => '确定';
	@override String get cancel => '取消';
	@override String get save => '保存';
	@override String get close => '关闭';
	@override String get retry => '重试';
	@override String get loading => '加载中...';
	@override String get error => '错误';
	@override String get success => '成功';
	@override String get failed => '失败';
	@override String get unknown => '未知';
	@override String get unknownState => '未知状态';
	@override String get set => '设置';
	@override String get send => '发送';
	@override String get update => '更新';
	@override String get yes => '是';
	@override String get no => '否';
	@override String get connect => '连接';
	@override String get connected => '已连接';
	@override String get disconnect => '断开连接';
	@override String get clear => '清除';
	@override String get refresh => '刷新';
	@override String get updateNow => '立即更新';
	@override String get upToDate => '已是最新版本';
}

// Path: devices
class TranslationsDevicesZhCn extends TranslationsDevicesEn {
	TranslationsDevicesZhCn._(TranslationsZhCn root) : this._root = root, super.internal(root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get title => '设备';
	@override String get noDevicesConnected => '无已连接设备';
	@override String get addDevice => '添加设备';
	@override String get addDeviceTitle => '添加 Airspot 设备';
	@override String get deviceConnectedSuccessfully => '设备连接成功';
	@override String get forgetDevice => '忘记设备';
	@override String get connectedStatus => '已连接';
	@override String get retryNow => '立即重试';
	@override String get ppm => 'PPM';
	@override String get co2 => 'CO₂';
	@override String get co2Text => 'CO₂';
	@override String get subscript2 => '₂';
}

// Path: home
class TranslationsHomeZhCn extends TranslationsHomeEn {
	TranslationsHomeZhCn._(TranslationsZhCn root) : this._root = root, super.internal(root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override late final TranslationsHomeMenuZhCn menu = TranslationsHomeMenuZhCn._(_root);
}

// Path: deviceSettings
class TranslationsDeviceSettingsZhCn extends TranslationsDeviceSettingsEn {
	TranslationsDeviceSettingsZhCn._(TranslationsZhCn root) : this._root = root, super.internal(root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get title => '设备设置';
	@override String get deviceScreenSettings => '设备屏幕设置';
	@override String get doNotDisturb => '勿扰模式';
	@override String get airspotDeviceUpdate => 'AirSpot 设备更新';
	@override String get calibrateDevice => '校准设备';
	@override String get locateMyAirspot => '定位我的 Airspot';
	@override String get sensorConfiguration => '传感器配置';
	@override String get timeSettings => '时间设置';
	@override String co2ReadingRate({required Object co2Text}) => '${co2Text} 读取频率';
	@override String get turnOffDeviceBt => '关闭设备蓝牙';
	@override String get deleteLocalCache => '删除本地缓存';
	@override String get restartDevice => '重启设备';
	@override String get fetchConfiguration => '获取配置';
	@override String get deviceDataDump => '设备数据转储';
	@override String get startDataDump => '开始数据转储';
	@override String failedToDumpDeviceData({required Object error}) => '转储设备数据失败：${error}';
	@override String get deviceDataDumpedSuccessfully => '设备数据转储成功';
	@override String get latestVersion => '最新版本：';
	@override String get installedVersion => '已安装版本：';
	@override String get metresAboveSeaLevel => '海拔高度（米）';
	@override String get pressure => '压力（hPa）';
	@override String get scaling => '缩放（0.5-2.0）';
	@override String sendCommandTo({required Object deviceName}) => '向 ${deviceName} 发送命令';
	@override String get nextAutoCalibration => '下次自动校准：';
	@override String get manualCalibration => '手动校准';
	@override String deviceLog({required Object deviceName}) => '${deviceName} 日志';
	@override String get noLogEntriesAvailable => '无可用日志条目';
	@override String get errorLoadingDeviceLog => '加载设备日志错误';
	@override String get syncWithMobileDevice => '与移动设备同步';
	@override String get manualTime => '手动时间';
	@override String get selectTime => '选择时间';
	@override String get autoCalibration => '自动校准';
	@override String get resetSensor => '重置传感器';
	@override String get alarmLevels => '报警级别';
	@override String get co2Ppm => 'CO₂ (ppm)';
	@override String get repeats => '重复';
	@override String get enabled => '已启用';
	@override String get selectCo2Level => '选择 CO₂ 级别';
	@override String get selectAlarmRepeats => '选择报警重复';
	@override String get now => '立即';
	@override String get min3 => '3 分钟';
	@override String get min1 => '1 分钟';
	@override String get sec5 => '5 秒';
	@override String get dumpDeviceData => '导出设备数据';
	@override String get importCsvData => '导入 CSV 数据';
	@override String get eraseDeviceData => '擦除设备数据';
	@override String get forgetThisDevice => '忘记此设备';
	@override String get autoConnect => '自动连接';
	@override String get amberAlert => '黄色警报';
	@override String get redAlert => '红色警报';
	@override String get sendCommand => '发送命令';
	@override String get populateFakeData => '填充测试数据';
	@override String get deviceVariant => '设备变体';
	@override String get testSensorError => '测试传感器错误';
	@override String get disconnectDevice => '断开设备连接';
	@override String get alarm => '报警';
	@override String get powerOffDevice => '关闭设备电源';
	@override String get factoryReset => '恢复出厂设置';
	@override String get flightMode => '飞行模式';
	@override String get vibrate => '振动';
	@override String get devSettings => '开发者设置';
	@override String get deviceNotConnected => '设备未连接';
	@override String get numberOfPages => '页数';
	@override String get enterNumberOfPages => '输入要转储的页数';
	@override String get pleaseEnterNumberOfPages => '请输入页数';
	@override String get pleaseEnterValidNumberOfPages => '请输入有效的页数';
	@override String get processingDeviceData => '正在处理设备数据...';
	@override String get batteryTooLowForUpdate => '电池电量过低，无法更新。请连接充电器。';
	@override String get localCacheDeleted => '本地缓存已删除';
	@override String get ascDurationSeconds => 'ASC 持续时间（秒）';
	@override String get durationIsRequired => '持续时间是必需的';
	@override String get invalidDuration => '无效持续时间';
	@override String get durationMustBeAtLeast30 => '持续时间至少为 30 秒';
	@override String get screenIllumination => '屏幕照明';
	@override String get turnOnScreenWhenAlarmTriggers => '报警触发时打开屏幕';
	@override String get alarmOnCo2Fall => 'CO₂ 下降报警';
	@override String get triggerAlarmOnCo2Fall => 'CO₂ 下降时触发报警';
	@override String get setBeepsVibrationsAndCo2Levels => '设置蜂鸣/振动和 CO₂ 报警级别。';
	@override String get resetToDefaults => '重置为默认值';
	@override String get saveChanges => '保存更改';
	@override String get allAdvancedSettingsReset => '所有高级设置已重置为默认值';
	@override String get failedToSaveAlarmSettings => '保存报警级别设置失败。请重试。';
	@override String get alarmLevelChangesSaved => '报警级别更改已保存';
	@override String get good => '良好';
	@override String get warning => '警告';
	@override String get alert => '警报';
	@override String get greenZoneUpTo => '绿色区域（最高）';
	@override String get yellowZoneUpTo => '黄色区域（最高）';
	@override String get greenZoneCannotBeGreater => '绿色区域不能大于黄色区域';
	@override String get yellowZoneCannotBeLess => '黄色区域不能小于绿色区域';
	@override String get greenCo2MustBeLess => '绿色 CO₂ 必须小于黄色 CO₂';
	@override String get co2PpmZonesUpdated => 'CO₂ PPM 区域更新成功';
	@override String selectValueBetween({required Object min, required Object max}) => '选择 ${min} 到 ${max} ppm 之间的值';
}

// Path: appSetup
class TranslationsAppSetupZhCn extends TranslationsAppSetupEn {
	TranslationsAppSetupZhCn._(TranslationsZhCn root) : this._root = root, super.internal(root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get title => '设置';
	@override String get latestNews => '最新新闻';
	@override String get airspotAppUpdates => 'AirSpot 应用更新';
	@override String get privacyPolicy => '隐私政策';
	@override String get devMode => '开发者模式';
	@override String get airspotAppUpdate => 'AirSpot 应用更新';
	@override String get updateNow => '立即更新';
	@override String get privacyPolicyTitle => '隐私政策';
	@override String get language => '语言';
	@override String get selectLanguage => '选择语言';
	@override String get english => 'English';
	@override String get chinese => '中文 (Chinese)';
	@override String languageChanged({required Object language}) => '语言已更改为${language}';
}

// Path: solutions
class TranslationsSolutionsZhCn extends TranslationsSolutionsEn {
	TranslationsSolutionsZhCn._(TranslationsZhCn root) : this._root = root, super.internal(root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get title => '解决方案';
	@override String get naturalVent => '自然通风';
	@override String get mechanicalVent => '机械通风';
	@override String co2Monitors({required Object co2Text}) => '${co2Text} 监测器';
	@override String get uvLight => '紫外线灯';
	@override String get airFilters => '空气过滤器';
	@override String get regulations => '法规';
	@override String get links => '链接';
	@override String get protection => '防护';
	@override String get masks => '口罩';
	@override String get successStories => '成功案例';
}

// Path: deviceGraph
class TranslationsDeviceGraphZhCn extends TranslationsDeviceGraphEn {
	TranslationsDeviceGraphZhCn._(TranslationsZhCn root) : this._root = root, super.internal(root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get title => '设备图表';
	@override String get saveAsCsv => '保存为 CSV';
	@override String get share => '分享';
	@override String get fetchingData => '正在获取数据...';
	@override late final TranslationsDeviceGraphRangesZhCn ranges = TranslationsDeviceGraphRangesZhCn._(_root);
	@override late final TranslationsDeviceGraphGraphSettingsZhCn graphSettings = TranslationsDeviceGraphGraphSettingsZhCn._(_root);
}

// Path: findMyDevice
class TranslationsFindMyDeviceZhCn extends TranslationsFindMyDeviceEn {
	TranslationsFindMyDeviceZhCn._(TranslationsZhCn root) : this._root = root, super.internal(root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get title => '定位我的 Airspot';
	@override String get deviceNotFound => '未找到设备。';
}

// Path: advancedAlarmSettings
class TranslationsAdvancedAlarmSettingsZhCn extends TranslationsAdvancedAlarmSettingsEn {
	TranslationsAdvancedAlarmSettingsZhCn._(TranslationsZhCn root) : this._root = root, super.internal(root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get title => '高级报警设置';
}

// Path: alerts
class TranslationsAlertsZhCn extends TranslationsAlertsEn {
	TranslationsAlertsZhCn._(TranslationsZhCn root) : this._root = root, super.internal(root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get deviceConnectedSuccessfully => '设备连接成功';
	@override String get confirmAction => '您确定要继续吗？';
	@override String get actionCompleted => '操作成功完成';
	@override String get somethingWentWrong => '出现了问题';
}

// Path: errors
class TranslationsErrorsZhCn extends TranslationsErrorsEn {
	TranslationsErrorsZhCn._(TranslationsZhCn root) : this._root = root, super.internal(root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get connectionFailed => '连接失败';
	@override String get deviceNotFound => '未找到设备';
	@override String get bluetoothDisabled => '蓝牙已禁用';
	@override String get permissionDenied => '权限被拒绝';
	@override String get networkError => '网络错误';
	@override String get unknownError => '发生未知错误';
}

// Path: bluetooth
class TranslationsBluetoothZhCn extends TranslationsBluetoothEn {
	TranslationsBluetoothZhCn._(TranslationsZhCn root) : this._root = root, super.internal(root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get scanning => '正在扫描设备...';
	@override String get noDevicesFound => '未找到设备';
	@override String get noDevicesFoundSwipeRefresh => '未找到设备，向下滑动刷新';
	@override String deviceFound({required Object deviceName}) => '找到设备：${deviceName}';
	@override String get connecting => '正在连接...';
	@override String get disconnecting => '正在断开连接...';
	@override late final TranslationsBluetoothBondStateZhCn bondState = TranslationsBluetoothBondStateZhCn._(_root);
}

// Path: notifications
class TranslationsNotificationsZhCn extends TranslationsNotificationsEn {
	TranslationsNotificationsZhCn._(TranslationsZhCn root) : this._root = root, super.internal(root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get title => '通知';
	@override String get co2LevelHigh => 'CO₂ 浓度偏高';
	@override String get deviceDisconnected => '设备已断开连接';
	@override String get calibrationNeeded => '需要校准';
}

// Path: units
class TranslationsUnitsZhCn extends TranslationsUnitsEn {
	TranslationsUnitsZhCn._(TranslationsZhCn root) : this._root = root, super.internal(root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get ppm => 'ppm';
	@override String get hpa => 'hPa';
	@override String get metres => '米';
	@override String get seconds => '秒';
	@override String get minutes => '分钟';
	@override String get hours => '小时';
}

// Path: timeFormat
class TranslationsTimeFormatZhCn extends TranslationsTimeFormatEn {
	TranslationsTimeFormatZhCn._(TranslationsZhCn root) : this._root = root, super.internal(root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get colon => '：';
}

// Path: home.menu
class TranslationsHomeMenuZhCn extends TranslationsHomeMenuEn {
	TranslationsHomeMenuZhCn._(TranslationsZhCn root) : this._root = root, super.internal(root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get devices => '设备';
	@override String get devicesDescription => '设备列表和管理';
	@override String get airMap => '空气地图';
	@override String get airMapDescription => '通过清洁空气地图定位室内空气质量。';
	@override String get appSetup => '应用设置';
	@override String get appSetupDescription => '查看应用通知、更新和隐私政策。';
	@override String get solutions => '解决方案';
	@override String get solutionsDescription => '关于在新鲜空气中健康生活的好建议。';
	@override String get shop => '商店';
	@override String get shopDescription => '来自 AirSpot 和我们合作伙伴的优质产品。';
	@override String get news => '新闻';
	@override String get newsDescription => '新鲜空气生活的最新更新。';
}

// Path: deviceGraph.ranges
class TranslationsDeviceGraphRangesZhCn extends TranslationsDeviceGraphRangesEn {
	TranslationsDeviceGraphRangesZhCn._(TranslationsZhCn root) : this._root = root, super.internal(root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get today => '今天';
	@override String get yesterday => '昨天';
	@override String get last7Days => '过去 7 天';
	@override String get customRange => '自定义范围';
	@override String get selectSpecificDates => '选择特定日期';
}

// Path: deviceGraph.graphSettings
class TranslationsDeviceGraphGraphSettingsZhCn extends TranslationsDeviceGraphGraphSettingsEn {
	TranslationsDeviceGraphGraphSettingsZhCn._(TranslationsZhCn root) : this._root = root, super.internal(root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get areaFill => '区域填充';
	@override String get markLines => '标记线';
	@override String get rebreathePercentage => '重呼吸 %';
}

// Path: bluetooth.bondState
class TranslationsBluetoothBondStateZhCn extends TranslationsBluetoothBondStateEn {
	TranslationsBluetoothBondStateZhCn._(TranslationsZhCn root) : this._root = root, super.internal(root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get bonded => '已连接';
	@override String get bonding => '正在连接...';
	@override String get none => '未连接';
}
