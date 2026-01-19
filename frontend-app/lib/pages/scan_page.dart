// Example code: Using ONNX Runtime for inference
// Note: For actual usage, please refer to YoloService implementation

import 'package:onnxruntime/onnxruntime.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';

Future<void> runOnnxInference() async {
  try {
    // 1. Initialize ONNX Runtime environment
    OrtEnv.instance.init();

    // 2. Load ONNX model from assets
    final ByteData modelBytes = await rootBundle.load(
      'assets/models/best.onnx',
    );

    // 3. Create session options
    final sessionOptions = OrtSessionOptions();
    sessionOptions.setIntraOpNumThreads(2); // Set thread count

    // 4. Create ONNX session from buffer
    final session = OrtSession.fromBuffer(
      modelBytes.buffer.asUint8List(),
      sessionOptions,
    );

    sessionOptions.release();

    // 5. Prepare input data
    // Model input shape is [1, 3, 640, 640] (NCHW format)
    final inputShape = [1, 3, 640, 640];
    final inputSize = inputShape.reduce((a, b) => a * b);
    final inputData = Float32List(inputSize);
    // ... fill input data with preprocessed image (NCHW format: R plane, G plane, B plane) ...

    // 6. Create input tensor
    final inputTensor = OrtValueTensor.createTensorWithDataList(
      inputData,
      inputShape,
    );

    // 7. Prepare inputs map (YOLOv8 input name is usually 'images')
    final inputs = {'images': inputTensor};

    // 8. Create run options
    final runOptions = OrtRunOptions();

    // 9. Run inference
    final outputs = session.run(runOptions, inputs);

    // 10. Process output data
    // YOLOv8 output shape is usually [1, 81, 8400]
    // outputs[0].value is a nested list: List<List<List<double>>>
    final rawBatchOutput = (outputs[0]?.value as List)[0];
    final List<List<double>> outputMatrix = (rawBatchOutput as List)
        .map((e) => (e as List).map((x) => x as double).toList())
        .toList();

    // Process the outputMatrix for bounding boxes and class predictions
    // See YoloService._postprocess() for full implementation
    print(
      "✅ Inference completed. Output shape: [${outputMatrix.length}, ${outputMatrix[0].length}]",
    );

    // 11. Cleanup resources
    inputTensor.release();
    runOptions.release();
    for (var element in outputs) {
      element?.release();
    }
    session.release();
  } catch (e) {
    print("❌ ONNX inference error: $e");
    rethrow;
  }
}
