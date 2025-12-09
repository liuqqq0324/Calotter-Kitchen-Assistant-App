from ultralytics import YOLO

# 确保路径使用了原始字符串 r''
model = YOLO(r'D:\files\NewFolder_2\code\PersonalSousChef\A-team-PersonalSousChef\yolo_training_project\runs\detect\personal_chef.v1i.yolov8_train\weights\best.pt')

# 使用官方 export 函数
results = model.export(format='onnx', opset=12)

print(results)