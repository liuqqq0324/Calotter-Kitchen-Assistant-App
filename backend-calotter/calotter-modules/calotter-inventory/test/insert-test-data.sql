-- Inventory API 测试数据注入脚本
-- 使用方法: docker exec -i calotter_postgres psql -U postgres -d calotter < insert-test-data.sql

-- ============================================
-- 1. 插入测试用户
-- ============================================
-- 注意：使用 DO UPDATE SET 确保即使用户已存在，也会更新密码哈希和其他字段
-- 这样可以避免密码哈希不一致的问题
INSERT INTO users (username, password_hash, email, role, status, is_onboarded, create_time, update_time)
VALUES 
  ('testuser', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'testuser@example.com', 'ROLE_USER', 1, false, NOW(), NOW()),
  ('inventory_test', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'inventory_test@example.com', 'ROLE_USER', 1, false, NOW(), NOW())
ON CONFLICT (username) DO UPDATE SET
  password_hash = EXCLUDED.password_hash,
  email = EXCLUDED.email,
  role = EXCLUDED.role,
  status = EXCLUDED.status,
  is_onboarded = EXCLUDED.is_onboarded,
  update_time = NOW();

-- ============================================
-- 2. 插入测试家庭（Household）
-- ============================================
-- 使用子查询动态获取 testuser 的 ID，确保 household 正确关联
-- 这样无论 testuser 的 ID 是多少，都能正确创建关联的 household
INSERT INTO households (name, invite_code, owner_id, create_time, update_time)
SELECT 
  'Test Household 1',
  'TEST001',
  u.id,
  NOW(),
  NOW()
FROM users u
WHERE u.username = 'testuser'
LIMIT 1
ON CONFLICT (invite_code) DO NOTHING;

INSERT INTO households (name, invite_code, owner_id, create_time, update_time)
SELECT 
  'Test Household 2',
  'TEST002',
  u.id,
  NOW(),
  NOW()
FROM users u
WHERE u.username = 'testuser'
LIMIT 1
ON CONFLICT (invite_code) DO NOTHING;

-- ============================================
-- 3. 插入标准食材库（StandardIngredient）
-- ============================================
-- 注意：扩展了食材数据，用于测试精确匹配和模糊匹配查找功能
INSERT INTO ref_standard_ingredients (id, name, category, calories, protein, fat, carb, fiber, average_gram_per_unit, shelf_life_pantry, shelf_life_fridge, shelf_life_freezer, default_location)
VALUES 
  -- 肉类 (MEAT) - ID: 1001-1020
  (1001, 'Chicken Breast', 'MEAT', 165, 31.0, 3.6, 0.0, 0.0, 100, 1, 2, 180, 'FRIDGE'),
  (1002, 'Egg', 'MEAT', 155, 13.0, 11.0, 1.1, 0.0, 50, 30, 30, 0, 'FRIDGE'),
  (1008, 'Beef', 'MEAT', 250, 26.0, 15.0, 0.0, 0.0, 100, 1, 3, 270, 'FRIDGE'),
  (1009, 'Pork', 'MEAT', 242, 27.0, 14.0, 0.0, 0.0, 100, 1, 3, 270, 'FRIDGE'),
  (1011, 'Chicken Thigh', 'MEAT', 181, 20.0, 10.0, 0.0, 0.0, 150, 1, 2, 180, 'FRIDGE'),
  (1012, 'Chicken Wing', 'MEAT', 211, 19.0, 14.0, 0.0, 0.0, 80, 1, 2, 180, 'FRIDGE'),
  (1013, 'Duck', 'MEAT', 240, 19.0, 18.0, 0.0, 0.0, 100, 1, 2, 180, 'FRIDGE'),
  (1014, 'Lamb', 'MEAT', 206, 20.0, 12.0, 0.0, 0.0, 100, 1, 3, 270, 'FRIDGE'),
  (1015, 'Fish', 'MEAT', 144, 20.0, 6.0, 0.0, 0.0, 100, 1, 2, 90, 'FRIDGE'),
  (1016, 'Shrimp', 'MEAT', 99, 24.0, 0.2, 0.0, 0.0, 30, 1, 2, 90, 'FRIDGE'),
  (1017, 'Ribbonfish', 'MEAT', 127, 17.7, 4.9, 0.0, 0.0, 200, 1, 2, 90, 'FRIDGE'),
  (1018, 'Salmon', 'MEAT', 139, 22.0, 5.0, 0.0, 0.0, 150, 1, 2, 90, 'FRIDGE'),
  (1019, 'Pork Ribs', 'MEAT', 264, 18.0, 20.0, 0.0, 0.0, 200, 1, 3, 270, 'FRIDGE'),
  (1020, 'Pork Belly', 'MEAT', 395, 9.0, 40.0, 0.0, 0.0, 100, 1, 3, 270, 'FRIDGE'),
  
  -- 蔬菜类 (VEG) - ID: 1003-1006, 1010, 1021-1050
  (1003, 'Tomato', 'VEG', 18, 0.9, 0.2, 3.9, 1.2, 150, 7, 14, 0, 'FRIDGE'),
  (1004, 'Carrot', 'VEG', 41, 0.9, 0.2, 9.6, 2.8, 100, 30, 30, 0, 'FRIDGE'),
  (1005, 'Potato', 'VEG', 77, 2.0, 0.1, 17.0, 2.2, 200, 30, 30, 0, 'PANTRY'),
  (1006, 'Onion', 'VEG', 40, 1.1, 0.1, 9.3, 1.7, 150, 30, 30, 0, 'PANTRY'),
  (1010, 'Tofu', 'VEG', 76, 8.1, 4.8, 1.9, 0.3, 200, 1, 3, 0, 'FRIDGE'),
  (1021, 'Cabbage', 'VEG', 16, 1.5, 0.1, 3.2, 1.0, 500, 7, 14, 0, 'FRIDGE'),
  (1022, 'Napa Cabbage', 'VEG', 16, 1.5, 0.1, 3.2, 1.0, 800, 7, 14, 0, 'FRIDGE'),
  (1023, 'Baby Bok Choy', 'VEG', 15, 1.5, 0.2, 2.7, 1.1, 200, 5, 7, 0, 'FRIDGE'),
  (1024, 'Green Vegetable', 'VEG', 20, 2.0, 0.3, 3.0, 1.2, 200, 5, 7, 0, 'FRIDGE'),
  (1025, 'Spinach', 'VEG', 23, 2.9, 0.4, 3.6, 2.2, 200, 3, 5, 0, 'FRIDGE'),
  (1026, 'Celery', 'VEG', 16, 0.8, 0.1, 3.9, 1.4, 200, 7, 14, 0, 'FRIDGE'),
  (1027, 'Chinese Chive', 'VEG', 25, 2.4, 0.4, 4.5, 1.4, 150, 3, 5, 0, 'FRIDGE'),
  (1028, 'Lettuce', 'VEG', 15, 1.4, 0.2, 2.9, 1.3, 200, 5, 7, 0, 'FRIDGE'),
  (1029, 'Cabbage Head', 'VEG', 25, 1.5, 0.2, 5.4, 1.0, 500, 7, 14, 0, 'FRIDGE'),
  (1030, 'Cauliflower', 'VEG', 25, 2.1, 0.2, 4.6, 1.2, 300, 5, 7, 0, 'FRIDGE'),
  (1031, 'Broccoli', 'VEG', 34, 2.8, 0.4, 5.2, 2.6, 200, 5, 7, 0, 'FRIDGE'),
  (1032, 'Cucumber', 'VEG', 16, 0.7, 0.1, 3.6, 0.5, 200, 7, 7, 0, 'FRIDGE'),
  (1033, 'Eggplant', 'VEG', 25, 1.1, 0.2, 5.4, 1.3, 250, 5, 7, 0, 'FRIDGE'),
  (1034, 'Green Bell Pepper', 'VEG', 22, 1.0, 0.2, 5.4, 1.4, 100, 7, 7, 0, 'FRIDGE'),
  (1035, 'Red Bell Pepper', 'VEG', 31, 1.0, 0.3, 7.4, 1.5, 100, 7, 7, 0, 'FRIDGE'),
  (1036, 'Chili Pepper', 'VEG', 27, 1.3, 0.4, 6.2, 2.1, 50, 7, 14, 0, 'FRIDGE'),
  (1037, 'Green Bean', 'VEG', 31, 2.5, 0.2, 6.7, 2.1, 200, 5, 7, 0, 'FRIDGE'),
  (1038, 'Snap Bean', 'VEG', 31, 2.5, 0.2, 6.7, 2.1, 200, 5, 7, 0, 'FRIDGE'),
  (1039, 'Lima Bean', 'VEG', 37, 2.7, 0.2, 7.4, 2.1, 200, 5, 7, 0, 'FRIDGE'),
  (1040, 'Winter Melon', 'VEG', 11, 0.4, 0.0, 2.6, 0.7, 1000, 7, 14, 0, 'FRIDGE'),
  (1041, 'Pumpkin', 'VEG', 26, 0.7, 0.1, 6.5, 0.8, 500, 30, 30, 0, 'PANTRY'),
  (1042, 'Luffa', 'VEG', 20, 1.0, 0.2, 4.2, 0.6, 300, 5, 7, 0, 'FRIDGE'),
  (1043, 'Bitter Melon', 'VEG', 19, 1.0, 0.1, 4.9, 1.4, 300, 5, 7, 0, 'FRIDGE'),
  (1044, 'White Radish', 'VEG', 16, 0.9, 0.1, 3.8, 1.0, 500, 14, 30, 0, 'FRIDGE'),
  (1045, 'Green Radish', 'VEG', 29, 1.1, 0.1, 6.8, 1.3, 500, 14, 30, 0, 'FRIDGE'),
  (1046, 'Lotus Root', 'VEG', 47, 1.9, 0.2, 11.5, 1.2, 300, 7, 14, 0, 'FRIDGE'),
  (1047, 'Corn', 'VEG', 86, 3.4, 1.2, 19.9, 2.9, 200, 7, 7, 0, 'FRIDGE'),
  (1048, 'Pea', 'VEG', 81, 7.4, 0.3, 14.4, 3.0, 100, 3, 5, 0, 'FRIDGE'),
  (1049, 'Edamame', 'VEG', 131, 13.1, 5.0, 10.5, 4.0, 200, 3, 5, 0, 'FRIDGE'),
  (1050, 'Mushroom', 'VEG', 22, 2.7, 0.1, 4.1, 2.5, 150, 3, 5, 0, 'FRIDGE'),
  
  -- 谷物类 (GRAIN) - ID: 1007, 1051-1060
  (1007, 'Rice', 'GRAIN', 130, 2.7, 0.3, 28.0, 0.4, 100, 365, 0, 0, 'PANTRY'),
  (1051, 'Millet', 'GRAIN', 361, 9.0, 3.1, 75.1, 1.6, 100, 365, 0, 0, 'PANTRY'),
  (1052, 'Noodle', 'GRAIN', 109, 4.2, 0.7, 22.1, 0.4, 100, 180, 0, 0, 'PANTRY'),
  (1053, 'Dried Noodle', 'GRAIN', 109, 4.2, 0.7, 22.1, 0.4, 100, 365, 0, 0, 'PANTRY'),
  (1054, 'Flour', 'GRAIN', 364, 9.4, 1.4, 75.9, 0.3, 100, 180, 0, 0, 'PANTRY'),
  (1055, 'Bread', 'GRAIN', 266, 8.3, 3.1, 50.6, 0.5, 50, 3, 7, 0, 'PANTRY'),
  (1056, 'Oat', 'GRAIN', 389, 15.0, 6.7, 66.2, 5.3, 100, 365, 0, 0, 'PANTRY'),
  (1057, 'Black Rice', 'GRAIN', 341, 9.4, 2.5, 72.2, 3.9, 100, 365, 0, 0, 'PANTRY'),
  (1058, 'Brown Rice', 'GRAIN', 348, 7.4, 2.0, 75.0, 0.7, 100, 365, 0, 0, 'PANTRY'),
  (1059, 'Glutinous Rice', 'GRAIN', 348, 7.3, 1.0, 78.3, 0.6, 100, 365, 0, 0, 'PANTRY'),
  (1060, 'Mung Bean', 'GRAIN', 316, 21.6, 0.8, 62.0, 6.4, 100, 365, 0, 0, 'PANTRY'),
  
  -- 水果类 (FRUIT) - ID: 1061-1075
  (1061, 'Apple', 'FRUIT', 52, 0.3, 0.2, 13.8, 2.4, 150, 30, 30, 0, 'FRIDGE'),
  (1062, 'Banana', 'FRUIT', 89, 1.1, 0.3, 22.8, 2.6, 120, 7, 7, 0, 'PANTRY'),
  (1063, 'Orange', 'FRUIT', 47, 0.9, 0.1, 11.8, 2.4, 200, 14, 30, 0, 'FRIDGE'),
  (1064, 'Tangerine', 'FRUIT', 43, 0.8, 0.1, 10.6, 1.4, 150, 14, 30, 0, 'FRIDGE'),
  (1065, 'Pear', 'FRUIT', 57, 0.4, 0.1, 15.2, 3.1, 200, 14, 30, 0, 'FRIDGE'),
  (1066, 'Grape', 'FRUIT', 69, 0.7, 0.2, 18.1, 0.9, 100, 7, 7, 0, 'FRIDGE'),
  (1067, 'Strawberry', 'FRUIT', 32, 0.7, 0.3, 7.7, 2.0, 20, 3, 5, 0, 'FRIDGE'),
  (1068, 'Watermelon', 'FRUIT', 30, 0.6, 0.1, 7.6, 0.3, 2000, 7, 7, 0, 'FRIDGE'),
  (1069, 'Peach', 'FRUIT', 39, 0.9, 0.1, 9.5, 1.5, 150, 5, 7, 0, 'FRIDGE'),
  (1070, 'Plum', 'FRUIT', 36, 0.7, 0.2, 8.7, 2.2, 100, 5, 7, 0, 'FRIDGE'),
  (1071, 'Mango', 'FRUIT', 60, 0.8, 0.4, 15.0, 1.6, 300, 7, 7, 0, 'FRIDGE'),
  (1072, 'Kiwi', 'FRUIT', 61, 1.1, 0.5, 14.7, 2.6, 100, 7, 14, 0, 'FRIDGE'),
  (1073, 'Lemon', 'FRUIT', 29, 1.1, 0.3, 9.3, 2.8, 100, 30, 30, 0, 'FRIDGE'),
  (1074, 'Pomelo', 'FRUIT', 41, 0.8, 0.2, 10.3, 1.0, 1000, 30, 30, 0, 'FRIDGE'),
  (1075, 'Dragon Fruit', 'FRUIT', 60, 1.1, 0.2, 13.3, 1.6, 400, 7, 7, 0, 'FRIDGE'),
  
  -- 豆制品类 (BEAN) - ID: 1076-1080
  (1076, 'Soy Milk', 'BEAN', 31, 1.8, 1.1, 1.8, 0.0, 250, 1, 2, 0, 'FRIDGE'),
  (1077, 'Dried Tofu', 'BEAN', 140, 16.2, 3.6, 11.5, 0.4, 100, 3, 5, 0, 'FRIDGE'),
  (1078, 'Bean Curd Stick', 'BEAN', 457, 44.6, 21.7, 22.3, 1.0, 50, 180, 0, 0, 'PANTRY'),
  (1079, 'Tofu Skin', 'BEAN', 409, 44.6, 17.4, 18.8, 0.2, 50, 3, 5, 0, 'FRIDGE'),
  (1080, 'Soybean', 'BEAN', 359, 35.0, 16.0, 34.2, 15.5, 100, 365, 0, 0, 'PANTRY'),
  
  -- 其他类 (OTHER) - ID: 1081-1090
  (1081, 'Milk', 'DAIRY', 54, 3.0, 3.2, 3.4, 0.0, 250, 0, 7, 0, 'FRIDGE'),
  (1082, 'Yogurt', 'DAIRY', 99, 2.5, 3.3, 15.0, 0.0, 100, 0, 14, 0, 'FRIDGE'),
  (1083, 'Cheese', 'DAIRY', 328, 25.0, 23.5, 3.5, 0.0, 50, 0, 30, 0, 'FRIDGE'),
  (1084, 'Butter', 'DAIRY', 717, 0.5, 81.1, 0.1, 0.0, 50, 30, 90, 0, 'FRIDGE'),
  (1085, 'Peanut', 'NUT', 563, 24.8, 44.3, 21.7, 8.0, 50, 180, 0, 0, 'PANTRY'),
  (1086, 'Walnut', 'NUT', 654, 14.9, 65.2, 13.7, 9.5, 30, 180, 0, 0, 'PANTRY'),
  (1087, 'Almond', 'NUT', 578, 22.1, 50.6, 19.7, 11.8, 30, 180, 0, 0, 'PANTRY'),
  (1088, 'Wood Ear Mushroom', 'OTHER', 21, 1.5, 0.2, 6.0, 2.6, 50, 180, 0, 0, 'PANTRY'),
  (1089, 'Tremella', 'OTHER', 200, 10.0, 1.4, 67.3, 30.4, 50, 180, 0, 0, 'PANTRY'),
  (1090, 'Kelp', 'OTHER', 17, 1.8, 0.1, 3.0, 0.5, 100, 30, 0, 0, 'PANTRY')
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
  default_location = EXCLUDED.default_location;

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
  (3015, 'Bay Leaf')
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
  (2015, 'Knife', 'icon_knife.png')
ON CONFLICT (id) DO UPDATE SET 
  name = EXCLUDED.name,
  icon_url = EXCLUDED.icon_url;

-- ============================================
-- 6. 插入测试过敏原（RefAllergen）
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
  (8, 'Fish', 'Fish allergy')
ON CONFLICT (id) DO UPDATE SET 
  name = EXCLUDED.name,
  description = EXCLUDED.description;

-- ============================================
-- 7. 可选：插入一些测试食材库存（用于测试）
-- ============================================
-- 注意：需要先确保household_id存在
INSERT INTO household_ingredients (household_id, standard_ingredient_id, quantity, unit, expiration_date, location, create_time, update_time)
SELECT 
  h.id,
  1001, -- Chicken Breast
  500.0,
  'g',
  CURRENT_DATE + INTERVAL '7 days',
  'FRIDGE',
  NOW(),
  NOW()
FROM households h
WHERE h.invite_code = 'TEST001'
ON CONFLICT DO NOTHING;

INSERT INTO household_ingredients (household_id, standard_ingredient_id, quantity, unit, expiration_date, location, create_time, update_time)
SELECT 
  h.id,
  1003, -- Tomato
  1000.0,
  'g',
  CURRENT_DATE + INTERVAL '5 days',
  'FRIDGE',
  NOW(),
  NOW()
FROM households h
WHERE h.invite_code = 'TEST001'
ON CONFLICT DO NOTHING;

-- ============================================
-- 8. 可选：插入一些测试调料（用于测试）
-- ============================================
INSERT INTO household_spices (household_id, standard_spice_id, is_available, remark, create_time, update_time)
SELECT 
  h.id,
  3001, -- Salt
  true,
  'Test spice',
  NOW(),
  NOW()
FROM households h
WHERE h.invite_code = 'TEST001'
ON CONFLICT DO NOTHING;

INSERT INTO household_spices (household_id, standard_spice_id, is_available, remark, create_time, update_time)
SELECT 
  h.id,
  3003, -- Soy Sauce
  true,
  'Test spice',
  NOW(),
  NOW()
FROM households h
WHERE h.invite_code = 'TEST001'
ON CONFLICT DO NOTHING;

-- ============================================
-- 9. 可选：插入一些测试厨具（用于测试）
-- ============================================
INSERT INTO household_utensils (household_id, standard_utensil_id, is_available, remark, create_time, update_time)
SELECT 
  h.id,
  2001, -- Frying Pan
  true,
  'Test utensil',
  NOW(),
  NOW()
FROM households h
WHERE h.invite_code = 'TEST001'
ON CONFLICT DO NOTHING;

INSERT INTO household_utensils (household_id, standard_utensil_id, is_available, remark, create_time, update_time)
SELECT 
  h.id,
  2002, -- Wok
  true,
  'Test utensil',
  NOW(),
  NOW()
FROM households h
WHERE h.invite_code = 'TEST001'
ON CONFLICT DO NOTHING;

-- ============================================
-- 10. 可选：插入一些测试剩菜（用于测试）
-- ============================================
-- 注意：household_leftovers 表已迁移，包含 dish_name, cover_image, calories_per_100g 字段
INSERT INTO household_leftovers (
  household_id, 
  original_dish_id,
  dish_name, 
  cover_image, 
  current_quantity_gram, 
  calories_per_100g,
  produced_time, 
  create_time, 
  update_time
)
SELECT 
  h.id,
  1, -- 假设的 dish_id
  'Test Leftover - Braised Pork',
  'https://example.com/image.jpg',
  500,
  250, -- 每100克250卡路里
  NOW() - INTERVAL '1 day',
  NOW(),
  NOW()
FROM households h
WHERE h.invite_code = 'TEST001'
ON CONFLICT DO NOTHING;

-- ============================================
-- 查询验证数据
-- ============================================
SELECT 'Users created:' as info, COUNT(*) as count FROM users WHERE username IN ('testuser', 'inventory_test');
SELECT 'Households created:' as info, COUNT(*) as count FROM households WHERE invite_code IN ('TEST001', 'TEST002');
SELECT 'Standard Ingredients:' as info, COUNT(*) as count FROM ref_standard_ingredients;
SELECT 'Standard Spices:' as info, COUNT(*) as count FROM ref_standard_spices;
SELECT 'Standard Utensils:' as info, COUNT(*) as count FROM ref_standard_utensils;
SELECT 'Standard Allergens:' as info, COUNT(*) as count FROM ref_standard_allergens;

-- 按分类统计食材
SELECT 'Ingredients by category:' as info, category, COUNT(*) as count 
FROM ref_standard_ingredients 
GROUP BY category 
ORDER BY category;

-- 显示部分食材示例（用于验证）
SELECT 'Sample ingredients:' as info, id, name, category, default_location 
FROM ref_standard_ingredients 
ORDER BY id 
LIMIT 20;
