from ultralytics import YOLO


model_path = r'D:\files\NewFolder_2\code\PersonalSousChef\A-team-PersonalSousChef\yolo_training_project\runs\detect\personal_chef.v1i.yolov8_train\weights\best.pt' 

try:
    model = YOLO(model_path)
    print("\n" + "="*30)
    print(f"{len(model.names)} ")
    print("")
    print("="*30)
    print(model.names)
    print("="*30 + "\n")
except Exception as e:
    print(f"{e}")