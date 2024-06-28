import 'package:mci_screening/model/landmark_data.dart';
import 'dart:typed_data';

class LandmarkFrame {
  static const int byteLength = LandmarkData.byteLength * 33 +
      8; // 33 landmarks, 8 bytes for timestamp (high precision)

  final List<LandmarkData> landmarks;
  final double timeSinceLastFrame;

  bool get isValid => landmarks.length > 32;

  LandmarkData? get nose => landmarks.length > 32 ? landmarks[0] : null;
  LandmarkData? get leftEyeInner => landmarks.length > 32 ? landmarks[1] : null;
  LandmarkData? get leftEye => landmarks.length > 32 ? landmarks[2] : null;
  LandmarkData? get leftEyeOuter => landmarks.length > 32 ? landmarks[3] : null;
  LandmarkData? get rightEyeInner => landmarks.length > 32 ? landmarks[4] : null;
  LandmarkData? get rightEye => landmarks.length > 32 ? landmarks[5] : null;
  LandmarkData? get rightEyeOuter => landmarks.length > 32 ? landmarks[6] : null;
  LandmarkData? get leftEar => landmarks.length > 32 ? landmarks[7] : null;
  LandmarkData? get rightEar => landmarks.length > 32 ? landmarks[8] : null;
  LandmarkData? get mouthLeft => landmarks.length > 32 ? landmarks[9] : null;
  LandmarkData? get mouthRight => landmarks.length > 32 ? landmarks[10] : null;
  LandmarkData? get leftShoulder => landmarks.length > 32 ? landmarks[11] : null;
  LandmarkData? get rightShoulder => landmarks.length > 32 ? landmarks[12] : null;
  LandmarkData? get leftElbow => landmarks.length > 32 ? landmarks[13] : null;
  LandmarkData? get rightElbow => landmarks.length > 32 ? landmarks[14] : null;
  LandmarkData? get leftWrist => landmarks.length > 32 ? landmarks[15] : null;
  LandmarkData? get rightWrist => landmarks.length > 32 ? landmarks[16] : null;
  LandmarkData? get leftPinky => landmarks.length > 32 ? landmarks[17] : null;
  LandmarkData? get rightPinky => landmarks.length > 32 ? landmarks[18] : null;
  LandmarkData? get leftIndex => landmarks.length > 32 ? landmarks[19] : null;
  LandmarkData? get rightIndex => landmarks.length > 32 ? landmarks[20] : null;
  LandmarkData? get leftThumb => landmarks.length > 32 ? landmarks[21] : null;
  LandmarkData? get rightThumb => landmarks.length > 32 ? landmarks[22] : null;
  LandmarkData? get leftHip => landmarks.length > 32 ? landmarks[23] : null;
  LandmarkData? get rightHip => landmarks.length > 32 ? landmarks[24] : null;
  LandmarkData? get leftKnee => landmarks.length > 32 ? landmarks[25] : null;
  LandmarkData? get rightKnee => landmarks.length > 32 ? landmarks[26] : null;
  LandmarkData? get leftAnkle => landmarks.length > 32 ? landmarks[27] : null;
  LandmarkData? get rightAnkle => landmarks.length > 32 ? landmarks[28] : null;
  LandmarkData? get leftHeel => landmarks.length > 32 ? landmarks[29] : null;
  LandmarkData? get rightHeel => landmarks.length > 32 ? landmarks[30] : null;
  LandmarkData? get leftFootIndex => landmarks.length > 32 ? landmarks[31] : null;
  LandmarkData? get rightFootIndex => landmarks.length > 32 ? landmarks[32] : null;

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
