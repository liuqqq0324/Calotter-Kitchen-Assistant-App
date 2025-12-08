-- 种子数据：标准食材
-- 注意：如果表已存在数据，这些 INSERT 可能会失败，这是正常的
INSERT INTO standard_ingredients (id, name, category, base_unit, image_url) VALUES
(1, 'Beef Steak', 'Meat', 'g', ''),
(2, 'Chicken Breast', 'Meat', 'g', ''),
(3, 'Pork Belly', 'Meat', 'g', ''),
(4, 'Egg', 'Dairy', 'piece', ''),
(5, 'Tomato', 'Vegetable', 'g', ''),
(6, 'Potato', 'Vegetable', 'g', ''),
(7, 'Onion', 'Vegetable', 'g', ''),
(8, 'Rice', 'Grains', 'g', ''),
(9, 'Peanut', 'Nuts', 'g', ''),
(10, 'Carrot', 'Vegetable', 'g', ''),
(11, 'Milk', 'Dairy', 'ml', ''),
(12, 'Cheese', 'Dairy', 'g', '')
ON CONFLICT DO NOTHING;

-- 种子数据：标准炊具
INSERT INTO standard_cookwares (id, name, ai_code) VALUES
(1, 'Stove Top', 'stove'),
(2, 'Oven', 'oven'),
(3, 'Microwave', 'microwave'),
(4, 'Air Fryer', 'air_fryer'),
(5, 'Rice Cooker', 'rice_cooker'),
(6, 'Pressure Cooker', 'pressure_cooker'),
(7, 'Blender', 'blender')
ON CONFLICT DO NOTHING;

-- 种子数据：标准调料
INSERT INTO standard_seasonings (id, name, ai_code) VALUES
(1, 'Salt', 'salt'),
(2, 'Sugar', 'sugar'),
(3, 'Soy Sauce', 'soy_sauce'),
(4, 'Black Pepper', 'black_pepper'),
(5, 'Olive Oil', 'oil'),
(6, 'Vinegar', 'vinegar'),
(7, 'Chili Powder', 'chili_powder'),
(8, 'Garlic Powder', 'garlic_powder')
ON CONFLICT DO NOTHING;

