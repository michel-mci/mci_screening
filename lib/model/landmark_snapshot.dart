import 'package:mci_screening/model/landmark_data.dart';
import 'dart:typed_data';

class LandmarkFrame {
  static const int byteLength = LandmarkData.byteLength * 33 +
      8; // 33 landmarks, 8 bytes for timestamp (high precision)

  final List<LandmarkData> landmarks;
  final double timeSinceLastFrame;

  LandmarkFrame({
    required this.landmarks,
    required this.timeSinceLastFrame,
  });

  factory LandmarkFrame.fromBytes(List<int> bytes) {
    List<int> landmarkBytes = bytes.sublist(0, LandmarkData.byteLength * 33);
    List<LandmarkData> landmarks = bytesToLandmarkDataList(landmarkBytes);

    ByteData byteData = ByteData.view(
        Uint8List.fromList(bytes.sublist(LandmarkData.byteLength * 33)).buffer);
    double timeSincePreviousSnapshot = byteData.getFloat64(0, Endian.little);

    return LandmarkFrame(
      landmarks: landmarks,
      timeSinceLastFrame: timeSincePreviousSnapshot,
    );
  }
}

List<int> landmarkSnapshotToBytes(LandmarkFrame landmarkSnapshot) {
  List<int> bytes = landmarkDataListToBytes(landmarkSnapshot.landmarks);

  ByteData byteData = ByteData(8); // 8 bytes for a double
  byteData.setFloat64(0, landmarkSnapshot.timeSinceLastFrame, Endian.little);
  bytes.addAll(byteData.buffer.asUint8List());

  return bytes;
}
