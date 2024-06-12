class Landmark {
  final double x;
  final double y;
  final double z;
  final double visibility;

  Landmark({
    required this.x,
    required this.y,
    required this.z,
    required this.visibility,
  });

  factory Landmark.fromJson(Map<String, dynamic> json) {
    return Landmark(
      x: json['x'],
      y: json['y'],
      z: json['z'],
      visibility: json['visibility'],
    );
  }
}