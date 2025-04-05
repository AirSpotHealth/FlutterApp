import 'dart:io';

import 'package:path_provider/path_provider.dart';

// create a builder pattern for a dump service...
// Follow builder pattern from JAVA
// it first creates a file and then writes the data to it and then closes the file

class DataDumpBuilder {
  late String deviceId;

  File? file;

  DataDumpBuilder(this.deviceId);

  String get fileName => 'device_data_dump_$deviceId.txt';

  Future<DataDumpBuilder> createFile() async {
    final directory = await getApplicationDocumentsDirectory();

    file = File('${directory.path}/device_data_$deviceId.txt');

    // Check if the file already exists and delete it if it does
    if (await file!.exists()) {
      await file!.delete();
    }

    // Create a new file
    file = await file!.create();

    return this;
  }

  DataDumpBuilder writeData(String data, {bool newLine = true}) {
    if (file == null) {
      throw Exception('File not created');
    }

    final String content = newLine ? '$data\n' : data;

    file!.writeAsStringSync(content, mode: FileMode.append);
    return this;
  }

  File build() {
    if (file == null) {
      throw Exception('File not created');
    }

    return file!;
  }
}
