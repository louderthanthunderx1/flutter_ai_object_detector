import 'package:ai_object_detector/controller/scan_controller.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// original
// class CameraView extends StatelessWidget {
//   // const CameraView({super.key});
//   const CameraView({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: GetBuilder<ScanController>(
//           init: ScanController(),
//           builder: (controller) {
//             var x = controller.x;
//             var y = controller.y;
//             var w = controller.w;
//             var h = controller.h;
//             var label = controller.label;
//             var confidence = controller.confidence;
//             print("front ${controller.label}");
//             return controller.isCameraInitialized.value
//                 ? Stack(
//                     children: [
//                       CameraPreview(controller.cameraController),
//                       Positioned(
//                         // top: 700,
//                         top: y *700,
//                         // // right: 500,
//                         right: x *500,
//                         // right: 500,
//                         child: Container(
//                           // Container(
//                           // width: 200,
//                           width: w * 200,
//                           // height: 200,
//                           height: h *200,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(2),
//                             border: Border.all(
//                                 color: Color.fromARGB(255, 255, 255, 0),
//                                 width: 4.0),
//                           ),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Container(
//                                 color: Color.fromARGB(255, 255, 255, 255),
//                                 // child: const Text("Label of object"),
//                                 child: Text(
//                                     "Class: $label, Confidence: $confidence"),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   )
//                 // : const Center(child: Text("Loading Preview ..."));
//                 : const Center(child: CircularProgressIndicator());
//           }),
//     );
//   }
// }

// old
class CameraView extends StatelessWidget {
  const CameraView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: GetBuilder<ScanController>(
        init: ScanController(),
        builder: (controller) {
          return controller.isCameraInitialized.value
              ? Stack(
                  children: [
                    CameraPreview(controller.cameraController),
                    CustomPaint(
                      painter: BoundingBoxPainter(
                        boundingBox: Rect.fromLTWH(
                          controller.x * screenSize.width,
                          controller.y * screenSize.height,
                          controller.w * screenSize.width,
                          controller.h * screenSize.height,
                        ),
                        label: controller.label,
                      ),
                    ),
                  ],
                )
              : const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class BoundingBoxPainter extends CustomPainter {
  final Rect boundingBox;
  final String label;

  BoundingBoxPainter({
    required this.boundingBox,
    required this.label,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow // Set the color of the bounding box
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawRect(boundingBox, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: label, // Display the detected object label
        style: TextStyle(
          color: Colors.white, // Set the text color
          fontSize: 16.0,
        ),
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    final labelOffset = Offset(boundingBox.left,
        boundingBox.top - 20.0); // Adjust the positioning of the label
    textPainter.paint(canvas, labelOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// finals
