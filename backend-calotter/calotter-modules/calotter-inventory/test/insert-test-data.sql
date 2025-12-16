-- Inventory API 测试数据注入脚本
-- 使用方法: docker exec -i calotter_postgres psql -U postgres -d calotter < insert-test-data.sql

-- ============================================
-- 1. 插入测试用户
-- ============================================
INSERT INTO users (username, password_hash, email, role, status, is_onboarded, create_time, update_time)
VALUES 
  ('testuser', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'testuser@example.com', 'ROLE_USER', 1, false, NOW(), NOW()),
  ('inventory_test', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'inventory_test@example.com', 'ROLE_USER', 1, false, NOW(), NOW())
ON CONFLICT (username) DO NOTHING;

-- 获取测试用户ID（用于创建Household）
-- 注意：这里假设testuser的ID是1，如果不存在会自动创建

-- ============================================
-- 2. 插入测试家庭（Household）
-- ============================================
INSERT INTO households (name, invite_code, owner_id, create_time, update_time)
VALUES 
  ('测试家庭1', 'TEST001', 1, NOW(), NOW()),
  ('测试家庭2', 'TEST002', 1, NOW(), NOW())
ON CONFLICT (invite_code) DO NOTHING;

-- ============================================
-- 3. 插入标准食材库（StandardIngredient）
-- ============================================
-- 注意：扩展了食材数据，用于测试精确匹配和模糊匹配查找功能
INSERT INTO ref_standard_ingredients (id, name, category, calories, protein, fat, carb, fiber, average_gram_per_unit, shelf_life_pantry, shelf_life_fridge, shelf_life_freezer, default_location)
VALUES 
  -- 肉类 (MEAT) - ID: 1001-1020
  (1001, '鸡胸肉', 'MEAT', 165, 31.0, 3.6, 0.0, 0.0, 100, 1, 2, 180, 'FRIDGE'),
  (1002, '鸡蛋', 'MEAT', 155, 13.0, 11.0, 1.1, 0.0, 50, 30, 30, 0, 'FRIDGE'),
  (1008, '牛肉', 'MEAT', 250, 26.0, 15.0, 0.0, 0.0, 100, 1, 3, 270, 'FRIDGE'),
  (1009, '猪肉', 'MEAT', 242, 27.0, 14.0, 0.0, 0.0, 100, 1, 3, 270, 'FRIDGE'),
  (1011, '鸡腿', 'MEAT', 181, 20.0, 10.0, 0.0, 0.0, 150, 1, 2, 180, 'FRIDGE'),
  (1012, '鸡翅', 'MEAT', 211, 19.0, 14.0, 0.0, 0.0, 80, 1, 2, 180, 'FRIDGE'),
  (1013, '鸭肉', 'MEAT', 240, 19.0, 18.0, 0.0, 0.0, 100, 1, 2, 180, 'FRIDGE'),
  (1014, '羊肉', 'MEAT', 206, 20.0, 12.0, 0.0, 0.0, 100, 1, 3, 270, 'FRIDGE'),
  (1015, '鱼肉', 'MEAT', 144, 20.0, 6.0, 0.0, 0.0, 100, 1, 2, 90, 'FRIDGE'),
  (1016, '虾', 'MEAT', 99, 24.0, 0.2, 0.0, 0.0, 30, 1, 2, 90, 'FRIDGE'),
  (1017, '带鱼', 'MEAT', 127, 17.7, 4.9, 0.0, 0.0, 200, 1, 2, 90, 'FRIDGE'),
  (1018, '三文鱼', 'MEAT', 139, 22.0, 5.0, 0.0, 0.0, 150, 1, 2, 90, 'FRIDGE'),
  (1019, '排骨', 'MEAT', 264, 18.0, 20.0, 0.0, 0.0, 200, 1, 3, 270, 'FRIDGE'),
  (1020, '五花肉', 'MEAT', 395, 9.0, 40.0, 0.0, 0.0, 100, 1, 3, 270, 'FRIDGE'),
  
  -- 蔬菜类 (VEG) - ID: 1003-1006, 1010, 1021-1050
  (1003, '西红柿', 'VEG', 18, 0.9, 0.2, 3.9, 1.2, 150, 7, 14, 0, 'FRIDGE'),
  (1004, '胡萝卜', 'VEG', 41, 0.9, 0.2, 9.6, 2.8, 100, 30, 30, 0, 'FRIDGE'),
  (1005, '土豆', 'VEG', 77, 2.0, 0.1, 17.0, 2.2, 200, 30, 30, 0, 'PANTRY'),
  (1006, '洋葱', 'VEG', 40, 1.1, 0.1, 9.3, 1.7, 150, 30, 30, 0, 'PANTRY'),
  (1010, '豆腐', 'VEG', 76, 8.1, 4.8, 1.9, 0.3, 200, 1, 3, 0, 'FRIDGE'),
  (1021, '白菜', 'VEG', 16, 1.5, 0.1, 3.2, 1.0, 500, 7, 14, 0, 'FRIDGE'),
  (1022, '大白菜', 'VEG', 16, 1.5, 0.1, 3.2, 1.0, 800, 7, 14, 0, 'FRIDGE'),
  (1023, '小白菜', 'VEG', 15, 1.5, 0.2, 2.7, 1.1, 200, 5, 7, 0, 'FRIDGE'),
  (1024, '青菜', 'VEG', 20, 2.0, 0.3, 3.0, 1.2, 200, 5, 7, 0, 'FRIDGE'),
  (1025, '菠菜', 'VEG', 23, 2.9, 0.4, 3.6, 2.2, 200, 3, 5, 0, 'FRIDGE'),
  (1026, '芹菜', 'VEG', 16, 0.8, 0.1, 3.9, 1.4, 200, 7, 14, 0, 'FRIDGE'),
  (1027, '韭菜', 'VEG', 25, 2.4, 0.4, 4.5, 1.4, 150, 3, 5, 0, 'FRIDGE'),
  (1028, '生菜', 'VEG', 15, 1.4, 0.2, 2.9, 1.3, 200, 5, 7, 0, 'FRIDGE'),
  (1029, '卷心菜', 'VEG', 25, 1.5, 0.2, 5.4, 1.0, 500, 7, 14, 0, 'FRIDGE'),
  (1030, '花菜', 'VEG', 25, 2.1, 0.2, 4.6, 1.2, 300, 5, 7, 0, 'FRIDGE'),
  (1031, '西兰花', 'VEG', 34, 2.8, 0.4, 5.2, 2.6, 200, 5, 7, 0, 'FRIDGE'),
  (1032, '黄瓜', 'VEG', 16, 0.7, 0.1, 3.6, 0.5, 200, 7, 7, 0, 'FRIDGE'),
  (1033, '茄子', 'VEG', 25, 1.1, 0.2, 5.4, 1.3, 250, 5, 7, 0, 'FRIDGE'),
  (1034, '青椒', 'VEG', 22, 1.0, 0.2, 5.4, 1.4, 100, 7, 7, 0, 'FRIDGE'),
  (1035, '红椒', 'VEG', 31, 1.0, 0.3, 7.4, 1.5, 100, 7, 7, 0, 'FRIDGE'),
  (1036, '辣椒', 'VEG', 27, 1.3, 0.4, 6.2, 2.1, 50, 7, 14, 0, 'FRIDGE'),
  (1037, '豆角', 'VEG', 31, 2.5, 0.2, 6.7, 2.1, 200, 5, 7, 0, 'FRIDGE'),
  (1038, '四季豆', 'VEG', 31, 2.5, 0.2, 6.7, 2.1, 200, 5, 7, 0, 'FRIDGE'),
  (1039, '扁豆', 'VEG', 37, 2.7, 0.2, 7.4, 2.1, 200, 5, 7, 0, 'FRIDGE'),
  (1040, '冬瓜', 'VEG', 11, 0.4, 0.0, 2.6, 0.7, 1000, 7, 14, 0, 'FRIDGE'),
  (1041, '南瓜', 'VEG', 26, 0.7, 0.1, 6.5, 0.8, 500, 30, 30, 0, 'PANTRY'),
  (1042, '丝瓜', 'VEG', 20, 1.0, 0.2, 4.2, 0.6, 300, 5, 7, 0, 'FRIDGE'),
  (1043, '苦瓜', 'VEG', 19, 1.0, 0.1, 4.9, 1.4, 300, 5, 7, 0, 'FRIDGE'),
  (1044, '白萝卜', 'VEG', 16, 0.9, 0.1, 3.8, 1.0, 500, 14, 30, 0, 'FRIDGE'),
  (1045, '青萝卜', 'VEG', 29, 1.1, 0.1, 6.8, 1.3, 500, 14, 30, 0, 'FRIDGE'),
  (1046, '莲藕', 'VEG', 47, 1.9, 0.2, 11.5, 1.2, 300, 7, 14, 0, 'FRIDGE'),
  (1047, '玉米', 'VEG', 86, 3.4, 1.2, 19.9, 2.9, 200, 7, 7, 0, 'FRIDGE'),
  (1048, '豌豆', 'VEG', 81, 7.4, 0.3, 14.4, 3.0, 100, 3, 5, 0, 'FRIDGE'),
  (1049, '毛豆', 'VEG', 131, 13.1, 5.0, 10.5, 4.0, 200, 3, 5, 0, 'FRIDGE'),
  (1050, '蘑菇', 'VEG', 22, 2.7, 0.1, 4.1, 2.5, 150, 3, 5, 0, 'FRIDGE'),
  
  -- 谷物类 (GRAIN) - ID: 1007, 1051-1060
  (1007, '大米', 'GRAIN', 130, 2.7, 0.3, 28.0, 0.4, 100, 365, 0, 0, 'PANTRY'),
  (1051, '小米', 'GRAIN', 361, 9.0, 3.1, 75.1, 1.6, 100, 365, 0, 0, 'PANTRY'),
  (1052, '面条', 'GRAIN', 109, 4.2, 0.7, 22.1, 0.4, 100, 180, 0, 0, 'PANTRY'),
  (1053, '挂面', 'GRAIN', 109, 4.2, 0.7, 22.1, 0.4, 100, 365, 0, 0, 'PANTRY'),
  (1054, '面粉', 'GRAIN', 364, 9.4, 1.4, 75.9, 0.3, 100, 180, 0, 0, 'PANTRY'),
  (1055, '面包', 'GRAIN', 266, 8.3, 3.1, 50.6, 0.5, 50, 3, 7, 0, 'PANTRY'),
  (1056, '燕麦', 'GRAIN', 389, 15.0, 6.7, 66.2, 5.3, 100, 365, 0, 0, 'PANTRY'),
  (1057, '黑米', 'GRAIN', 341, 9.4, 2.5, 72.2, 3.9, 100, 365, 0, 0, 'PANTRY'),
  (1058, '糙米', 'GRAIN', 348, 7.4, 2.0, 75.0, 0.7, 100, 365, 0, 0, 'PANTRY'),
  (1059, '糯米', 'GRAIN', 348, 7.3, 1.0, 78.3, 0.6, 100, 365, 0, 0, 'PANTRY'),
  (1060, '绿豆', 'GRAIN', 316, 21.6, 0.8, 62.0, 6.4, 100, 365, 0, 0, 'PANTRY'),
  
  -- 水果类 (FRUIT) - ID: 1061-1075
  (1061, '苹果', 'FRUIT', 52, 0.3, 0.2, 13.8, 2.4, 150, 30, 30, 0, 'FRIDGE'),
  (1062, '香蕉', 'FRUIT', 89, 1.1, 0.3, 22.8, 2.6, 120, 7, 7, 0, 'PANTRY'),
  (1063, '橙子', 'FRUIT', 47, 0.9, 0.1, 11.8, 2.4, 200, 14, 30, 0, 'FRIDGE'),
  (1064, '橘子', 'FRUIT', 43, 0.8, 0.1, 10.6, 1.4, 150, 14, 30, 0, 'FRIDGE'),
  (1065, '梨', 'FRUIT', 57, 0.4, 0.1, 15.2, 3.1, 200, 14, 30, 0, 'FRIDGE'),
  (1066, '葡萄', 'FRUIT', 69, 0.7, 0.2, 18.1, 0.9, 100, 7, 7, 0, 'FRIDGE'),
  (1067, '草莓', 'FRUIT', 32, 0.7, 0.3, 7.7, 2.0, 20, 3, 5, 0, 'FRIDGE'),
  (1068, '西瓜', 'FRUIT', 30, 0.6, 0.1, 7.6, 0.3, 2000, 7, 7, 0, 'FRIDGE'),
  (1069, '桃子', 'FRUIT', 39, 0.9, 0.1, 9.5, 1.5, 150, 5, 7, 0, 'FRIDGE'),
  (1070, '李子', 'FRUIT', 36, 0.7, 0.2, 8.7, 2.2, 100, 5, 7, 0, 'FRIDGE'),
  (1071, '芒果', 'FRUIT', 60, 0.8, 0.4, 15.0, 1.6, 300, 7, 7, 0, 'FRIDGE'),
  (1072, '猕猴桃', 'FRUIT', 61, 1.1, 0.5, 14.7, 2.6, 100, 7, 14, 0, 'FRIDGE'),
  (1073, '柠檬', 'FRUIT', 29, 1.1, 0.3, 9.3, 2.8, 100, 30, 30, 0, 'FRIDGE'),
  (1074, '柚子', 'FRUIT', 41, 0.8, 0.2, 10.3, 1.0, 1000, 30, 30, 0, 'FRIDGE'),
  (1075, '火龙果', 'FRUIT', 60, 1.1, 0.2, 13.3, 1.6, 400, 7, 7, 0, 'FRIDGE'),
  
  -- 豆制品类 (BEAN) - ID: 1076-1080
  (1076, '豆浆', 'BEAN', 31, 1.8, 1.1, 1.8, 0.0, 250, 1, 2, 0, 'FRIDGE'),
  (1077, '豆干', 'BEAN', 140, 16.2, 3.6, 11.5, 0.4, 100, 3, 5, 0, 'FRIDGE'),
  (1078, '腐竹', 'BEAN', 457, 44.6, 21.7, 22.3, 1.0, 50, 180, 0, 0, 'PANTRY'),
  (1079, '豆皮', 'BEAN', 409, 44.6, 17.4, 18.8, 0.2, 50, 3, 5, 0, 'FRIDGE'),
  (1080, '黄豆', 'BEAN', 359, 35.0, 16.0, 34.2, 15.5, 100, 365, 0, 0, 'PANTRY'),
  
  -- 其他类 (OTHER) - ID: 1081-1090
  (1081, '牛奶', 'DAIRY', 54, 3.0, 3.2, 3.4, 0.0, 250, 0, 7, 0, 'FRIDGE'),
  (1082, '酸奶', 'DAIRY', 99, 2.5, 3.3, 15.0, 0.0, 100, 0, 14, 0, 'FRIDGE'),
  (1083, '奶酪', 'DAIRY', 328, 25.0, 23.5, 3.5, 0.0, 50, 0, 30, 0, 'FRIDGE'),
  (1084, '黄油', 'DAIRY', 717, 0.5, 81.1, 0.1, 0.0, 50, 30, 90, 0, 'FRIDGE'),
  (1085, '花生', 'NUT', 563, 24.8, 44.3, 21.7, 8.0, 50, 180, 0, 0, 'PANTRY'),
  (1086, '核桃', 'NUT', 654, 14.9, 65.2, 13.7, 9.5, 30, 180, 0, 0, 'PANTRY'),
  (1087, '杏仁', 'NUT', 578, 22.1, 50.6, 19.7, 11.8, 30, 180, 0, 0, 'PANTRY'),
  (1088, '木耳', 'OTHER', 21, 1.5, 0.2, 6.0, 2.6, 50, 180, 0, 0, 'PANTRY'),
  (1089, '银耳', 'OTHER', 200, 10.0, 1.4, 67.3, 30.4, 50, 180, 0, 0, 'PANTRY'),
  (1090, '海带', 'OTHER', 17, 1.8, 0.1, 3.0, 0.5, 100, 30, 0, 0, 'PANTRY')
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
  (3001, '盐'),
  (3002, '胡椒粉'),
  (3003, '酱油'),
  (3004, '醋'),
  (3005, '料酒'),
  (3006, '生抽'),
  (3007, '老抽'),
  (3008, '蚝油'),
  (3009, '豆瓣酱'),
  (3010, '辣椒粉'),
  (3011, '五香粉'),
  (3012, '花椒'),
  (3013, '八角'),
  (3014, '桂皮'),
  (3015, '香叶')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;

-- ============================================
-- 5. 插入标准厨具库（StandardUtensil）
-- ============================================
INSERT INTO ref_standard_utensils (id, name, icon_url)
VALUES 
  (2001, '平底锅', 'icon_pan.png'),
  (2002, '炒锅', 'icon_wok.png'),
  (2003, '汤锅', 'icon_pot.png'),
  (2004, '蒸锅', 'icon_steamer.png'),
  (2005, '高压锅', 'icon_pressure_cooker.png'),
  (2006, '砂锅', 'icon_clay_pot.png'),
  (2007, '烤箱', 'icon_oven.png'),
  (2008, '微波炉', 'icon_microwave.png'),
  (2009, '电饭煲', 'icon_rice_cooker.png'),
  (2010, '空气炸锅', 'icon_air_fryer.png'),
  (2011, '搅拌机', 'icon_blender.png'),
  (2012, '榨汁机', 'icon_juicer.png'),
  (2013, '料理机', 'icon_food_processor.png'),
  (2014, '切菜板', 'icon_cutting_board.png'),
  (2015, '刀具', 'icon_knife.png')
ON CONFLICT (id) DO UPDATE SET 
  name = EXCLUDED.name,
  icon_url = EXCLUDED.icon_url;

-- ============================================
-- 6. 插入测试过敏原（RefAllergen）
-- ============================================
INSERT INTO ref_standard_allergens (id, name, description)
VALUES 
  (1, '花生', '可能引起严重过敏反应'),
  (2, '牛奶', '乳糖不耐受'),
  (3, '鸡蛋', '常见过敏原'),
  (4, '大豆', '常见过敏原'),
  (5, '小麦', '麸质不耐受'),
  (6, '海鲜', '甲壳类过敏'),
  (7, '坚果', '树坚果过敏'),
  (8, '鱼类', '鱼类过敏')
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
  1001, -- 鸡胸肉
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
  1003, -- 西红柿
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
  3001, -- 盐
  true,
  '测试调料',
  NOW(),
  NOW()
FROM households h
WHERE h.invite_code = 'TEST001'
ON CONFLICT DO NOTHING;

INSERT INTO household_spices (household_id, standard_spice_id, is_available, remark, create_time, update_time)
SELECT 
  h.id,
  3003, -- 酱油
  true,
  '测试调料',
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
  2001, -- 平底锅
  true,
  '测试厨具',
  NOW(),
  NOW()
FROM households h
WHERE h.invite_code = 'TEST001'
ON CONFLICT DO NOTHING;

INSERT INTO household_utensils (household_id, standard_utensil_id, is_available, remark, create_time, update_time)
SELECT 
  h.id,
  2002, -- 炒锅
  true,
  '测试厨具',
  NOW(),
  NOW()
FROM households h
WHERE h.invite_code = 'TEST001'
ON CONFLICT DO NOTHING;

-- ============================================
-- 10. 可选：插入一些测试剩菜（用于测试）
-- ============================================
INSERT INTO household_leftovers (household_id, name, cover_image, quantity_gram, produced_time, create_time, update_time)
SELECT 
  h.id,
  '测试剩菜-红烧肉',
  'https://example.com/image.jpg',
  500.0,
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
