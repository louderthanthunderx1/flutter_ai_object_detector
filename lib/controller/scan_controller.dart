import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite_v2/tflite_v2.dart';

class ScanController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    print("Start Initailize Camera");
    initCamera();
    print("Start Initialize Models");
    initTFLite();
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();
  }

  late CameraController cameraController;
  late List<CameraDescription> cameras;

  var isCameraInitialized = false.obs;
  var cameraCount = 0;

  var h = 0.0;
  var w = 0.0;
  var x = 0.0;
  var y = 0.0;

  var label = "";
  var confidence = 0.0;

  initCamera() async {
    if (await Permission.camera.request().isGranted) {
      cameras = await availableCameras();

      try {
        cameraController = CameraController(cameras[0], ResolutionPreset.high,
            imageFormatGroup: ImageFormatGroup.yuv420);
        await cameraController.initialize().then((value) {
          cameraController.startImageStream((image) {
            cameraCount++;
            if (cameraCount % 10 == 0) {
              cameraCount = 0;
              print("Start Detection");
              objectDetector(image);
              print("Object Detector: $objectDetector(image)");
            }
            update();
          });
        });
        isCameraInitialized(true);
        update();
      } catch (e) {
        print('Error initializing camera: $e');
      }
    } else {
      print("Camera Permission denied");
    }
  }

// Initial Model to inferences
  initTFLite() async {
    try {
      var models = await Tflite.loadModel(
        model: "assets/yolov2_tiny.tflite",
        labels: "assets/yolov2_tiny.txt",
        isAsset: true,
        numThreads: 1,
        useGpuDelegate: false,
      );
      print('Model loaded successfilly: $models');
    } catch (e) {
      print('Error Loading model: $e');
    }
  }

//   // old
  objectDetector(CameraImage image) async {
    try {
      var detector = await Tflite.detectObjectOnFrame(
        bytesList: image.planes.map((plane) => plane.bytes).toList(),
        model: "YOLO",
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 127.5,
        imageStd: 127.5,
        threshold: 0.1,
        numResultsPerClass: 2,
        anchors: Tflite.anchors,
        blockSize: 32,
        numBoxesPerBlock: 5,
        asynch: true,
      );

      if (detector != null) {
        // var ourDetectorObject = detector.first;
        var detectionResult = detector
            .first; // Assuming detector is the list containing detection results
        if (detectionResult['confidenceInClass'] * 100 > 45) {
          label = detectionResult['detectedClass'].toString();
          h = detectionResult['rect']['h'];
          w = detectionResult['rect']['w'];
          x = detectionResult['rect']['x'];
          y = detectionResult['rect']['y'];
          confidence = detectionResult['confidenceInClass'] * 100;

          print("Updated Label: $label");
          print("Updated Confidence: $confidence");
          print("Updated X: $x");
          print("Updated Y: $y");
          print("Updated Width: $w");
          print("Updated Height: $h");
        }
        update();

        print("Detection Result1: $detector");
        print(label);
        print(confidence);
      }
    } catch (e) {
      print('Error during object detection: $e');
    }
  }
}
//finals
