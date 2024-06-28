import 'dart:typed_data';

class LandmarkData {
  static const int byteLength = 5 * 4 + 1; // 5 doubles, 4 bytes for each double (lower precision) + 1 byte for visibility
  static const double visibilityThreshold = 0.5;

  final double imageX;
  final double imageY;
  final double worldX;
  final double worldY;
  final double worldZ;
  final bool visible;

  LandmarkData({
    required this.imageX,
    required this.imageY,
    required this.worldX,
    required this.worldY,
    required this.worldZ,
    required this.visible,
  });

  factory LandmarkData.fromJson(Map<String, dynamic> json) {
    return LandmarkData(
      imageX: json['imageX'],
      imageY: json['imageY'],
      worldX: json['worldX'],
      worldY: json['worldY'],
      worldZ: json['worldZ'],
      visible: json['visibility'] > visibilityThreshold,
    );
  }

  factory LandmarkData.fromBytes(List<int> bytes) {
    ByteData byteData = ByteData.view(Uint8List.fromList(bytes).buffer);
    double imageX = byteData.getFloat32(0, Endian.little);
    double imageY = byteData.getFloat32(4, Endian.little);
    double worldX = byteData.getFloat32(8, Endian.little);
    double worldY = byteData.getFloat32(12, Endian.little);
    double worldZ = byteData.getFloat32(16, Endian.little);
    int visible = byteData.getInt8(20);

    return LandmarkData(
      imageX: imageX,
      imageY: imageY,
      worldX: worldX,
      worldY: worldY,
      worldZ: worldZ,
      visible: visible == 1,
    );
  }

  List<int> toBytes(LandmarkData landmarkData) {
    ByteData byteData = ByteData(byteLength);
    byteData.setFloat32(0, landmarkData.imageX, Endian.little);
    byteData.setFloat32(4, landmarkData.imageY, Endian.little);
    byteData.setFloat32(8, landmarkData.worldX, Endian.little);
    byteData.setFloat32(12, landmarkData.worldY, Endian.little);
    byteData.setFloat32(16, landmarkData.worldZ, Endian.little);
    byteData.setInt8(20, visible ? 1 : 0);
    return byteData.buffer.asUint8List();
  }
}

List<int> landmarkDataListToBytes(List<LandmarkData> landmarkDataList) {
  List<int> bytes = [];
  for (LandmarkData landmarkData in landmarkDataList) {
    bytes.addAll(landmarkData.toBytes(landmarkData));
  }
  return bytes;
}

List<LandmarkData> bytesToLandmarkDataList(List<int> bytes) {
  List<LandmarkData> landmarkDataList = [];
  for (int i = 0; i < bytes.length; i += LandmarkData.byteLength) { // 20 bytes for each LandmarkData
    List<int> landmarkBytes = bytes.sublist(i, i + LandmarkData.byteLength);
    LandmarkData landmarkData = LandmarkData.fromBytes(landmarkBytes);
    landmarkDataList.add(landmarkData);
  }
  return landmarkDataList;
}