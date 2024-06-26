import 'dart:io';
import 'package:mci_screening/model/landmark_snapshot.dart';
import 'package:path_provider/path_provider.dart';

class LandmarkSnapshotReader {
  late RandomAccessFile _raf;
  int _nextByteIndex = 0;

  Future<void> openFile(String fileName) async {
    Directory cacheDir = await getTemporaryDirectory();
    File file = File('${cacheDir.path}/$fileName');
    _raf = await file.open(mode: FileMode.read);
  }

  Future<void> closeFile() async {
    await _raf.close();
  }

  Future<LandmarkFrame?> readNextLandmarkData() async {
    int byteCount = LandmarkFrame.byteLength;
    if (_nextByteIndex + byteCount > await _raf.length()) {
      return null;
    }
    List<int> bytes = await _raf.read(byteCount);
    _nextByteIndex += byteCount;
    return LandmarkFrame.fromBytes(bytes);
  }
}