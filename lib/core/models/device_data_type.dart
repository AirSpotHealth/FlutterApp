enum DeviceDataType {
  co2,
  batteryLow,
  calibration,
  sensorError,
  reset,
  sensorFactoryReset,
  calibrationCorrection,
  sensorAutoCalibration,
  integrityError,
  calibrationTarget,
  timeSync,
  calibrationAdjustment,
  ascLowest,
  calibrationCorrectionOld,
  manualCalibStart,
  calibrationTargetUpdate,
  dfuUpdate,
  dfuUpdateFail,
  co2Retry,
  flightMode,
  scaling,
  empty;

  static DeviceDataType fromByte(int byte) =>
      deviceDataByteMap[byte] ?? DeviceDataType.empty;

  @override
  String toString() => humanizedName;

  String get humanizedName => deviceDataTypeMap[this] ?? '-';
}

const resetReasonMap = {
  0: 'Unknown',
  1: 'Pin Reset',
  2: 'Watchdog',
  3: 'Soft Reset',
  4: 'CPU Lock-up',
  5: 'Wake up from System OFF mode (GPIO)',
  6: 'Wake up from System OFF mode (LPCOMP)',
  7: 'Wake up from System OFF mode (Debug Interface)',
  8: 'Wake up from System OFF mode (NFC)',
};

const deviceDataByteMap = {
  0x00: DeviceDataType.co2,
  0x01: DeviceDataType.batteryLow,
  0x02: DeviceDataType.calibration,
  0x03: DeviceDataType.sensorError,
  0x04: DeviceDataType.reset,
  0x05: DeviceDataType.sensorFactoryReset,
  0x06: DeviceDataType.calibrationCorrection,
  0x07: DeviceDataType.sensorAutoCalibration,
  0x08: DeviceDataType.integrityError,
  0x09: DeviceDataType.calibrationTarget,
  0x0A: DeviceDataType.timeSync,
  0x0B: DeviceDataType.calibrationAdjustment,
  0x0C: DeviceDataType.ascLowest,
  0x0D: DeviceDataType.calibrationCorrectionOld,
  0x0E: DeviceDataType.manualCalibStart,
  0x0F: DeviceDataType.calibrationTargetUpdate,
  0x10: DeviceDataType.dfuUpdate,
  0x11: DeviceDataType.dfuUpdateFail,
  0x12: DeviceDataType.co2Retry,
  0x13: DeviceDataType.flightMode,
  0x14: DeviceDataType.scaling,
  // 0x12: DeviceDataType.empty,
};

const deviceDataTypeMap = {
  DeviceDataType.co2: 'CO2',
  DeviceDataType.batteryLow: 'Battery Low',
  DeviceDataType.calibration: 'Calibration Start',
  DeviceDataType.sensorError: 'Sensor Error',
  DeviceDataType.reset: 'Device Reset',
  DeviceDataType.sensorFactoryReset: 'Sensor Factory Reset',
  DeviceDataType.calibrationCorrection: 'New Calibration Correction',
  DeviceDataType.sensorAutoCalibration: 'Automatic Calibration',
  DeviceDataType.integrityError: 'Integrity Error',
  DeviceDataType.calibrationTarget: 'Calibration Target',
  DeviceDataType.timeSync: 'Time Sync',
  DeviceDataType.calibrationAdjustment: 'Calibration Adjustment',
  DeviceDataType.ascLowest: 'ASC Lowest',
  DeviceDataType.calibrationCorrectionOld: 'Old Calibration Correction',
  DeviceDataType.manualCalibStart: 'Manual Calibration Start',
  DeviceDataType.calibrationTargetUpdate: 'Calibration Target Update',
  DeviceDataType.dfuUpdate: 'DFU Update',
  DeviceDataType.dfuUpdateFail: 'DFU Update Fail',
  DeviceDataType.co2Retry: 'CO2 Retry',
  DeviceDataType.flightMode: 'Flight Mode',
  DeviceDataType.scaling: 'Scaling',
  DeviceDataType.empty: '-',
};

const sensorErrorMap = {
  0x01: 'Sensor Read Error',
  0x02: 'Sensor Auto Calibration Error',
  0x03: 'Sensor Reset Error',
  0x04: 'Sensor Measurement Start Error',
  0x05: 'Sensor Data Status Error',
  0x06: 'Sensor Variant Check Error',
  0x07: 'Sensor Measurement Stop Error',
  0x08: 'Invalid CO2 Reading',
  0x09: 'I2C Communication Failure',
  0x0A: 'CRC Checksum Failure',
  0x0B: 'Sensor Not Ready',
  0x0C: 'CO2 Reading Too High (>50000 ppm)',
};

const deviceDataOrder = [
  DeviceDataType.co2,
  DeviceDataType.co2Retry,
  DeviceDataType.batteryLow,
  DeviceDataType.calibration,
  DeviceDataType.sensorError,
  DeviceDataType.reset,
  DeviceDataType.sensorFactoryReset,
  DeviceDataType.sensorAutoCalibration,
  DeviceDataType.integrityError,
  DeviceDataType.calibrationTargetUpdate,
  DeviceDataType.timeSync,
  DeviceDataType.calibrationAdjustment,
  DeviceDataType.manualCalibStart,
  DeviceDataType.calibrationCorrectionOld,
  DeviceDataType.ascLowest,
  DeviceDataType.calibrationTarget,
  DeviceDataType.calibrationCorrection,
  DeviceDataType.dfuUpdate,
  DeviceDataType.dfuUpdateFail,
  DeviceDataType.flightMode,
  DeviceDataType.scaling,
];
