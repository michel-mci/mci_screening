import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mci_screening/error_patterns/rep_counter.dart';
import 'package:mci_screening/landmark_frame_writer.dart';
import 'package:mci_screening/model/landmark_data.dart';
import 'package:mci_screening/model/landmark_frame.dart';
import 'package:mci_screening/pages/playback.dart';
import 'package:mci_screening/widgets/pose_painter.dart';

class ScreeningPage extends StatefulWidget {
  const ScreeningPage({super.key});

  @override
  State<ScreeningPage> createState() => _ScreeningPageState();
}

class _ScreeningPageState extends State<ScreeningPage> {
  List<Offset> points = [];
  LandmarkFrameWriter dataWriter = LandmarkFrameWriter();
  RepCounter repCounter = RepCounter();

  @override
  void dispose() {
    dataWriter.closeFile();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest:
                URLRequest(url: WebUri("http://localhost:8080/index.html")),
            initialSettings: InAppWebViewSettings(
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: true,
            ),
            onPermissionRequest: (controller, request) async {
              return PermissionResponse(
                resources: request.resources,
                action: PermissionResponseAction.GRANT,
              );
            },
            onWebViewCreated: (controller) {
              dataWriter.openFile('data');

              controller.addJavaScriptHandler(
                  handlerName: 'sendPose',
                  callback: (args) {
                    // Now you can use the `points` list in your Dart code
                    List<LandmarkData> landmarkList = [];

                    for (var landmarkJson in args[0]) {
                      LandmarkData landmarkData =
                          LandmarkData.fromJson(landmarkJson);

                      landmarkList.add(landmarkData);
                    }

                    double timeSinceLastFrame = args[1];

                    LandmarkFrame frame = LandmarkFrame(
                      landmarks: landmarkList,
                      timeSinceLastFrame: timeSinceLastFrame,
                    );

                    repCounter.process(frame, callback: () {
                      setState(() {});
                    });
                    dataWriter.writeNextLandmarkFrame(frame);

                    double aspectRatio = args[2];

                    setState(() {
                      points = landmarkList.map((landmarkData) {
                        double x =
                            (1.0 - landmarkData.imageX) * screenSize.width;
                        double y = landmarkData.imageY *
                                screenSize.width *
                                aspectRatio +
                            (screenSize.height -
                                    (screenSize.width * aspectRatio)) *
                                0.5;
                        return Offset(x, y);
                      }).toList();
                    });
                  });
            },
          ),
          _ModelPainter(
            customPainter: PosePainter(
              points: points,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              child: Text(
                repCounter.reps.toString(),
                style: const TextStyle(
                  fontSize: 35.0,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: OutlinedButton(
                child: const Text('Playback'),
                onPressed: () {
                  dataWriter.closeFile();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PlaybackPage()),
                  );
                },
              ),
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
