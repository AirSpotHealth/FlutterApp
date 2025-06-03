///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations implements BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  );

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsAppEn app = TranslationsAppEn.internal(_root);
	late final TranslationsCommonEn common = TranslationsCommonEn.internal(_root);
	late final TranslationsDevicesEn devices = TranslationsDevicesEn.internal(_root);
	late final TranslationsHomeEn home = TranslationsHomeEn.internal(_root);
	late final TranslationsDeviceSettingsEn deviceSettings = TranslationsDeviceSettingsEn.internal(_root);
	late final TranslationsAppSetupEn appSetup = TranslationsAppSetupEn.internal(_root);
	late final TranslationsSolutionsEn solutions = TranslationsSolutionsEn.internal(_root);
	late final TranslationsDeviceGraphEn deviceGraph = TranslationsDeviceGraphEn.internal(_root);
	late final TranslationsFindMyDeviceEn findMyDevice = TranslationsFindMyDeviceEn.internal(_root);
	late final TranslationsAdvancedAlarmSettingsEn advancedAlarmSettings = TranslationsAdvancedAlarmSettingsEn.internal(_root);
	late final TranslationsAlertsEn alerts = TranslationsAlertsEn.internal(_root);
	late final TranslationsErrorsEn errors = TranslationsErrorsEn.internal(_root);
	late final TranslationsBluetoothEn bluetooth = TranslationsBluetoothEn.internal(_root);
	late final TranslationsNotificationsEn notifications = TranslationsNotificationsEn.internal(_root);
	late final TranslationsUnitsEn units = TranslationsUnitsEn.internal(_root);
	late final TranslationsTimeFormatEn timeFormat = TranslationsTimeFormatEn.internal(_root);
	String get devModeEnabled => 'Dev Mode is now enabled.';
	String get devModeDisabled => 'Dev Mode is now disabled';
	String get deviceDisconnected => 'Device disconnected.';
	String get deviceIsNotConnected => 'Device is not connected';
	String get deviceRemovedSuccessfully => 'Device removed successfully';
	String get deviceDataErasedSuccessfully => 'Device data erased successfully';
	String firmwareUpdateFailed({required Object error}) => 'Failed to update firmware, ${error}';
	String get firmwareUpdatedSuccessfully => 'Firmware updated successfully';
	String get firmwareUpdateInProgress => 'Firmware update in progress...';
	String calibrationTargetUpdated({required Object value}) => 'Calibration target updated to ${value}';
	String get invalidScalingValue => 'Invalid scaling value. Settings not saved.';
	String get settingsSaved => 'Settings saved';
	String get deviceFactoryResetSuccessfully => 'Device factory reset successfully';
	String get noFileSelected => 'No file selected';
	String errorSelectingFile({required Object error}) => 'Error selecting file: ${error}';
	String get sensorResetSuccessfully => 'Sensor reset successfully';
	String get latestVersionLabel => 'Latest Version:';
	String get autoCalibration => 'Auto Calibration';
	String get resetSensor => 'Reset Sensor';
	String get fetchConfiguration => 'Fetch Configuration';
	String get doNotDisturb => 'Do not disturb';
	String get connected => 'Connected';
	String get calibratingStatus => 'Calibrating';
	String get initialisingStatus => 'Initialising...';
	String remainingTime({required Object seconds}) => 'Remaining Time: ${seconds} seconds';
	String get calibrationCompleted => 'Calibration Completed';
	String correctionValue({required Object value}) => 'Correction Value: ${value}';
	String get calibrationFailed => 'Calibration Failed';
	String errorLabel({required Object error}) => 'Error: ${error}';
	String failedToResetSensor({required Object error}) => 'Failed to reset sensor: ${error}';
	String get autoCalibrationDescription => 'Automatically calibrate the sensor based on the lowest CO₂ reading in the previous 7 days.';
	String get autoCalibrationWarning => 'If Auto Calibration is enabled, AirSpot will calibrate itself on the assumption that it has made measurements in fresh air at least once a week. It is usually best to leave this OFF unless you are sure AirSpot will be measuring fresh air at least every few days. See full manual for details.';
	String get resetSensorDescription => 'If you are experiencing issues with your AirSpot\'s accuracy, you can reset the sensor to its factory settings. This will erase all calibration data and settings.';
	String get noNickname => 'No Nickname';
	String get changeDeviceNickname => 'Change Device Nickname';
	String get enterNickname => 'Enter nickname';
	String get notConnected => 'Not Connected';
	String get unavailable => 'Unavailable';
	String get sensorConfigurationNotLoaded => 'Sensor configuration not loaded.';
	String get loadingSensorData => 'Loading sensor data...';
	String get retry => 'Retry';
	String get graphMaxValue => 'Graph Max Value';
	String get graphMinValue => 'Graph Min Value';
	String graphMaxValueSet({required Object value}) => 'Graph Max Value set to ${value}';
	String graphMinValueSet({required Object value}) => 'Graph Min Value set to ${value}';
	String get selectValueBetween400And5000 => 'Select a value between 400 and 5000 ppm';
	String get tapToUpdateFirmware => 'Tap to update firmware';
	String get forgetDevice => 'Forget Device';
	String get areYouSureFactoryReset => 'Are you sure you want to factory reset this device?';
	String get factoryResetWarning => 'Factory reset will erase all settings and data on the device. This action cannot be undone.';
	String get importCsvData => 'Import CSV Data';
	String get sensorConfiguration => 'Sensor Configuration';
	String get airspotDeviceFirmwareUpdate => 'Airspot device firmware update';
	String get firmwareUpdateWarning => 'Warning: This device update will erase the CO2 history stored on the device. If you want to keep it, download it first. It will be saved as a .csv (spreadsheet).';
	String get failedToReadFirmwareVersion => 'Failed to read installed firmware version.';
	String get updateAnyway => 'Update Anyway!';
	String get updateNow => 'Update Now';
	String get screenMode => 'Screen Mode';
	String get plain => 'Plain';
	String get graph => 'Graph';
	String get colourBars => 'Colour Bars';
	String get flightMode => 'Flight Mode';
	String get altitudePressure => 'Altitude/Pressure';
	String get altitudePressureDescription => 'For most accurate calibration, set altitude or air pressure or scaling here (optional advanced feature, see manual.)';
	String get flightModeTurnedOff => 'Flight mode turned off. You can now set scaling.';
	String get flightModeActive => 'Flight mode is active. Scaling cannot be changed. Tap to turn off.';
	String get required => 'Required';
	String get invalid => 'Invalid';
	String get learnMore => 'Learn more';
	String failedToGetAscData({required Object error}) => 'Failed to get ASC data: ${error}';
	String lastCorrectionApplied({required Object correction}) => 'The last correction applied was ${correction}.';
	String get tapToGetLatestValues => 'Tap to get latest values';
	String get downloading => 'Downloading...';
	String get csvDataExported => 'CSV Data Exported';
	String get exportCsvData => 'Export CSV Data';
	String get updateAvailable => 'Update Available';
	String get bluetoothIsDisabled => 'Bluetooth is Disabled';
	String get bluetoothEnableInfo => 'Settings > Bluetooth > Turn On Bluetooth';
	String get pleaseEnableBluetoothService => 'Please enable the bluetooth service to continue:';
	String get selectCo2Level => 'Select CO₂ Level';
	String get selectAlarmRepeats => 'Select Alarm Repeats';
	String get done => 'Done';
}

// Path: app
class TranslationsAppEn {
	TranslationsAppEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get name => 'AirSpot Health';
	String get title => 'AirSpot Health App';
}

// Path: common
class TranslationsCommonEn {
	TranslationsCommonEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get ok => 'OK';
	String get cancel => 'Cancel';
	String get save => 'Save';
	String get close => 'Close';
	String get retry => 'Retry';
	String get loading => 'Loading...';
	String get error => 'Error';
	String get success => 'Success';
	String get failed => 'Failed';
	String get unknown => 'Unknown';
	String get unknownState => 'Unknown state';
	String get set => 'Set';
	String get send => 'Send';
	String get update => 'Update';
	String get yes => 'Yes';
	String get no => 'No';
	String get connect => 'Connect';
	String get connected => 'Connected';
	String get disconnect => 'Disconnect';
	String get clear => 'Clear';
	String get refresh => 'Refresh';
	String get updateNow => 'Update Now';
	String get upToDate => 'Up to date';
}

// Path: devices
class TranslationsDevicesEn {
	TranslationsDevicesEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Devices';
	String get noDevicesConnected => 'No devices connected';
	String get addDevice => 'Add Device';
	String get addDeviceTitle => 'Add Airspot Device';
	String get deviceConnectedSuccessfully => 'Device connected successfully';
	String get forgetDevice => 'Forget Device';
	String get connectedStatus => 'Connected';
	String get retryNow => 'Retry now';
	String get ppm => 'PPM';
	String get co2 => 'CO₂';
	String get co2Text => 'CO₂';
	String get subscript2 => '₂';
}

// Path: home
class TranslationsHomeEn {
	TranslationsHomeEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsHomeMenuEn menu = TranslationsHomeMenuEn.internal(_root);
}

// Path: deviceSettings
class TranslationsDeviceSettingsEn {
	TranslationsDeviceSettingsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Device Settings';
	String get deviceScreenSettings => 'Device Screen Settings';
	String get doNotDisturb => 'Do not disturb';
	String get airspotDeviceUpdate => 'AirSpot Device Update';
	String get calibrateDevice => 'Calibrate Device';
	String get locateMyAirspot => 'Locate my Airspot';
	String get sensorConfiguration => 'Sensor Configuration';
	String get timeSettings => 'Time Settings';
	String co2ReadingRate({required Object co2Text}) => '${co2Text} reading rate';
	String get turnOffDeviceBt => 'Turn off Device BT';
	String get deleteLocalCache => 'Delete Local Cache';
	String get restartDevice => 'Restart Device';
	String get fetchConfiguration => 'Fetch Configuration';
	String get deviceDataDump => 'Device data dump';
	String get startDataDump => 'Start Data Dump';
	String failedToDumpDeviceData({required Object error}) => 'Failed to dump device data: ${error}';
	String get deviceDataDumpedSuccessfully => 'Device data dumped successfully';
	String get latestVersion => 'Latest Version: ';
	String get installedVersion => 'Installed Version: ';
	String get metresAboveSeaLevel => 'Metres above sea level';
	String get pressure => 'Pressure (hPa)';
	String get scaling => 'Scaling (0.5-2.0)';
	String sendCommandTo({required Object deviceName}) => 'Send Command to ${deviceName}';
	String get nextAutoCalibration => 'Next Auto Calibration:';
	String get manualCalibration => 'Manual Calibration';
	String deviceLog({required Object deviceName}) => '${deviceName} log';
	String get noLogEntriesAvailable => 'No log entries available';
	String get errorLoadingDeviceLog => 'Error loading device log';
	String get syncWithMobileDevice => 'Sync with mobile device';
	String get manualTime => 'Manual Time';
	String get selectTime => 'Select time';
	String get autoCalibration => 'Auto Calibration';
	String get resetSensor => 'Reset Sensor';
	String get alarmLevels => 'Alarm Levels';
	String get co2Ppm => 'CO₂ (ppm)';
	String get repeats => 'Repeats';
	String get enabled => 'Enabled';
	String get selectCo2Level => 'Select CO₂ Level';
	String get selectAlarmRepeats => 'Select Alarm Repeats';
	String get now => 'Now';
	String get min3 => '3 min';
	String get min1 => '1 min';
	String get sec5 => '5 sec';
	String get dumpDeviceData => 'Dump Device Data';
	String get importCsvData => 'Import CSV Data';
	String get forgetThisDevice => 'Forget This Device';
	String get autoConnect => 'Auto Connect';
	String get amberAlert => 'Amber Alert';
	String get redAlert => 'Red Alert';
	String get sendCommand => 'Send Command';
	String get populateFakeData => 'Populate Fake Data';
	String get testSensorError => 'Test Sensor Error';
	String get disconnectDevice => 'Disconnect Device';
	String get alarm => 'Alarm';
	String get factoryReset => 'Factory Reset';
	String get flightMode => 'Flight Mode';
	String get vibrate => 'Vibrate';
	String get devSettings => 'Dev Settings';
	String get deviceNotConnected => 'Device not connected';
	String get numberOfPages => 'Number of pages';
	String get enterNumberOfPages => 'Enter number of pages to dump';
	String get pleaseEnterNumberOfPages => 'Please enter number of pages';
	String get pleaseEnterValidNumberOfPages => 'Please enter a valid number of pages';
	String get processingDeviceData => 'Processing device data...';
	String get batteryTooLowForUpdate => 'Battery too low for updating. Please connect charger.';
	String get localCacheDeleted => 'Local cache deleted';
	String get ascDurationSeconds => 'ASC Duration (seconds)';
	String get durationIsRequired => 'Duration is required';
	String get invalidDuration => 'Invalid duration';
	String get durationMustBeAtLeast30 => 'Duration must be at least 30 seconds';
	String get screenIllumination => 'Screen Illumination';
	String get turnOnScreenWhenAlarmTriggers => 'Turn on screen when alarm triggers';
	String get alarmOnCo2Fall => 'Alarm on CO₂ Fall';
	String get triggerAlarmOnCo2Fall => 'Trigger alarm on CO₂ fall';
	String get setBeepsVibrationsAndCo2Levels => 'Set beeps/vibrations and CO₂ levels for alarms.';
	String get resetToDefaults => 'Reset to Defaults';
	String get saveChanges => 'Save changes';
	String get allAdvancedSettingsReset => 'All advanced settings reset to defaults';
	String get failedToSaveAlarmSettings => 'Failed to save alarm level settings. Please try again.';
	String get alarmLevelChangesSaved => 'Alarm level changes saved';
	String get good => 'Good';
	String get warning => 'Warning';
	String get alert => 'Alert';
	String get greenZoneUpTo => 'Green Zone (Up to)';
	String get yellowZoneUpTo => 'Yellow Zone (Up to)';
	String get greenZoneCannotBeGreater => 'Green zone cannot be greater than yellow zone';
	String get yellowZoneCannotBeLess => 'Yellow zone cannot be less than green zone';
	String get greenCo2MustBeLess => 'Green CO₂ must be less than yellow CO₂';
	String get co2PpmZonesUpdated => 'CO₂ PPM Zones updated successfully';
	String selectValueBetween({required Object min, required Object max}) => 'Select a value between ${min} and ${max} ppm';
	String get co2PpmZones => 'CO₂ PPM Zones';
	String get tapToStartCalibration => 'Tap to start calibration';
	String get settings => 'Settings';
	String get resettingDevice => 'Resetting device....';
	String get advanced => 'Advanced';
	String get calibrationTarget => 'Calibration Target';
	String get pleaseEnterCalibrationTarget => 'Please enter a calibration target';
	String get pleaseEnterValidNumber => 'Please enter a valid number';
	String get pleaseEnterPositiveNumber => 'Please enter a positive number greater than 0';
	String get pleaseEnterNumberLessThan1000 => 'Please enter a number less than 1000';
	String get calibrationTargetDescription => 'You can set the CO2 level of the air where calibration takes place. If unknown, 420-450 is typical for outdoors. This value is used for manual or automatic calibration.';
	String get eraseDeviceData => 'Erase Device Data';
	String get areYouSureEraseData => 'Are you sure you want to erase all data from this device?';
	String get eraseDataWarning => 'Erasing data will remove all the CO2 history stored in the device. This action cannot be undone.';
	String get erasingDeviceData => 'Erasing device data....';
	String get noChangeLogAvailable => 'No change log available';
	String get doNotDisturbSettings => 'Do not disturb Settings';
	String get startTime => 'Start time';
	String get endTime => 'End time';
	String get notSet => 'Not set';
	String get selectStartTime => 'Select start time';
	String get selectEndTime => 'Select end time';
	String get na => 'N/A';
	String get command => 'Command';
	String get enterCommand => 'Enter command';
	String get powerOffDevice => 'Power Off Device';
	String get areYouSurePowerOff => 'Are you sure you want to power off the device?';
	String get powerOffDescription => 'This will put the device into sleep mode and you will need to press the button on the device to turn it back on. This is useful if you are not using the device for a long period of time and want to save battery.';
	String get powerOff => 'Power Off';
	String get manualCalibrationDescription => 'To calibrate this AirSpot, place the device outdoors for at least 5 minutes, away from any people or CO2 sources, then tap the icon below. See full manual for details.';
	String get deviceVariant => 'Device Variant';
}

// Path: appSetup
class TranslationsAppSetupEn {
	TranslationsAppSetupEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Settings';
	String get latestNews => 'Latest News';
	String get airspotAppUpdates => 'AirSpot App Updates';
	String get privacyPolicy => 'Privacy Policy';
	String get devMode => 'Dev Mode';
	String get airspotAppUpdate => 'AirSpot App Update';
	String get updateNow => 'Update Now';
	String get privacyPolicyTitle => 'Privacy Policy';
	String get language => 'Language';
	String get selectLanguage => 'Select Language';
	String get english => 'English';
	String get chinese => '中文 (Chinese)';
	String languageChanged({required Object language}) => 'Language changed to ${language}';
}

// Path: solutions
class TranslationsSolutionsEn {
	TranslationsSolutionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Solutions';
	String get naturalVent => 'Natural Vent';
	String get mechanicalVent => 'Mechanical Vent';
	String co2Monitors({required Object co2Text}) => '${co2Text} Monitors';
	String get uvLight => 'UV Light';
	String get airFilters => 'Air Filters';
	String get regulations => 'Regulations';
	String get links => 'Links';
	String get protection => 'Protection';
	String get masks => 'Masks';
	String get successStories => 'Success Stories';
}

// Path: deviceGraph
class TranslationsDeviceGraphEn {
	TranslationsDeviceGraphEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Device Graph';
	String get saveAsCsv => 'Save as CSV';
	String get share => 'Share';
	String get fetchingData => 'Fetching data...';
	late final TranslationsDeviceGraphRangesEn ranges = TranslationsDeviceGraphRangesEn.internal(_root);
	late final TranslationsDeviceGraphGraphSettingsEn graphSettings = TranslationsDeviceGraphGraphSettingsEn.internal(_root);
}

// Path: findMyDevice
class TranslationsFindMyDeviceEn {
	TranslationsFindMyDeviceEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Locate My Airspot';
	String get deviceNotFound => 'Device not found.';
}

// Path: advancedAlarmSettings
class TranslationsAdvancedAlarmSettingsEn {
	TranslationsAdvancedAlarmSettingsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Advanced Alarm Settings';
}

// Path: alerts
class TranslationsAlertsEn {
	TranslationsAlertsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get deviceConnectedSuccessfully => 'Device connected successfully';
	String get confirmAction => 'Are you sure you want to proceed?';
	String get actionCompleted => 'Action completed successfully';
	String get somethingWentWrong => 'Something went wrong';
}

// Path: errors
class TranslationsErrorsEn {
	TranslationsErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get connectionFailed => 'Connection failed';
	String get deviceNotFound => 'Device not found';
	String get bluetoothDisabled => 'Bluetooth is disabled';
	String get permissionDenied => 'Permission denied';
	String get networkError => 'Network error';
	String get unknownError => 'An unknown error occurred';
}

// Path: bluetooth
class TranslationsBluetoothEn {
	TranslationsBluetoothEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get scanning => 'Scanning for devices...';
	String get noDevicesFound => 'No devices found';
	String get noDevicesFoundSwipeRefresh => 'No devices found, swipe down to refresh';
	String deviceFound({required Object deviceName}) => 'Device found: ${deviceName}';
	String get connecting => 'Connecting...';
	String get disconnecting => 'Disconnecting...';
	late final TranslationsBluetoothBondStateEn bondState = TranslationsBluetoothBondStateEn.internal(_root);
}

// Path: notifications
class TranslationsNotificationsEn {
	TranslationsNotificationsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Notifications';
	String get co2LevelHigh => 'CO₂ level is high';
	String get deviceDisconnected => 'Device disconnected';
	String get calibrationNeeded => 'Calibration needed';
}

// Path: units
class TranslationsUnitsEn {
	TranslationsUnitsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get ppm => 'ppm';
	String get hpa => 'hPa';
	String get metres => 'metres';
	String get seconds => 'seconds';
	String get minutes => 'minutes';
	String get hours => 'hours';
}

// Path: timeFormat
class TranslationsTimeFormatEn {
	TranslationsTimeFormatEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get colon => ':';
}

// Path: home.menu
class TranslationsHomeMenuEn {
	TranslationsHomeMenuEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get devices => 'Devices';
	String get devicesDescription => 'Device List and Management';
	String get airMap => 'AirMap';
	String get airMapDescription => 'Geolocate indoor air quality with the Clean Air Map.';
	String get appSetup => 'App Set Up';
	String get appSetupDescription => 'Review app notifications, updates and privacy policy.';
	String get solutions => 'Solutions';
	String get solutionsDescription => 'Great advice for healthy living in fresh air.';
	String get shop => 'Shop';
	String get shopDescription => 'Great products from AirSpot and our affiliate partners.';
	String get news => 'News';
	String get newsDescription => 'Latest updates on fresh air living.';
}

// Path: deviceGraph.ranges
class TranslationsDeviceGraphRangesEn {
	TranslationsDeviceGraphRangesEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get today => 'Today';
	String get yesterday => 'Yesterday';
	String get last7Days => 'Last 7 Days';
	String get customRange => 'Custom Range';
	String get selectSpecificDates => 'Select specific dates';
}

// Path: deviceGraph.graphSettings
class TranslationsDeviceGraphGraphSettingsEn {
	TranslationsDeviceGraphGraphSettingsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get areaFill => 'Area Fill';
	String get markLines => 'Mark Lines';
	String get rebreathePercentage => 'Rebreathed %';
}

// Path: bluetooth.bondState
class TranslationsBluetoothBondStateEn {
	TranslationsBluetoothBondStateEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get bonded => 'Connected';
	String get bonding => 'Connecting...';
	String get none => 'Not connected';
}
