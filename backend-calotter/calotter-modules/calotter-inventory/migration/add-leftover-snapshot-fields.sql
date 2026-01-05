-- 为 household_leftovers 表添加菜品信息快照字段
-- 执行时间：2026-01-05
-- 说明：添加 dish_name, cover_image, calories_per_100g 字段，用于存储菜品信息快照，避免查询时 JOIN 和循环依赖

-- 添加菜品名称快照字段
ALTER TABLE household_leftovers 
ADD COLUMN IF NOT EXISTS dish_name VARCHAR(200);

-- 添加封面图快照字段
ALTER TABLE household_leftovers 
ADD COLUMN IF NOT EXISTS cover_image VARCHAR(500);

-- 添加每100克卡路里快照字段
ALTER TABLE household_leftovers 
ADD COLUMN IF NOT EXISTS calories_per_100g INTEGER;

-- 为现有数据填充默认值（可选，如果需要）
-- UPDATE household_leftovers 
-- SET dish_name = '未知菜品', calories_per_100g = 0 
-- WHERE dish_name IS NULL;

