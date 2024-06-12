import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mci_screening/widgets/pose_painter.dart';

class ScreeningPage extends StatefulWidget {
  const ScreeningPage({super.key});

  @override
  State<ScreeningPage> createState() => _ScreeningPageState();
}

class _ScreeningPageState extends State<ScreeningPage> {
  List<Offset> points = [];

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
              controller.addJavaScriptHandler(handlerName: 'sendPose', callback: (args) {
                // Now you can use the `points` list in your Dart code
                List<Offset> newPoints = [];

                double aspectRatio = args[1];
                for (var point in args[0][0]) {
                  double x = (1.0 - point['x']) * screenSize.width;
                  double y = point['y'] * screenSize.width * aspectRatio + (screenSize.height - (screenSize.width * aspectRatio)) * 0.5;

                  newPoints.add(Offset(x, y));
                }

                setState(() {
                  points = newPoints;
                });
              });
            },
          ),
          _ModelPainter(
            customPainter: PosePainter(
              points: points,
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
    Key? key,
  }) : super(key: key);

  final CustomPainter customPainter;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: customPainter,
    );
  }
}
