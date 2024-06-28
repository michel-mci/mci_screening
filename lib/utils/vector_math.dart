import 'dart:math' as math;

import 'package:mci_screening/model/landmark_data.dart';

double angleBetween(LandmarkData l1, LandmarkData l2, LandmarkData l3) {
  // Create vectors
  var a = [l1.worldX - l2.worldX, l1.worldY - l2.worldY, l1.worldZ - l2.worldZ];
  var b = [l3.worldX - l2.worldX, l3.worldY - l2.worldY, l3.worldZ - l2.worldZ];

  // Calculate magnitudes (lengths) of a and b
  var magA = math.sqrt(a[0]*a[0] + a[1]*a[1] + a[2]*a[2]);
  var normA = [a[0] / magA, a[1] / magA, a[2] / magA];

  var magB = math.sqrt(b[0]*b[0] + b[1]*b[1] + b[2]*b[2]);
  var normB = [b[0] / magB, b[1] / magB, b[2] / magB];


  // Calculate dot product
  var dotProduct = normA[0]*normB[0] + normA[1]*normB[1] + normA[2]*normB[2];

  // Calculate angle in radians
  var angleInRadians = math.acos(dotProduct);

  // Convert to degrees
  var angleInDegrees = angleInRadians * (180.0 / math.pi);

  return angleInDegrees;
}