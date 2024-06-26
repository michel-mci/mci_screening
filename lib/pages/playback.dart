import 'package:flutter/material.dart';
import 'package:mci_screening/landmark_snapshot_reader.dart';
import 'package:mci_screening/model/landmark_snapshot.dart';
import 'package:mci_screening/widgets/pose_painter.dart';

class PlaybackPage extends StatefulWidget {
  const PlaybackPage({super.key});

  @override
  State<PlaybackPage> createState() => _PlaybackPageState();
}

class _PlaybackPageState extends State<PlaybackPage> {
  List<Offset> points = [];
  LandmarkSnapshotReader dataReader = LandmarkSnapshotReader();

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
    print("PlayNextFrame");
    LandmarkFrame? landmarkFrame = await dataReader.readNextLandmarkData();

    if (landmarkFrame != null) {
      print("LandmarkFrame is not null");

      print("timeSinceLastFrame ${landmarkFrame.timeSinceLastFrame}");

      await Future.delayed(Duration(
        milliseconds: (landmarkFrame.timeSinceLastFrame * 1000).round(),
      ));

      print("Landmarks: ${landmarkFrame.landmarks.length}");

      setState(() {
        points = landmarkFrame.landmarks.map((landmarkData) {
          double x = (1.0 - landmarkData.imageX) * screenSize.width;
          double y = landmarkData.imageY * screenSize.height;
          return Offset(x, y);
        }).toList();
      });

      playNextFrame(screenSize);
    } else {
      print("LandmarkFrame is null");
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
