import 'dart:io';
import 'package:mci_screening/model/landmark_frame.dart';
import 'package:path_provider/path_provider.dart';

class LandmarkFrameWriter {
  late IOSink _sink;
  bool _isClosed = false;

  Future<void> openFile(String fileName) async {
    // Get the cache directory
    Directory cacheDir = await getTemporaryDirectory();

    // Open the file in the cache directory
    File file = File('${cacheDir.path}/$fileName');

    // Delete the file if it already exists
    if (await file.exists()) {
      await file.delete();
    }

    _sink = file.openWrite(mode: FileMode.append);
    _isClosed = false;
  }

  Future<void> closeFile() async {
    // Always close the IOSink when done
    await _sink.flush();
    await _sink.close();
    _isClosed = true;
  }

  void writeNextLandmarkFrame(LandmarkFrame landmarkFrame) {
    if(_isClosed){
      return;
    }

    // Write the data to the file
    _sink.add(landmarkSnapshotToBytes(landmarkFrame));
  }
}