import 'package:onnxruntime/onnxruntime.dart';
import 'package:flutter/services.dart';

Future<void> runOnnxInference() async {
  // 1. 加载模型（从 assets）
  final modelBytes = await rootBundle.load('assets/models/best.onnx');
  
  // 2. 创建 ORT 环境和会话
  final session = await OrtSession.create(modelBytes.buffer.asUint8List());

  // 3. 准备输入数据
  // 假设您的模型输入是 float32 类型，形状为 [1, 3, 224, 224]
  final inputData = Float32List.fromList([ /* 您的输入数据，例如图像预处理后的像素 */ ]);
  final inputShape = [1, 3, 224, 224];
  
  final inputTensor = OrtTensor.createDense(
    inputData, 
    inputShape, 
    OrtDataType.float
  );

  final inputs = {'input_name': inputTensor}; // "input_name" 必须与模型输入名称一致

  // 4. 运行推理
  final results = await session.run(inputs);
  
  // 5. 处理结果
  final outputTensor = results['output_name'] as OrtTensor; // "output_name" 必须与模型输出名称一致
  final outputData = outputTensor.data; // 获取输出数据
  
  // 6. 关闭会话
  session.release();
}