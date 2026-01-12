-- ============================================
-- 标准库数据初始化脚本
-- Standard Libraries Data Initialization Script
-- ============================================
-- 
-- 使用方法:
--   docker exec -i calotter_postgres psql -U postgres -d calotter < init-standard-libraries.sql
--   或直接使用 psql: psql -h localhost -U postgres -d calotter -f init-standard-libraries.sql
-- 
-- Usage:
--   docker exec -i calotter_postgres psql -U postgres -d calotter < init-standard-libraries.sql
--   or directly: psql -h localhost -U postgres -d calotter -f init-standard-libraries.sql
--
-- 注意：
--   1. 此脚本会初始化标准库数据（过敏原、食材、调料、厨具）
--   2. 使用 ON CONFLICT 确保幂等性，可重复执行
--   3. 不会影响现有用户数据
--
-- ============================================
-- 1. 清空现有标准库数据（可选，谨慎使用）
-- Clear existing standard library data (optional, use with caution)
-- ============================================
-- 如果需要完全重置标准库，取消下面的注释：
-- If you need to completely reset standard libraries, uncomment below:
--
-- DELETE FROM ingredient_allergens;
-- DELETE FROM spice_allergens;
-- DELETE FROM ref_standard_ingredients;
-- DELETE FROM ref_standard_spices;
-- DELETE FROM ref_standard_utensils;
-- DELETE FROM ref_standard_allergens;

-- ============================================
-- 2. 插入标准过敏原库（RefAllergen）
-- Insert Standard Allergens
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

-- 重置序列（如果需要）
SELECT setval('ref_standard_allergens_id_seq', (SELECT MAX(id) FROM ref_standard_allergens));

-- ============================================
-- 3. 插入标准食材库（StandardIngredient）
-- Insert Standard Ingredients (77 items based on ML model labels)
-- ============================================
INSERT INTO ref_standard_ingredients (id, name, category, calories, protein, fat, carb, fiber, average_gram_per_unit, shelf_life_pantry, shelf_life_fridge, shelf_life_freezer, default_location, primary_unit, secondary_unit, unit_conversion_factor, standard_unit)
VALUES 
  -- Fruits (FRUIT) - ID: 1001-1024
  -- 对于有 average_gram_per_unit 的食材：primary_unit='pcs', secondary_unit='g', unit_conversion_factor=average_gram_per_unit, standard_unit='g'
  (1001, 'Apple', 'FRUIT', 52, 0.3, 0.2, 13.8, 2.4, 150, 30, 30, 0, 'FRIDGE', 'pcs', 'g', 150.0, 'g'),
  (1002, 'Apricot', 'FRUIT', 48, 1.4, 0.4, 11.1, 2.0, 50, 5, 7, 0, 'FRIDGE', 'pcs', 'g', 50.0, 'g'),
  (1003, 'Banana', 'FRUIT', 89, 1.1, 0.3, 22.8, 2.6, 120, 7, 7, 0, 'PANTRY', 'pcs', 'g', 120.0, 'g'),
  (1004, 'Blueberry', 'FRUIT', 57, 0.7, 0.3, 14.5, 2.4, 20, 3, 5, 0, 'FRIDGE', 'pcs', 'g', 20.0, 'g'),
  (1005, 'Cantaloupe', 'FRUIT', 34, 0.8, 0.2, 8.2, 0.9, 500, 7, 7, 0, 'FRIDGE', 'pcs', 'g', 500.0, 'g'),
  (1006, 'Cherry', 'FRUIT', 63, 1.0, 0.2, 16.0, 2.1, 10, 3, 5, 0, 'FRIDGE', 'pcs', 'g', 10.0, 'g'),
  (1007, 'Coconut', 'FRUIT', 354, 3.3, 33.5, 15.2, 9.0, 400, 30, 30, 0, 'PANTRY', 'pcs', 'g', 400.0, 'g'),
  (1008, 'Dragon-Fruit', 'FRUIT', 60, 1.1, 0.2, 13.3, 1.6, 400, 7, 7, 0, 'FRIDGE', 'pcs', 'g', 400.0, 'g'),
  (1009, 'Grape', 'FRUIT', 69, 0.7, 0.2, 18.1, 0.9, 100, 7, 7, 0, 'FRIDGE', 'pcs', 'g', 100.0, 'g'),
  (1010, 'Kiwifruit', 'FRUIT', 61, 1.1, 0.5, 14.7, 2.6, 100, 7, 14, 0, 'FRIDGE', 'pcs', 'g', 100.0, 'g'),
  (1011, 'Lemon', 'FRUIT', 29, 1.1, 0.3, 9.3, 2.8, 100, 30, 30, 0, 'FRIDGE', 'pcs', 'g', 100.0, 'g'),
  (1012, 'Lime', 'FRUIT', 30, 0.7, 0.2, 10.5, 2.8, 80, 30, 30, 0, 'FRIDGE', 'pcs', 'g', 80.0, 'g'),
  (1013, 'Longan', 'FRUIT', 60, 1.3, 0.1, 15.1, 1.1, 10, 5, 7, 0, 'FRIDGE', 'pcs', 'g', 10.0, 'g'),
  (1014, 'Lychee', 'FRUIT', 66, 0.8, 0.4, 16.5, 1.3, 20, 5, 7, 0, 'FRIDGE', 'pcs', 'g', 20.0, 'g'),
  (1015, 'Mango', 'FRUIT', 60, 0.8, 0.4, 15.0, 1.6, 300, 7, 7, 0, 'FRIDGE', 'pcs', 'g', 300.0, 'g'),
  (1016, 'Orange', 'FRUIT', 47, 0.9, 0.1, 11.8, 2.4, 200, 14, 30, 0, 'FRIDGE', 'pcs', 'g', 200.0, 'g'),
  (1017, 'Papaya', 'FRUIT', 43, 0.5, 0.3, 10.8, 1.7, 500, 7, 7, 0, 'FRIDGE', 'pcs', 'g', 500.0, 'g'),
  (1018, 'Peach', 'FRUIT', 39, 0.9, 0.1, 9.5, 1.5, 150, 5, 7, 0, 'FRIDGE', 'pcs', 'g', 150.0, 'g'),
  (1019, 'Pear', 'FRUIT', 57, 0.4, 0.1, 15.2, 3.1, 200, 14, 30, 0, 'FRIDGE', 'pcs', 'g', 200.0, 'g'),
  (1020, 'Persimmon', 'FRUIT', 70, 0.6, 0.2, 18.6, 3.6, 200, 7, 14, 0, 'FRIDGE', 'pcs', 'g', 200.0, 'g'),
  (1021, 'Pineapple', 'FRUIT', 50, 0.5, 0.1, 13.1, 1.4, 1000, 5, 7, 0, 'FRIDGE', 'pcs', 'g', 1000.0, 'g'),
  (1022, 'PomoGranate', 'FRUIT', 83, 1.7, 1.2, 18.7, 4.0, 200, 30, 30, 0, 'FRIDGE', 'pcs', 'g', 200.0, 'g'),
  (1023, 'Strawberry', 'FRUIT', 32, 0.7, 0.3, 7.7, 2.0, 20, 3, 5, 0, 'FRIDGE', 'pcs', 'g', 20.0, 'g'),
  (1024, 'Watermelon', 'FRUIT', 30, 0.6, 0.1, 7.6, 0.3, 2000, 7, 7, 0, 'FRIDGE', 'pcs', 'g', 2000.0, 'g'),

  -- Vegetables (VEG) - ID: 1025-1048
  (1025, 'Asparagus', 'VEG', 20, 2.2, 0.1, 3.9, 2.1, 100, 3, 5, 0, 'FRIDGE', 'pcs', 'g', 100.0, 'g'),
  (1026, 'Beetroot', 'VEG', 43, 1.6, 0.2, 9.6, 2.8, 200, 14, 30, 0, 'FRIDGE', 'pcs', 'g', 200.0, 'g'),
  (1027, 'Bok-Choy', 'VEG', 15, 1.5, 0.2, 2.7, 1.1, 200, 5, 7, 0, 'FRIDGE', 'pcs', 'g', 200.0, 'g'),
  (1028, 'Broccoli', 'VEG', 34, 2.8, 0.4, 5.2, 2.6, 200, 5, 7, 0, 'FRIDGE', 'pcs', 'g', 200.0, 'g'),
  (1029, 'Cabbage', 'VEG', 16, 1.5, 0.1, 3.2, 1.0, 500, 7, 14, 0, 'FRIDGE', 'pcs', 'g', 500.0, 'g'),
  (1030, 'Carrot', 'VEG', 41, 0.9, 0.2, 9.6, 2.8, 100, 30, 30, 0, 'FRIDGE', 'pcs', 'g', 100.0, 'g'),
  (1031, 'Cauliflower', 'VEG', 25, 2.1, 0.2, 4.6, 1.2, 300, 5, 7, 0, 'FRIDGE', 'pcs', 'g', 300.0, 'g'),
  (1032, 'Corn', 'VEG', 86, 3.4, 1.2, 19.9, 2.9, 200, 7, 7, 0, 'FRIDGE', 'pcs', 'g', 200.0, 'g'),
  (1033, 'Cucumbers', 'VEG', 16, 0.7, 0.1, 3.6, 0.5, 200, 7, 7, 0, 'FRIDGE', 'pcs', 'g', 200.0, 'g'),
  (1034, 'Eggplant', 'VEG', 25, 1.1, 0.2, 5.4, 1.3, 250, 5, 7, 0, 'FRIDGE', 'pcs', 'g', 250.0, 'g'),
  (1035, 'Garlic', 'VEG', 149, 6.4, 0.5, 33.1, 2.1, 10, 90, 120, 0, 'PANTRY', 'pcs', 'g', 10.0, 'g'),
  (1036, 'Ginger', 'VEG', 80, 1.8, 0.8, 17.8, 2.0, 50, 30, 30, 0, 'FRIDGE', 'pcs', 'g', 50.0, 'g'),
  (1037, 'Green-Pepper', 'VEG', 22, 1.0, 0.2, 5.4, 1.4, 100, 7, 7, 0, 'FRIDGE', 'pcs', 'g', 100.0, 'g'),
  (1038, 'Kale', 'VEG', 49, 4.3, 0.9, 8.8, 2.0, 100, 3, 5, 0, 'FRIDGE', 'pcs', 'g', 100.0, 'g'),
  (1039, 'Lettuce', 'VEG', 15, 1.4, 0.2, 2.9, 1.3, 200, 5, 7, 0, 'FRIDGE', 'pcs', 'g', 200.0, 'g'),
  (1040, 'Potato', 'VEG', 77, 2.0, 0.1, 17.0, 2.2, 200, 30, 30, 0, 'PANTRY', 'pcs', 'g', 200.0, 'g'),
  (1041, 'Pumpkin', 'VEG', 26, 0.7, 0.1, 6.5, 0.8, 500, 30, 30, 0, 'PANTRY', 'pcs', 'g', 500.0, 'g'),
  (1042, 'Radish', 'VEG', 16, 0.9, 0.1, 3.8, 1.0, 500, 14, 30, 0, 'FRIDGE', 'pcs', 'g', 500.0, 'g'),
  (1043, 'Red-Pepper', 'VEG', 31, 1.0, 0.3, 7.4, 1.5, 100, 7, 7, 0, 'FRIDGE', 'pcs', 'g', 100.0, 'g'),
  (1044, 'Spanich', 'VEG', 23, 2.9, 0.4, 3.6, 2.2, 200, 3, 5, 0, 'FRIDGE', 'pcs', 'g', 200.0, 'g'),
  (1045, 'Spring-Onion', 'VEG', 32, 1.8, 0.2, 7.3, 2.6, 50, 3, 7, 0, 'FRIDGE', 'pcs', 'g', 50.0, 'g'),
  (1046, 'Sweet-Potato', 'VEG', 86, 1.6, 0.1, 20.1, 3.0, 200, 30, 30, 0, 'PANTRY', 'pcs', 'g', 200.0, 'g'),
  (1047, 'Tomato', 'VEG', 18, 0.9, 0.2, 3.9, 1.2, 150, 7, 14, 0, 'FRIDGE', 'pcs', 'g', 150.0, 'g'),
  (1048, 'Zucchini', 'VEG', 17, 1.2, 0.3, 3.1, 1.0, 200, 7, 7, 0, 'FRIDGE', 'pcs', 'g', 200.0, 'g'),

  -- Meat & Protein (MEAT) - ID: 1055-1074
  -- 肉类通常以克为单位，primary_unit='g', secondary_unit='kg', unit_conversion_factor=1000.0, standard_unit='g'
  (1055, 'Beef-Lean', 'MEAT', 250, 26.0, 15.0, 0.0, 0.0, 100, 1, 3, 270, 'FRIDGE', 'g', 'kg', 1000.0, 'g'),
  (1056, 'Beef-Medium', 'MEAT', 250, 26.0, 15.0, 0.0, 0.0, 100, 1, 3, 270, 'FRIDGE', 'g', 'kg', 1000.0, 'g'),
  (1057, 'Beef-Medium-Lean', 'MEAT', 250, 26.0, 15.0, 0.0, 0.0, 100, 1, 3, 270, 'FRIDGE', 'g', 'kg', 1000.0, 'g'),
  (1058, 'Beef-marbled', 'MEAT', 250, 26.0, 15.0, 0.0, 0.0, 100, 1, 3, 270, 'FRIDGE', 'g', 'kg', 1000.0, 'g'),
  (1059, 'Beef-marbled-A5', 'MEAT', 250, 26.0, 15.0, 0.0, 0.0, 100, 1, 3, 270, 'FRIDGE', 'g', 'kg', 1000.0, 'g'),
  (1060, 'Chicken-Breast', 'MEAT', 165, 31.0, 3.6, 0.0, 0.0, 100, 1, 2, 180, 'FRIDGE', 'g', 'kg', 1000.0, 'g'),
  (1061, 'Chicken-Leg', 'MEAT', 184, 24.0, 9.0, 0.0, 0.0, 150, 1, 2, 180, 'FRIDGE', 'pcs', 'g', 150.0, 'g'),
  (1062, 'Chicken-Quater', 'MEAT', 184, 24.0, 9.0, 0.0, 0.0, 200, 1, 2, 180, 'FRIDGE', 'pcs', 'g', 200.0, 'g'),
  (1063, 'Chicken-Thigh', 'MEAT', 181, 20.0, 10.0, 0.0, 0.0, 150, 1, 2, 180, 'FRIDGE', 'pcs', 'g', 150.0, 'g'),
  (1064, 'Chicken-Wing', 'MEAT', 211, 19.0, 14.0, 0.0, 0.0, 80, 1, 2, 180, 'FRIDGE', 'pcs', 'g', 80.0, 'g'),
  (1065, 'Eggs', 'MEAT', 155, 13.0, 11.0, 1.1, 0.0, 50, 30, 30, 0, 'FRIDGE', 'pcs', 'g', 50.0, 'g'),
  (1066, 'Minced-Meat', 'MEAT', 250, 26.0, 15.0, 0.0, 0.0, 100, 1, 2, 90, 'FRIDGE', 'g', 'kg', 1000.0, 'g'),
  (1067, 'Pork', 'MEAT', 242, 27.0, 14.0, 0.0, 0.0, 100, 1, 3, 270, 'FRIDGE', 'g', 'kg', 1000.0, 'g'),
  (1068, 'Salmon', 'MEAT', 139, 22.0, 5.0, 0.0, 0.0, 150, 1, 2, 90, 'FRIDGE', 'g', 'kg', 1000.0, 'g'),
  (1069, 'Sausage', 'MEAT', 301, 13.0, 27.0, 2.0, 0.0, 100, 7, 7, 90, 'FRIDGE', 'pcs', 'g', 100.0, 'g'),
  (1070, 'Sea-Bass', 'MEAT', 124, 20.0, 4.0, 0.0, 0.0, 200, 1, 2, 90, 'FRIDGE', 'g', 'kg', 1000.0, 'g'),
  (1071, 'Tuna', 'MEAT', 144, 30.0, 0.5, 0.0, 0.0, 100, 1, 2, 90, 'FRIDGE', 'g', 'kg', 1000.0, 'g'),
  (1072, 'Crab', 'MEAT', 97, 19.0, 1.5, 0.0, 0.0, 150, 1, 2, 90, 'FRIDGE', 'pcs', 'g', 150.0, 'g'),
  (1073, 'Mussels', 'MEAT', 86, 11.9, 2.2, 3.7, 0.0, 50, 1, 2, 90, 'FRIDGE', 'pcs', 'g', 50.0, 'g'),
  (1074, 'Squid', 'MEAT', 92, 15.6, 1.4, 3.1, 0.0, 100, 1, 2, 90, 'FRIDGE', 'pcs', 'g', 100.0, 'g'),

  -- Grains & Starches (GRAIN) - ID: 1075-1080
  (1075, 'Bagel', 'GRAIN', 257, 10.0, 1.7, 50.9, 2.3, 50, 3, 7, 0, 'PANTRY', 'pcs', 'g', 50.0, 'g'),
  (1076, 'Brown-rice', 'GRAIN', 348, 7.4, 2.0, 75.0, 0.7, 100, 365, 0, 0, 'PANTRY', 'g', 'kg', 1000.0, 'g'),
  (1077, 'Millet', 'GRAIN', 361, 9.0, 3.1, 75.1, 1.6, 100, 365, 0, 0, 'PANTRY', 'g', 'kg', 1000.0, 'g'),
  (1078, 'Oats', 'GRAIN', 389, 15.0, 6.7, 66.2, 5.3, 100, 365, 0, 0, 'PANTRY', 'g', 'kg', 1000.0, 'g'),
  (1079, 'Pasta', 'GRAIN', 131, 5.0, 1.1, 25.0, 1.8, 100, 365, 0, 0, 'PANTRY', 'g', 'kg', 1000.0, 'g'),
  (1080, 'White-Rice', 'GRAIN', 130, 2.7, 0.3, 28.0, 0.4, 100, 365, 0, 0, 'PANTRY', 'g', 'kg', 1000.0, 'g'),

  -- Dairy & Others (DAIRY/OTHER) - ID: 1081-1083
  (1081, 'Butter', 'DAIRY', 717, 0.5, 81.1, 0.1, 0.0, 50, 30, 90, 0, 'FRIDGE', 'g', 'kg', 1000.0, 'g'),
  (1082, 'Milk', 'DAIRY', 54, 3.0, 3.2, 3.4, 0.0, 250, 0, 7, 0, 'FRIDGE', 'ml', 'L', 1000.0, 'ml'),
  (1083, 'Sesame-Seeds', 'OTHER', 573, 17.7, 49.7, 23.4, 11.8, 10, 180, 0, 0, 'PANTRY', 'g', 'kg', 1000.0, 'g')
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

-- 重置序列（如果需要）- 注意：StandardIngredient使用手动ID，无序列
-- SELECT setval('ref_standard_ingredients_id_seq', (SELECT MAX(id) FROM ref_standard_ingredients));

-- ============================================
-- 4. 插入标准调料库（StandardSpice）
-- Insert Standard Spices
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

-- 重置序列（如果需要）- 注意：StandardSpice使用手动ID，无序列
-- SELECT setval('ref_standard_spices_id_seq', (SELECT MAX(id) FROM ref_standard_spices));

-- ============================================
-- 5. 插入标准厨具库（StandardUtensil）
-- Insert Standard Utensils
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

-- 重置序列（如果需要）- 注意：StandardUtensil使用手动ID，无序列
-- SELECT setval('ref_standard_utensils_id_seq', (SELECT MAX(id) FROM ref_standard_utensils));

-- ============================================
-- 6. 关联食材与过敏原（示例）
-- Link Ingredients with Allergens (Examples)
-- ============================================
-- 鸡蛋包含鸡蛋过敏原
INSERT INTO ingredient_allergens (ingredient_id, allergen_id)
SELECT 1065, 3
WHERE NOT EXISTS (
  SELECT 1 FROM ingredient_allergens 
  WHERE ingredient_id = 1065 AND allergen_id = 3
);

-- 牛奶包含乳制品过敏原
INSERT INTO ingredient_allergens (ingredient_id, allergen_id)
SELECT 1082, 2
WHERE NOT EXISTS (
  SELECT 1 FROM ingredient_allergens 
  WHERE ingredient_id = 1082 AND allergen_id = 2
);

-- 海鲜类包含海鲜过敏原
INSERT INTO ingredient_allergens (ingredient_id, allergen_id)
SELECT id, 6
FROM ref_standard_ingredients
WHERE name IN ('Salmon', 'Tuna', 'Sea-Bass', 'Crab', 'Mussels', 'Squid')
AND NOT EXISTS (
  SELECT 1 FROM ingredient_allergens 
  WHERE ingredient_id = ref_standard_ingredients.id AND allergen_id = 6
);

-- ============================================
-- 7. 关联调料与过敏原（示例）
-- Link Spices with Allergens (Examples)
-- ============================================
-- 酱油包含大豆过敏原
INSERT INTO spice_allergens (spice_id, allergen_id)
SELECT 3003, 4
WHERE NOT EXISTS (
  SELECT 1 FROM spice_allergens 
  WHERE spice_id = 3003 AND allergen_id = 4
);

-- 豆酱包含大豆过敏原
INSERT INTO spice_allergens (spice_id, allergen_id)
SELECT 3009, 4
WHERE NOT EXISTS (
  SELECT 1 FROM spice_allergens 
  WHERE spice_id = 3009 AND allergen_id = 4
);

-- ============================================
-- 8. 用户数据字段说明（参考）
-- User Data Field Notes (Reference)
-- ============================================
-- 
-- 注意：users 表的 dietary_styles 字段现在使用 Map 格式（JSONB）
-- Note: The dietary_styles field in users table now uses Map format (JSONB)
--
-- 数据结构示例：
-- Data structure example:
-- {
--   "TABOO": ["low_sodium", "low_sugar", "halal", "vegetarian"],
--   "AVOID_INGREDIENT": ["cilantro", "carrot", "lamb"]
-- }
--
-- TABOO 选项（来自 PreferenceStandardLibrary.TABOO_OPTIONS）：
-- TABOO options (from PreferenceStandardLibrary.TABOO_OPTIONS):
--   - low_sodium      (低钠)
--   - low_sugar       (低糖)
--   - low_fat         (低脂)
--   - low_calorie     (低卡)
--   - halal           (清真)
--   - vegetarian      (素食)
--   - vegan           (纯素)
--   - gluten_free     (无麸质)
--   - lactose_free    (无乳糖)
--   - soy_free        (无大豆)
--   - nut_free        (无坚果)
--
-- AVOID_INGREDIENT: 用户不喜欢吃的食材列表（英文名称）
-- AVOID_INGREDIENT: List of ingredients user dislikes (English names)
--
-- 重要：所有值必须是英文，不能使用中文！
-- Important: All values must be in English, not Chinese!
-- ============================================
-- 9. 剩菜表字段说明（参考）
-- LeftoverDish Table Field Notes (Reference)
-- ============================================
-- 
-- 表名：household_leftovers
-- Table Name: household_leftovers
-- 
-- 注意：此表由 JPA 的 ddl-auto: update 自动创建，无需手动执行 CREATE TABLE
-- Note: This table is automatically created by JPA's ddl-auto: update, no manual CREATE TABLE needed
--
-- 字段列表（共 18 个字段）：
-- Field List (18 fields total):
--
-- 1. 主键字段 (Primary Key):
--    - id (bigint, NOT NULL, AUTO_INCREMENT) - 主键
--
-- 2. 关联字段 (Relationships):
--    - household_id (bigint, NOT NULL) - 关联的家庭 ID（外键，级联删除）
--    - original_dish_id (bigint, NOT NULL) - 原始 Dish ID（弱引用，避免循环依赖）
--
-- 3. 菜品信息快照 (Dish Info Snapshots):
--    - dish_name (varchar(200), nullable) - 菜品名称快照
--    - cover_image (varchar(500), nullable) - 封面图快照（可选）
--
-- 4. 营养素快照（每100g的值）(Nutrition Snapshots per 100g):
--    - calories_per_100g (integer, nullable) - 每100克的卡路里（kcal）
--    - protein_per_100g (double precision, nullable) - 每100克的蛋白质（克）
--    - fat_per_100g (double precision, nullable) - 每100克的脂肪（克）
--    - carb_per_100g (double precision, nullable) - 每100克的碳水化合物（克）
--    - fiber_per_100g (double precision, nullable) - 每100克的纤维（克，可选）
--
-- 5. 重量信息 (Weight Information):
--    - current_quantity_gram (integer, NOT NULL) - 当前剩余重量（克）
--    - initial_quantity_gram (integer, nullable) - 初始重量快照（克），用于计算百分比
--
-- 6. 时间信息 (Time Information):
--    - produced_time (timestamp, NOT NULL) - 制作时间（用于判断新鲜度）
--
-- 7. 审计字段（继承自 BaseEntity）(Audit Fields from BaseEntity):
--    - create_time (timestamp, nullable) - 创建时间（自动填充，不可更新）
--    - update_time (timestamp, nullable) - 更新时间（自动填充）
--    - create_by (bigint, nullable) - 创建者 ID（自动填充，不可更新）
--    - update_by (bigint, nullable) - 更新者 ID（自动填充）
--
-- 设计说明：
-- Design Notes:
--   1. 快照模式：菜品信息和营养素在创建时保存快照，避免查询时 JOIN
--      Snapshot Pattern: Dish info and nutrition are saved as snapshots at creation time to avoid JOINs
--   2. 弱引用：使用 original_dish_id 而非 JPA 关联，避免模块循环依赖
--      Weak Reference: Uses original_dish_id instead of JPA relationship to avoid circular dependencies
--   3. 每100g标准化：所有营养素基于每100g的值，便于计算任意重量的营养
--      Per 100g Standardization: All nutrition values are per 100g for easy calculation of any weight
--   4. 审计字段：继承自 BaseEntity，自动记录创建和更新时间
--      Audit Fields: Inherited from BaseEntity, automatically records create and update times
--
-- 相关实体类：
-- Related Entity Class:
--   backend-calotter/calotter-modules/calotter-inventory/src/main/java/com/calotter/inventory/domain/entity/LeftoverDish.java

-- ============================================
-- 完成提示
-- Completion Message
-- ============================================
DO $$
BEGIN
  RAISE NOTICE '========================================';
  RAISE NOTICE 'Standard Libraries Initialization Complete!';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'Standard Ingredients: %', (SELECT COUNT(*) FROM ref_standard_ingredients);
  RAISE NOTICE 'Standard Spices: %', (SELECT COUNT(*) FROM ref_standard_spices);
  RAISE NOTICE 'Standard Utensils: %', (SELECT COUNT(*) FROM ref_standard_utensils);
  RAISE NOTICE 'Standard Allergens: %', (SELECT COUNT(*) FROM ref_standard_allergens);
  RAISE NOTICE '========================================';
END $$;
