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
INSERT INTO ref_standard_ingredients (id, name, category, calories, protein, fat, carb, fiber, average_gram_per_unit, shelf_life_pantry, shelf_life_fridge, shelf_life_freezer, default_location)
VALUES 
  (1001, '鸡胸肉', 'MEAT', 165, 31.0, 3.6, 0.0, 0.0, 100, 1, 2, 180, 'FRIDGE'),
  (1002, '鸡蛋', 'MEAT', 155, 13.0, 11.0, 1.1, 0.0, 50, 30, 30, 0, 'FRIDGE'),
  (1003, '西红柿', 'VEG', 18, 0.9, 0.2, 3.9, 1.2, 150, 7, 14, 0, 'FRIDGE'),
  (1004, '胡萝卜', 'VEG', 41, 0.9, 0.2, 9.6, 2.8, 100, 30, 30, 0, 'FRIDGE'),
  (1005, '土豆', 'VEG', 77, 2.0, 0.1, 17.0, 2.2, 200, 30, 30, 0, 'PANTRY'),
  (1006, '洋葱', 'VEG', 40, 1.1, 0.1, 9.3, 1.7, 150, 30, 30, 0, 'PANTRY'),
  (1007, '大米', 'GRAIN', 130, 2.7, 0.3, 28.0, 0.4, 100, 365, 0, 0, 'PANTRY'),
  (1008, '牛肉', 'MEAT', 250, 26.0, 15.0, 0.0, 0.0, 100, 1, 3, 270, 'FRIDGE'),
  (1009, '猪肉', 'MEAT', 242, 27.0, 14.0, 0.0, 0.0, 100, 1, 3, 270, 'FRIDGE'),
  (1010, '豆腐', 'VEG', 76, 8.1, 4.8, 1.9, 0.3, 200, 1, 3, 0, 'FRIDGE')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  category = EXCLUDED.category,
  calories = EXCLUDED.calories,
  protein = EXCLUDED.protein,
  fat = EXCLUDED.fat,
  carb = EXCLUDED.carb,
  fiber = EXCLUDED.fiber,
  average_gram_per_unit = EXCLUDED.average_gram_per_unit,
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
