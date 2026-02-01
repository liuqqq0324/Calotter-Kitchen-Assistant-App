-- ============================================
-- 标准库数据初始化（Spring Boot 自动执行）
-- Standard Libraries Data - auto-run by Spring Boot on startup (data.sql in src/main/resources)
-- ============================================
-- 来源: backend-calotter/init-standard-libraries.sql
-- 表结构由 JPA ddl-auto: update 建好后，Spring Boot 会执行本文件（需 spring.sql.init.mode=always）
--
-- 使用方法（若需手动执行）:
--   docker exec -i calotter_postgres psql -U postgres -d calotter < init-standard-libraries.sql
--   or: psql -h localhost -U postgres -d calotter -f init-standard-libraries.sql
--
-- 防冲突：所有 INSERT 均使用 ON CONFLICT（DO UPDATE 或 DO NOTHING / WHERE NOT EXISTS），
-- 重复执行不会报错，不影响现有用户数据。
-- ============================================

-- ============================================
-- 2. 插入标准过敏原库（RefAllergen）
-- ============================================
INSERT INTO ref_standard_allergens (id, name, description)
VALUES 
  (1, 'Peanut', 'May cause severe allergic reactions'),
  (2, 'Milk', 'Lactose intolerance'),
  (3, 'Egg', 'Common allergen'),
  (4, 'Soybean', 'Common allergen'),
  (5, 'Wheat', 'Gluten intolerance'),
  (6, 'Seafood', 'Crustacean allergy'),
  (7, 'Tree Nut', 'Tree nut allergy'),
  (8, 'Fish', 'Fish allergy'),
  (9, 'Sesame', 'Sesame seed allergy'),
  (10, 'Shellfish', 'Shellfish allergy')
ON CONFLICT (id) DO UPDATE SET 
  name = EXCLUDED.name,
  description = EXCLUDED.description;

SELECT setval('ref_standard_allergens_id_seq', (SELECT MAX(id) FROM ref_standard_allergens));

-- ============================================
-- 3. 插入标准食材库（StandardIngredient）
-- ============================================
INSERT INTO ref_standard_ingredients (id, name, category, calories, protein, fat, carb, fiber, average_gram_per_unit, shelf_life_pantry, shelf_life_fridge, shelf_life_freezer, default_location, primary_unit, secondary_unit, unit_conversion_factor, standard_unit)
VALUES 
  (1001, 'Apple', 'FRUIT', 52, 0.3, 0.2, 13.8, 2.4, 150, 30, 30, 0, 'FRIDGE', 'pcs', 'g', 150.0, 'g'),
  (1002, 'Apricot', 'FRUIT', 48, 1.4, 0.4, 11.1, 2.0, 50, 5, 7, 0, 'FRIDGE', 'pcs', 'g', 50.0, 'g'),
  (1003, 'Avocado', 'FRUIT', 160, 2.0, 14.7, 8.5, 6.7, 200, 7, 7, 0, 'FRIDGE', 'pcs', 'g', 200.0, 'g'),
  (1004, 'Banana', 'FRUIT', 89, 1.1, 0.3, 22.8, 2.6, 120, 7, 7, 0, 'PANTRY', 'pcs', 'g', 120.0, 'g'),
  (1005, 'Blackberry', 'FRUIT', 43, 1.4, 0.5, 9.6, 5.3, 5, 3, 5, 0, 'FRIDGE', 'pcs', 'g', 5.0, 'g'),
  (1006, 'Blueberry', 'FRUIT', 57, 0.7, 0.3, 14.5, 2.4, 20, 3, 5, 0, 'FRIDGE', 'pcs', 'g', 20.0, 'g'),
  (1007, 'Cantaloupe', 'FRUIT', 34, 0.8, 0.2, 8.2, 0.9, 500, 7, 7, 0, 'FRIDGE', 'pcs', 'g', 500.0, 'g'),
  (1008, 'Cherry', 'FRUIT', 63, 1.0, 0.2, 16.0, 2.1, 10, 3, 5, 0, 'FRIDGE', 'pcs', 'g', 10.0, 'g'),
  (1009, 'Coconut', 'FRUIT', 354, 3.3, 33.5, 15.2, 9.0, 400, 30, 30, 0, 'PANTRY', 'pcs', 'g', 400.0, 'g'),
  (1010, 'Dragon-Fruit', 'FRUIT', 60, 1.1, 0.2, 13.3, 1.6, 400, 7, 7, 0, 'FRIDGE', 'pcs', 'g', 400.0, 'g'),
  (1011, 'Grape', 'FRUIT', 69, 0.7, 0.2, 18.1, 0.9, 100, 7, 7, 0, 'FRIDGE', 'pcs', 'g', 100.0, 'g'),
  (1012, 'Guava', 'FRUIT', 68, 2.6, 1.0, 14.3, 5.4, 100, 7, 7, 0, 'FRIDGE', 'pcs', 'g', 100.0, 'g'),
  (1013, 'Kiwifruit', 'FRUIT', 61, 1.1, 0.5, 14.7, 2.6, 100, 7, 14, 0, 'FRIDGE', 'pcs', 'g', 100.0, 'g'),
  (1014, 'Lemon', 'FRUIT', 29, 1.1, 0.3, 9.3, 2.8, 100, 30, 30, 0, 'FRIDGE', 'pcs', 'g', 100.0, 'g'),
  (1015, 'Lime', 'FRUIT', 30, 0.7, 0.2, 10.5, 2.8, 80, 30, 30, 0, 'FRIDGE', 'pcs', 'g', 80.0, 'g'),
  (1016, 'Longan', 'FRUIT', 60, 1.3, 0.1, 15.1, 1.1, 10, 5, 7, 0, 'FRIDGE', 'pcs', 'g', 10.0, 'g'),
  (1017, 'Lychee', 'FRUIT', 66, 0.8, 0.4, 16.5, 1.3, 20, 5, 7, 0, 'FRIDGE', 'pcs', 'g', 20.0, 'g'),
  (1018, 'Mandarin', 'FRUIT', 53, 0.8, 0.3, 13.3, 1.8, 100, 14, 30, 0, 'FRIDGE', 'pcs', 'g', 100.0, 'g'),
  (1019, 'Mango', 'FRUIT', 60, 0.8, 0.4, 15.0, 1.6, 300, 7, 7, 0, 'FRIDGE', 'pcs', 'g', 300.0, 'g'),
  (1020, 'Nectarine', 'FRUIT', 44, 1.1, 0.3, 10.5, 1.7, 150, 5, 7, 0, 'FRIDGE', 'pcs', 'g', 150.0, 'g'),
  (1021, 'Orange', 'FRUIT', 47, 0.9, 0.1, 11.8, 2.4, 200, 14, 30, 0, 'FRIDGE', 'pcs', 'g', 200.0, 'g'),
  (1022, 'Papaya', 'FRUIT', 43, 0.5, 0.3, 10.8, 1.7, 500, 7, 7, 0, 'FRIDGE', 'pcs', 'g', 500.0, 'g'),
  (1023, 'Peach', 'FRUIT', 39, 0.9, 0.1, 9.5, 1.5, 150, 5, 7, 0, 'FRIDGE', 'pcs', 'g', 150.0, 'g'),
  (1024, 'Pear', 'FRUIT', 57, 0.4, 0.1, 15.2, 3.1, 200, 14, 30, 0, 'FRIDGE', 'pcs', 'g', 200.0, 'g'),
  (1025, 'Persimmon', 'FRUIT', 70, 0.6, 0.2, 18.6, 3.6, 200, 7, 14, 0, 'FRIDGE', 'pcs', 'g', 200.0, 'g'),
  (1026, 'Pineapple', 'FRUIT', 50, 0.5, 0.1, 13.1, 1.4, 1000, 5, 7, 0, 'FRIDGE', 'pcs', 'g', 1000.0, 'g'),
  (1027, 'Plum', 'FRUIT', 46, 0.7, 0.3, 11.4, 1.4, 50, 5, 7, 0, 'FRIDGE', 'pcs', 'g', 50.0, 'g'),
  (1028, 'Pomegranate', 'FRUIT', 83, 1.7, 1.2, 18.7, 4.0, 200, 30, 30, 0, 'FRIDGE', 'pcs', 'g', 200.0, 'g'),
  (1029, 'Raspberry', 'FRUIT', 52, 1.2, 0.7, 11.9, 6.5, 5, 3, 5, 0, 'FRIDGE', 'pcs', 'g', 5.0, 'g'),
  (1030, 'Strawberry', 'FRUIT', 32, 0.7, 0.3, 7.7, 2.0, 20, 3, 5, 0, 'FRIDGE', 'pcs', 'g', 20.0, 'g'),
  (1031, 'Watermelon', 'FRUIT', 30, 0.6, 0.1, 7.6, 0.3, 2000, 7, 7, 0, 'FRIDGE', 'pcs', 'g', 2000.0, 'g'),
  (1032, 'Asparagus', 'VEG', 20, 2.2, 0.1, 3.9, 2.1, 100, 3, 5, 0, 'FRIDGE', 'pcs', 'g', 100.0, 'g'),
  (1033, 'Beetroot', 'VEG', 43, 1.6, 0.2, 9.6, 2.8, 200, 14, 30, 0, 'FRIDGE', 'pcs', 'g', 200.0, 'g'),
  (1034, 'Bok-Choy', 'VEG', 15, 1.5, 0.2, 2.7, 1.1, 200, 5, 7, 0, 'FRIDGE', 'pcs', 'g', 200.0, 'g'),
  (1035, 'Broccoli', 'VEG', 34, 2.8, 0.4, 5.2, 2.6, 200, 5, 7, 0, 'FRIDGE', 'pcs', 'g', 200.0, 'g'),
  (1036, 'Cabbage', 'VEG', 16, 1.5, 0.1, 3.2, 1.0, 500, 7, 14, 0, 'FRIDGE', 'pcs', 'g', 500.0, 'g'),
  (1037, 'Capsicum', 'VEG', 31, 1.0, 0.3, 7.4, 1.5, 100, 7, 7, 0, 'FRIDGE', 'pcs', 'g', 100.0, 'g'),
  (1038, 'Carrot', 'VEG', 41, 0.9, 0.2, 9.6, 2.8, 100, 30, 30, 0, 'FRIDGE', 'pcs', 'g', 100.0, 'g'),
  (1039, 'Cauliflower', 'VEG', 25, 2.1, 0.2, 4.6, 1.2, 300, 5, 7, 0, 'FRIDGE', 'pcs', 'g', 300.0, 'g'),
  (1040, 'Celery', 'VEG', 16, 0.7, 0.2, 3.0, 1.6, 100, 7, 14, 0, 'FRIDGE', 'pcs', 'g', 100.0, 'g'),
  (1041, 'Corn', 'VEG', 86, 3.4, 1.2, 19.9, 2.9, 200, 7, 7, 0, 'FRIDGE', 'pcs', 'g', 200.0, 'g'),
  (1042, 'Courgette', 'VEG', 17, 1.2, 0.3, 3.1, 1.0, 200, 7, 7, 0, 'FRIDGE', 'pcs', 'g', 200.0, 'g'),
  (1043, 'Cucumber', 'VEG', 16, 0.7, 0.1, 3.6, 0.5, 200, 7, 7, 0, 'FRIDGE', 'pcs', 'g', 200.0, 'g'),
  (1044, 'Eggplant', 'VEG', 25, 1.1, 0.2, 5.4, 1.3, 250, 5, 7, 0, 'FRIDGE', 'pcs', 'g', 250.0, 'g'),
  (1045, 'Garlic', 'VEG', 149, 6.4, 0.5, 33.1, 2.1, 10, 90, 120, 0, 'PANTRY', 'pcs', 'g', 10.0, 'g'),
  (1046, 'Ginger', 'VEG', 80, 1.8, 0.8, 17.8, 2.0, 50, 30, 30, 0, 'FRIDGE', 'pcs', 'g', 50.0, 'g'),
  (1047, 'Green-Pepper', 'VEG', 22, 1.0, 0.2, 5.4, 1.4, 100, 7, 7, 0, 'FRIDGE', 'pcs', 'g', 100.0, 'g'),
  (1048, 'Kale', 'VEG', 49, 4.3, 0.9, 8.8, 2.0, 100, 3, 5, 0, 'FRIDGE', 'pcs', 'g', 100.0, 'g'),
  (1049, 'Leek', 'VEG', 61, 1.5, 0.3, 14.2, 1.8, 100, 7, 14, 0, 'FRIDGE', 'pcs', 'g', 100.0, 'g'),
  (1050, 'Lettuce', 'VEG', 15, 1.4, 0.2, 2.9, 1.3, 200, 5, 7, 0, 'FRIDGE', 'pcs', 'g', 200.0, 'g'),
  (1051, 'White_Button_Mushroom', 'VEG', 22, 3.1, 0.3, 3.3, 1.0, 50, 3, 7, 0, 'FRIDGE', 'pcs', 'g', 50.0, 'g'),
  (1052, 'Onion', 'VEG', 40, 1.1, 0.1, 9.3, 1.7, 100, 30, 30, 0, 'PANTRY', 'pcs', 'g', 100.0, 'g'),
  (1053, 'Parsnip', 'VEG', 75, 1.2, 0.3, 18.0, 4.9, 200, 30, 30, 0, 'FRIDGE', 'pcs', 'g', 200.0, 'g'),
  (1054, 'Potato', 'VEG', 77, 2.0, 0.1, 17.0, 2.2, 200, 30, 30, 0, 'PANTRY', 'pcs', 'g', 200.0, 'g'),
  (1055, 'Pumpkin', 'VEG', 26, 0.7, 0.1, 6.5, 0.8, 500, 30, 30, 0, 'PANTRY', 'pcs', 'g', 500.0, 'g'),
  (1056, 'Radish', 'VEG', 16, 0.9, 0.1, 3.8, 1.0, 500, 14, 30, 0, 'FRIDGE', 'pcs', 'g', 500.0, 'g'),
  (1057, 'Red-Pepper', 'VEG', 31, 1.0, 0.3, 7.4, 1.5, 100, 7, 7, 0, 'FRIDGE', 'pcs', 'g', 100.0, 'g'),
  (1058, 'Shiitake', 'VEG', 34, 2.2, 0.5, 6.8, 2.5, 20, 3, 7, 0, 'FRIDGE', 'pcs', 'g', 20.0, 'g'),
  (1059, 'Spinach', 'VEG', 23, 2.9, 0.4, 3.6, 2.2, 200, 3, 5, 0, 'FRIDGE', 'pcs', 'g', 200.0, 'g'),
  (1060, 'Spring-Onion', 'VEG', 32, 1.8, 0.2, 7.3, 2.6, 50, 3, 7, 0, 'FRIDGE', 'pcs', 'g', 50.0, 'g'),
  (1061, 'Swede', 'VEG', 36, 0.9, 0.2, 8.6, 2.2, 300, 30, 30, 0, 'FRIDGE', 'pcs', 'g', 300.0, 'g'),
  (1062, 'Sweet-Potato', 'VEG', 86, 1.6, 0.1, 20.1, 3.0, 200, 30, 30, 0, 'PANTRY', 'pcs', 'g', 200.0, 'g'),
  (1063, 'Tomato', 'VEG', 18, 0.9, 0.2, 3.9, 1.2, 150, 7, 14, 0, 'FRIDGE', 'pcs', 'g', 150.0, 'g'),
  (1064, 'Beef', 'MEAT', 250, 26.0, 15.0, 0.0, 0.0, 100, 1, 3, 270, 'FRIDGE', 'g', 'kg', 0.001, 'g'),
  (1065, 'Chicken-Breast', 'MEAT', 165, 31.0, 3.6, 0.0, 0.0, 100, 1, 2, 180, 'FRIDGE', 'g', 'kg', 0.001, 'g'),
  (1066, 'Chicken-Leg', 'MEAT', 184, 24.0, 9.0, 0.0, 0.0, 150, 1, 2, 180, 'FRIDGE', 'pcs', 'g', 150.0, 'g'),
  (1067, 'Chicken-Quater', 'MEAT', 184, 24.0, 9.0, 0.0, 0.0, 200, 1, 2, 180, 'FRIDGE', 'pcs', 'g', 200.0, 'g'),
  (1068, 'Chicken-Thigh', 'MEAT', 181, 20.0, 10.0, 0.0, 0.0, 150, 1, 2, 180, 'FRIDGE', 'pcs', 'g', 150.0, 'g'),
  (1069, 'Chicken-Whole', 'MEAT', 165, 31.0, 3.6, 0.0, 0.0, 1500, 1, 2, 180, 'FRIDGE', 'pcs', 'g', 1500.0, 'g'),
  (1070, 'Chicken-Wing', 'MEAT', 211, 19.0, 14.0, 0.0, 0.0, 80, 1, 2, 180, 'FRIDGE', 'pcs', 'g', 80.0, 'g'),
  (1071, 'Crab', 'MEAT', 97, 19.0, 1.5, 0.0, 0.0, 150, 1, 2, 90, 'FRIDGE', 'pcs', 'g', 150.0, 'g'),
  (1072, 'Egg', 'MEAT', 155, 13.0, 11.0, 1.1, 0.0, 50, 30, 30, 0, 'FRIDGE', 'pcs', 'g', 50.0, 'g'),
  (1073, 'Lamb', 'MEAT', 294, 25.0, 21.0, 0.0, 0.0, 100, 1, 3, 270, 'FRIDGE', 'g', 'kg', 0.001, 'g'),
  (1074, 'Minced-Meat', 'MEAT', 250, 26.0, 15.0, 0.0, 0.0, 100, 1, 2, 90, 'FRIDGE', 'g', 'kg', 0.001, 'g'),
  (1075, 'Mussels', 'MEAT', 86, 11.9, 2.2, 3.7, 0.0, 50, 1, 2, 90, 'FRIDGE', 'pcs', 'g', 50.0, 'g'),
  (1076, 'Pork', 'MEAT', 242, 27.0, 14.0, 0.0, 0.0, 100, 1, 3, 270, 'FRIDGE', 'g', 'kg', 0.001, 'g'),
  (1077, 'Salmon', 'MEAT', 139, 22.0, 5.0, 0.0, 0.0, 150, 1, 2, 90, 'FRIDGE', 'g', 'kg', 0.001, 'g'),
  (1078, 'Sausage', 'MEAT', 301, 13.0, 27.0, 2.0, 0.0, 100, 7, 7, 90, 'FRIDGE', 'pcs', 'g', 100.0, 'g'),
  (1079, 'Scallop', 'MEAT', 88, 16.8, 0.8, 3.2, 0.0, 30, 1, 2, 90, 'FRIDGE', 'pcs', 'g', 30.0, 'g'),
  (1080, 'Sea-Bass', 'MEAT', 124, 20.0, 4.0, 0.0, 0.0, 200, 1, 2, 90, 'FRIDGE', 'g', 'kg', 0.001, 'g'),
  (1081, 'Shrimp', 'MEAT', 99, 24.0, 0.3, 0.2, 0.0, 20, 1, 2, 90, 'FRIDGE', 'pcs', 'g', 20.0, 'g'),
  (1082, 'Snapper', 'MEAT', 100, 20.5, 1.3, 0.0, 0.0, 200, 1, 2, 90, 'FRIDGE', 'g', 'kg', 0.001, 'g'),
  (1083, 'Squid', 'MEAT', 92, 15.6, 1.4, 3.1, 0.0, 100, 1, 2, 90, 'FRIDGE', 'pcs', 'g', 100.0, 'g'),
  (1084, 'Tuna', 'MEAT', 144, 30.0, 0.5, 0.0, 0.0, 100, 1, 2, 90, 'FRIDGE', 'g', 'kg', 0.001, 'g'),
  (1085, 'Bagel', 'GRAIN', 257, 10.0, 1.7, 50.9, 2.3, 50, 3, 7, 0, 'PANTRY', 'pcs', 'g', 50.0, 'g'),
  (1086, 'Brown-rice', 'GRAIN', 348, 7.4, 2.0, 75.0, 0.7, 100, 365, 0, 0, 'PANTRY', 'g', 'kg', 0.001, 'g'),
  (1087, 'Chickpea', 'GRAIN', 364, 19.0, 6.0, 61.0, 17.0, 50, 365, 0, 0, 'PANTRY', 'g', 'kg', 0.001, 'g'),
  (1088, 'Lentil', 'GRAIN', 353, 25.0, 1.1, 63.0, 10.7, 50, 365, 0, 0, 'PANTRY', 'g', 'kg', 0.001, 'g'),
  (1089, 'Millet', 'GRAIN', 361, 9.0, 3.1, 75.1, 1.6, 100, 365, 0, 0, 'PANTRY', 'g', 'kg', 0.001, 'g'),
  (1090, 'Oats', 'GRAIN', 389, 15.0, 6.7, 66.2, 5.3, 100, 365, 0, 0, 'PANTRY', 'g', 'kg', 0.001, 'g'),
  (1091, 'Pasta', 'GRAIN', 131, 5.0, 1.1, 25.0, 1.8, 100, 365, 0, 0, 'PANTRY', 'g', 'kg', 0.001, 'g'),
  (1092, 'White-Rice', 'GRAIN', 130, 2.7, 0.3, 28.0, 0.4, 100, 365, 0, 0, 'PANTRY', 'g', 'kg', 0.001, 'g'),
  (1093, 'Butter', 'DAIRY', 717, 0.5, 81.1, 0.1, 0.0, 50, 30, 90, 0, 'FRIDGE', 'g', 'kg', 0.001, 'g'),
  (1094, 'Milk', 'DAIRY', 54, 3.0, 3.2, 3.4, 0.0, 250, 0, 7, 0, 'FRIDGE', 'ml', 'L', 0.001, 'ml'),
  (1095, 'Sesame-Seeds', 'OTHER', 573, 17.7, 49.7, 23.4, 11.8, 10, 180, 0, 0, 'PANTRY', 'g', 'kg', 0.001, 'g'),
  (1096, 'Tofu', 'OTHER', 76, 8.1, 4.8, 1.9, 0.3, 300, 0, 7, 0, 'FRIDGE', 'pcs', 'g', 300.0, 'g'),
  (1097, 'Yogurt', 'DAIRY', 59, 10.0, 0.4, 3.6, 0.0, 250, 0, 14, 0, 'FRIDGE', 'ml', 'L', 0.001, 'ml'),
  (1098, 'Greek Yogurt', 'DAIRY', 97, 10.0, 5.0, 3.9, 0.0, 200, 0, 14, 0, 'FRIDGE', 'g', 'kg', 0.001, 'g'),
  (1099, 'Cheddar Cheese', 'DAIRY', 402, 25.0, 33.1, 1.3, 0.0, 100, 30, 60, 90, 'FRIDGE', 'g', 'kg', 0.001, 'g'),
  (1100, 'Mozzarella Cheese', 'DAIRY', 300, 22.0, 22.0, 2.2, 0.0, 100, 7, 14, 90, 'FRIDGE', 'g', 'kg', 0.001, 'g'),
  (1101, 'Parmesan Cheese', 'DAIRY', 431, 38.0, 29.0, 4.1, 0.0, 50, 365, 365, 0, 'FRIDGE', 'g', 'kg', 0.001, 'g'),
  (1102, 'Cream Cheese', 'DAIRY', 342, 6.2, 34.4, 4.1, 0.0, 100, 0, 14, 0, 'FRIDGE', 'g', 'kg', 0.001, 'g'),
  (1103, 'Sour Cream', 'DAIRY', 198, 2.3, 19.4, 4.6, 0.0, 250, 0, 14, 0, 'FRIDGE', 'ml', 'L', 0.001, 'ml'),
  (1104, 'Cottage Cheese', 'DAIRY', 98, 11.1, 4.3, 3.4, 0.0, 200, 0, 7, 0, 'FRIDGE', 'g', 'kg', 0.001, 'g'),
  (1105, 'Bacon', 'MEAT', 541, 37.0, 42.0, 1.4, 0.0, 100, 7, 7, 90, 'FRIDGE', 'g', 'kg', 0.001, 'g'),
  (1106, 'Ham', 'MEAT', 145, 21.0, 5.5, 1.5, 0.0, 100, 7, 7, 90, 'FRIDGE', 'g', 'kg', 0.001, 'g'),
  (1107, 'Turkey', 'MEAT', 189, 29.0, 7.0, 0.0, 0.0, 100, 1, 2, 180, 'FRIDGE', 'g', 'kg', 0.001, 'g'),
  (1108, 'Duck', 'MEAT', 337, 19.0, 28.0, 0.0, 0.0, 100, 1, 2, 180, 'FRIDGE', 'g', 'kg', 0.001, 'g'),
  (1109, 'Ground Beef', 'MEAT', 250, 26.0, 15.0, 0.0, 0.0, 100, 1, 2, 90, 'FRIDGE', 'g', 'kg', 0.001, 'g'),
  (1110, 'Ground Turkey', 'MEAT', 189, 29.0, 7.0, 0.0, 0.0, 100, 1, 2, 90, 'FRIDGE', 'g', 'kg', 0.001, 'g'),
  (1111, 'Ground Pork', 'MEAT', 242, 27.0, 14.0, 0.0, 0.0, 100, 1, 2, 90, 'FRIDGE', 'g', 'kg', 0.001, 'g'),
  (1112, 'Lobster', 'MEAT', 98, 20.0, 1.0, 1.3, 0.0, 150, 1, 2, 90, 'FRIDGE', 'pcs', 'g', 150.0, 'g'),
  (1113, 'Clams', 'MEAT', 86, 14.7, 1.0, 3.6, 0.0, 100, 1, 2, 90, 'FRIDGE', 'pcs', 'g', 100.0, 'g'),
  (1114, 'Oysters', 'MEAT', 68, 7.0, 2.5, 3.9, 0.0, 50, 1, 2, 90, 'FRIDGE', 'pcs', 'g', 50.0, 'g'),
  (1115, 'Brussels Sprouts', 'VEG', 43, 3.4, 0.3, 9.0, 3.8, 100, 7, 14, 0, 'FRIDGE', 'pcs', 'g', 100.0, 'g'),
  (1116, 'Artichoke', 'VEG', 47, 3.3, 0.2, 11.0, 5.4, 200, 7, 7, 0, 'FRIDGE', 'pcs', 'g', 200.0, 'g'),
  (1117, 'Arugula', 'VEG', 25, 2.6, 0.7, 3.7, 1.6, 100, 3, 5, 0, 'FRIDGE', 'pcs', 'g', 100.0, 'g'),
  (1118, 'Endive', 'VEG', 17, 1.3, 0.2, 3.4, 3.1, 100, 7, 14, 0, 'FRIDGE', 'pcs', 'g', 100.0, 'g'),
  (1119, 'Fennel', 'VEG', 31, 1.2, 0.2, 7.3, 3.1, 200, 7, 14, 0, 'FRIDGE', 'pcs', 'g', 200.0, 'g'),
  (1120, 'Collard Greens', 'VEG', 32, 3.0, 0.6, 5.7, 4.0, 200, 3, 7, 0, 'FRIDGE', 'pcs', 'g', 200.0, 'g'),
  (1121, 'Swiss Chard', 'VEG', 19, 1.8, 0.2, 3.7, 1.6, 200, 3, 7, 0, 'FRIDGE', 'pcs', 'g', 200.0, 'g'),
  (1122, 'Turnip', 'VEG', 28, 0.9, 0.1, 6.4, 1.8, 150, 14, 30, 0, 'FRIDGE', 'pcs', 'g', 150.0, 'g'),
  (1123, 'Beans', 'VEG', 31, 1.8, 0.1, 7.0, 2.5, 150, 3, 5, 0, 'FRIDGE', 'g', 'kg', 0.001, 'g'),
  (1124, 'Green Beans', 'VEG', 31, 1.8, 0.1, 7.0, 2.5, 150, 3, 5, 0, 'FRIDGE', 'g', 'kg', 0.001, 'g'),
  (1125, 'Peas', 'VEG', 81, 5.4, 0.4, 14.5, 5.1, 100, 3, 5, 0, 'FRIDGE', 'g', 'kg', 0.001, 'g'),
  (1126, 'Edamame', 'VEG', 122, 11.0, 5.2, 9.9, 5.2, 100, 0, 3, 0, 'FRIDGE', 'g', 'kg', 0.001, 'g'),
  (1127, 'Bean Sprouts', 'VEG', 30, 3.0, 0.2, 5.9, 1.8, 100, 3, 5, 0, 'FRIDGE', 'g', 'kg', 0.001, 'g'),
  (1128, 'Cranberry', 'FRUIT', 46, 0.4, 0.1, 12.2, 4.6, 5, 30, 60, 0, 'FRIDGE', 'pcs', 'g', 5.0, 'g'),
  (1129, 'Gooseberry', 'FRUIT', 44, 0.9, 0.6, 10.2, 4.3, 5, 7, 14, 0, 'FRIDGE', 'pcs', 'g', 5.0, 'g'),
  (1130, 'Elderberry', 'FRUIT', 73, 0.7, 0.5, 18.4, 7.0, 5, 3, 7, 0, 'FRIDGE', 'pcs', 'g', 5.0, 'g'),
  (1131, 'Figs', 'FRUIT', 74, 0.8, 0.3, 19.2, 2.9, 50, 3, 7, 0, 'FRIDGE', 'pcs', 'g', 50.0, 'g'),
  (1132, 'Dates', 'FRUIT', 282, 2.5, 0.4, 75.0, 8.0, 10, 90, 180, 0, 'PANTRY', 'pcs', 'g', 10.0, 'g'),
  (1133, 'Olives', 'OTHER', 115, 0.8, 10.7, 6.0, 3.2, 10, 180, 365, 0, 'PANTRY', 'pcs', 'g', 10.0, 'g'),
  (1134, 'Capers', 'OTHER', 23, 2.4, 0.9, 5.0, 3.2, 10, 365, 365, 0, 'PANTRY', 'g', 'kg', 0.001, 'g'),
  (1135, 'Sun-Dried Tomatoes', 'OTHER', 258, 14.1, 2.9, 55.8, 12.3, 50, 365, 365, 0, 'PANTRY', 'g', 'kg', 0.001, 'g'),
  (1136, 'Roasted Red Peppers', 'OTHER', 31, 1.0, 0.3, 7.4, 1.5, 100, 7, 30, 0, 'FRIDGE', 'g', 'kg', 0.001, 'g'),
  (1137, 'Frozen Vegetables', 'OTHER', 65, 3.0, 0.4, 13.0, 4.0, 100, 0, 0, 270, 'FREEZER', 'g', 'kg', 0.001, 'g'),
  (1138, 'Frozen Fruits', 'OTHER', 57, 0.7, 0.3, 14.5, 2.4, 100, 0, 0, 270, 'FREEZER', 'g', 'kg', 0.001, 'g'),
  (1139, 'Frozen Berries', 'OTHER', 57, 0.7, 0.3, 14.5, 2.4, 100, 0, 0, 270, 'FREEZER', 'g', 'kg', 0.001, 'g'),
  (1140, 'Ice Cream', 'DAIRY', 207, 3.5, 11.0, 23.6, 0.7, 100, 0, 0, 180, 'FREEZER', 'ml', 'L', 0.001, 'ml')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  category = EXCLUDED.category,
  calories = EXCLUDED.calories,
  protein = EXCLUDED.protein,
  fat = EXCLUDED.fat,
  carb = EXCLUDED.carb,
  fiber = EXCLUDED.fiber,
  average_gram_per_unit = EXCLUDED.average_gram_per_unit,
  shelf_life_pantry = EXCLUDED.shelf_life_pantry,
  shelf_life_fridge = EXCLUDED.shelf_life_fridge,
  shelf_life_freezer = EXCLUDED.shelf_life_freezer,
  default_location = EXCLUDED.default_location,
  primary_unit = EXCLUDED.primary_unit,
  secondary_unit = EXCLUDED.secondary_unit,
  unit_conversion_factor = EXCLUDED.unit_conversion_factor,
  standard_unit = EXCLUDED.standard_unit;

-- ============================================
-- 4. 插入标准调料库（StandardSpice）
-- ============================================
INSERT INTO ref_standard_spices (id, name)
VALUES 
  (3001, 'Salt'),
  (3002, 'Black Pepper'),
  (3003, 'Soy Sauce'),
  (3004, 'Vinegar'),
  (3005, 'Cooking Wine'),
  (3006, 'Light Soy Sauce'),
  (3007, 'Dark Soy Sauce'),
  (3008, 'Oyster Sauce'),
  (3009, 'Bean Paste'),
  (3010, 'Chili Powder'),
  (3011, 'Five Spice Powder'),
  (3012, 'Sichuan Pepper'),
  (3013, 'Star Anise'),
  (3014, 'Cinnamon'),
  (3015, 'Bay Leaf'),
  (3016, 'Garlic Powder'),
  (3017, 'Ginger Powder'),
  (3018, 'Curry Powder'),
  (3019, 'Paprika'),
  (3020, 'Turmeric'),
  (3021, 'Cumin'),
  (3022, 'Coriander'),
  (3023, 'Basil'),
  (3024, 'Oregano'),
  (3025, 'Thyme'),
  (3026, 'Rosemary'),
  (3027, 'Sesame Oil'),
  (3028, 'Olive Oil'),
  (3029, 'Vegetable Oil'),
  (3030, 'Sugar')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;

-- ============================================
-- 5. 插入标准厨具库（StandardUtensil）
-- ============================================
INSERT INTO ref_standard_utensils (id, name, icon_url)
VALUES 
  (2001, 'Frying Pan', 'icon_pan.png'),
  (2002, 'Wok', 'icon_wok.png'),
  (2003, 'Pot', 'icon_pot.png'),
  (2004, 'Steamer', 'icon_steamer.png'),
  (2005, 'Pressure Cooker', 'icon_pressure_cooker.png'),
  (2006, 'Clay Pot', 'icon_clay_pot.png'),
  (2007, 'Oven', 'icon_oven.png'),
  (2008, 'Microwave', 'icon_microwave.png'),
  (2009, 'Rice Cooker', 'icon_rice_cooker.png'),
  (2010, 'Air Fryer', 'icon_air_fryer.png'),
  (2011, 'Blender', 'icon_blender.png'),
  (2012, 'Juicer', 'icon_juicer.png'),
  (2013, 'Food Processor', 'icon_food_processor.png'),
  (2014, 'Cutting Board', 'icon_cutting_board.png'),
  (2015, 'Knife', 'icon_knife.png'),
  (2016, 'Spatula', 'icon_spatula.png'),
  (2017, 'Ladle', 'icon_ladle.png'),
  (2018, 'Tongs', 'icon_tongs.png'),
  (2019, 'Whisk', 'icon_whisk.png'),
  (2020, 'Strainer', 'icon_strainer.png'),
  (2021, 'Colander', 'icon_colander.png'),
  (2022, 'Grater', 'icon_grater.png'),
  (2023, 'Peeler', 'icon_peeler.png'),
  (2024, 'Measuring Cup', 'icon_measuring_cup.png'),
  (2025, 'Measuring Spoon', 'icon_measuring_spoon.png')
ON CONFLICT (id) DO UPDATE SET 
  name = EXCLUDED.name,
  icon_url = EXCLUDED.icon_url;

-- ============================================
-- 6. 关联食材与过敏原
-- ============================================
INSERT INTO ingredient_allergens (ingredient_id, allergen_id)
SELECT 1072, 3
WHERE NOT EXISTS (SELECT 1 FROM ingredient_allergens WHERE ingredient_id = 1072 AND allergen_id = 3);

INSERT INTO ingredient_allergens (ingredient_id, allergen_id)
SELECT 1094, 2
WHERE NOT EXISTS (SELECT 1 FROM ingredient_allergens WHERE ingredient_id = 1094 AND allergen_id = 2);

INSERT INTO ingredient_allergens (ingredient_id, allergen_id)
SELECT id, 6
FROM ref_standard_ingredients
WHERE name IN ('Salmon', 'Tuna', 'Sea-Bass', 'Crab', 'Mussels', 'Squid', 'Scallop', 'Shrimp', 'Snapper')
AND NOT EXISTS (SELECT 1 FROM ingredient_allergens WHERE ingredient_id = ref_standard_ingredients.id AND allergen_id = 6);

-- ============================================
-- 7. 关联调料与过敏原
-- ============================================
INSERT INTO spice_allergens (spice_id, allergen_id)
SELECT 3003, 4
WHERE NOT EXISTS (SELECT 1 FROM spice_allergens WHERE spice_id = 3003 AND allergen_id = 4);

INSERT INTO spice_allergens (spice_id, allergen_id)
SELECT 3009, 4
WHERE NOT EXISTS (SELECT 1 FROM spice_allergens WHERE spice_id = 3009 AND allergen_id = 4);
