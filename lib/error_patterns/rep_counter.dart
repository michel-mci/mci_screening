import 'package:mci_screening/model/landmark_frame.dart';
import 'package:mci_screening/utils/vector_math.dart';

class RepCounter {
  static int confidenceInterval = 3;

  int _mode = 0;
  int _confidenceCount = 0;

  int _reps = 0;

  int get reps => _reps;

  void process(LandmarkFrame frame, {Function? callback}) {
    if (!frame.isValid) {
      return;
    }
    if (!frame.rightHip!.visible ||
        !frame.rightKnee!.visible ||
        !frame.rightAnkle!.visible) {
      print("No sufficient visibility");
      return;
    }

    print("Processing frame with angle: ");
    print(angleBetween(frame.rightHip!, frame.rightKnee!, frame.rightAnkle!));

    // Activation state
    if (_mode == 0) {
      // Check if angle between rightHip, rightKnee, rightAnkle is less than 90 degrees
      if (angleBetween(frame.rightHip!, frame.rightKnee!, frame.rightAnkle!) <
          90) {
        if (_confidenceCount < confidenceInterval) {
          _confidenceCount++;
        } else {
          _confidenceCount = 0;
          _mode = 1;
        }
      } else {
        _confidenceCount = 0;
      }
    }

    // Release state
    if (_mode == 1) {
      // Check if angle between rightHip, rightKnee, rightAnkle is greater than 90 degrees
      if (angleBetween(frame.rightHip!, frame.rightKnee!, frame.rightAnkle!) >
          90) {
        if (_confidenceCount < confidenceInterval) {
          _confidenceCount++;
        } else {
          _confidenceCount = 0;
          _mode = 0;
          _reps++;

          if (callback != null) {
            callback.call();
          }
        }
      } else {
        _confidenceCount = 0;
      }
    }

    print("Mode: $_mode");
    print("ConfidenceCount: $_confidenceCount");
    print("Reps: $_reps");
  }
}
