import 'package:flutter/material.dart';
import 'package:mci_screening/landmark_frame_reader.dart';
import 'package:mci_screening/model/landmark_frame.dart';
import 'package:mci_screening/widgets/pose_painter.dart';

class PlaybackPage extends StatefulWidget {
  const PlaybackPage({super.key});

  @override
  State<PlaybackPage> createState() => _PlaybackPageState();
}

class _PlaybackPageState extends State<PlaybackPage> {
  List<Offset> points = [];
  LandmarkFrameReader dataReader = LandmarkFrameReader();

  @override
  void dispose() {
    dataReader.closeFile();

    super.dispose();
  }

  void startPlayback(Size screenSize) async {
    print("StartPlayback");
    await dataReader.openFile('data');

    playNextFrame(screenSize);
  }

  void playNextFrame(Size screenSize) async {
    LandmarkFrame? landmarkFrame = await dataReader.readNextLandmarkFrame();

    if (landmarkFrame != null) {
      await Future.delayed(Duration(
        milliseconds: (landmarkFrame.timeSinceLastFrame * 1000).round(),
      ));

      setState(() {
        points = landmarkFrame.landmarks.map((landmarkData) {
          double x = (1.0 - landmarkData.imageX) * screenSize.width;
          double y = landmarkData.imageY * screenSize.height;
          return Offset(x, y);
        }).toList();
      });

      playNextFrame(screenSize);
    } else {
      dataReader.closeFile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _ModelPainter(
            customPainter: PosePainter(
              points: points,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              child: Text('Start Playback'),
              onPressed: () => startPlayback(screenSize),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModelPainter extends StatelessWidget {
  const _ModelPainter({
    required this.customPainter,
  });

  final CustomPainter customPainter;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: customPainter,
    );
  }
}
