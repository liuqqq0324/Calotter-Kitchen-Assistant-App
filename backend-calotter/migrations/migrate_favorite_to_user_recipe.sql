-- ============================================================
-- 数据库迁移脚本：收藏功能物理隔离重构
-- Migration: Favorite Recipe Physical Isolation Refactoring
-- ============================================================
-- 
-- 变更说明：
-- 1. 创建新表 user_recipes（用户收藏的菜谱蓝图）
-- 2. 修改 household_favorite_dishes 表：dish_id -> recipe_id
-- 3. 修改 dishes 表：删除 dish_type, template_dish_id, favorite 字段，添加 source_recipe_id 字段
-- 
-- 执行前提：
-- - 在生产环境执行前，请先备份数据库
-- - 建议在维护窗口期间执行
-- - 执行前请检查是否有现有的收藏数据需要迁移
-- 
-- 执行顺序：
-- 1. 备份数据库
-- 2. 检查现有数据（参考下方 CHECK 部分）
-- 3. 执行此迁移脚本
-- 4. 验证迁移结果
-- 5. 部署新代码
-- 
-- ============================================================

-- ============================================================
-- 第一部分：检查当前状态（执行前运行，用于确认）
-- ============================================================

-- 检查 dishes 表的现有字段
-- SELECT column_name, data_type 
-- FROM information_schema.columns 
-- WHERE table_name = 'dishes' 
-- ORDER BY ordinal_position;

-- 检查 household_favorite_dishes 表的现有字段
-- SELECT column_name, data_type 
-- FROM information_schema.columns 
-- WHERE table_name = 'household_favorite_dishes' 
-- ORDER BY ordinal_position;

-- 检查是否有现有收藏数据（如果有，需要特殊处理）
-- SELECT COUNT(*) FROM household_favorite_dishes;

-- ============================================================
-- 第二部分：创建 user_recipes 表
-- ============================================================
-- 注意：Hibernate 的 ddl-auto: update 会自动创建此表
-- 但如果需要确保表结构完全匹配，可以手动创建

CREATE TABLE IF NOT EXISTS user_recipes (
    id BIGSERIAL PRIMARY KEY,
    household_id BIGINT NOT NULL,
    
    -- 基础信息
    name VARCHAR(255) NOT NULL,
    cover_image TEXT,
    description VARCHAR(1000),
    
    -- 核心物理属性
    total_weight_gram INTEGER NOT NULL,
    
    -- 总营养素
    total_calories INTEGER,
    total_protein DOUBLE PRECISION,
    total_fat DOUBLE PRECISION,
    total_carb DOUBLE PRECISION,
    total_fiber DOUBLE PRECISION,
    
    -- 烹饪元数据
    cooking_time_minutes INTEGER,
    difficulty VARCHAR(20),
    
    -- JSONB 字段
    steps JSONB,
    tags JSONB,
    ingredient_snapshots JSONB,
    
    -- BaseEntity 审计字段
    create_time TIMESTAMP,
    update_time TIMESTAMP,
    create_by BIGINT,
    update_by BIGINT
    
    -- 注意：UserRecipe 使用弱引用，无外键约束
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_user_recipe_household ON user_recipes(household_id);
CREATE INDEX IF NOT EXISTS idx_user_recipe_name ON user_recipes(household_id, name);

-- ============================================================
-- 第三部分：修改 household_favorite_dishes 表
-- ============================================================

-- 步骤 3.1：添加新列 recipe_id
ALTER TABLE household_favorite_dishes 
ADD COLUMN IF NOT EXISTS recipe_id BIGINT;

-- 步骤 3.2：删除旧约束（如果存在）
-- 注意：PostgreSQL 需要先删除依赖该列的约束，再删除列
DO $$ 
BEGIN
    -- 删除旧的唯一约束（如果存在）
    IF EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'uk_household_dish'
    ) THEN
        ALTER TABLE household_favorite_dishes DROP CONSTRAINT uk_household_dish;
    END IF;
    
    -- 删除旧的索引（如果存在）
    IF EXISTS (
        SELECT 1 FROM pg_indexes 
        WHERE indexname = 'idx_fav_dish'
    ) THEN
        DROP INDEX IF EXISTS idx_fav_dish;
    END IF;
END $$;

-- 步骤 3.3：删除旧列 dish_id（如果存在）
-- ⚠️ 警告：这会删除旧数据！如果有旧数据需要迁移，请先执行数据迁移步骤
ALTER TABLE household_favorite_dishes 
DROP COLUMN IF EXISTS dish_id;

-- 步骤 3.4：设置新列 recipe_id 为 NOT NULL（在确保数据已迁移后）
-- 注意：如果存在 NULL 值，此步骤会失败，需要先处理数据
-- ALTER TABLE household_favorite_dishes 
-- ALTER COLUMN recipe_id SET NOT NULL;

-- 步骤 3.5：创建新的唯一约束
ALTER TABLE household_favorite_dishes
ADD CONSTRAINT uk_household_recipe UNIQUE (household_id, recipe_id);

-- 步骤 3.6：创建新索引
CREATE INDEX IF NOT EXISTS idx_fav_household ON household_favorite_dishes(household_id);
CREATE INDEX IF NOT EXISTS idx_fav_recipe ON household_favorite_dishes(recipe_id);

-- ============================================================
-- 第四部分：修改 dishes 表
-- ============================================================

-- 步骤 4.1：添加新列 source_recipe_id
ALTER TABLE dishes 
ADD COLUMN IF NOT EXISTS source_recipe_id BIGINT;

-- 步骤 4.2：删除旧字段
-- ⚠️ 警告：这会永久删除数据！请确保这些字段不再使用
ALTER TABLE dishes 
DROP COLUMN IF EXISTS dish_type,
DROP COLUMN IF EXISTS template_dish_id,
DROP COLUMN IF EXISTS favorite;

-- ============================================================
-- 第五部分：验证迁移结果
-- ============================================================

-- 验证 user_recipes 表是否存在
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'user_recipes'
    ) THEN
        RAISE EXCEPTION 'user_recipes 表未创建成功';
    END IF;
END $$;

-- 验证 household_favorite_dishes 表结构
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'household_favorite_dishes' 
        AND column_name = 'dish_id'
    ) THEN
        RAISE WARNING 'household_favorite_dishes 表仍存在 dish_id 列';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'household_favorite_dishes' 
        AND column_name = 'recipe_id'
    ) THEN
        RAISE EXCEPTION 'household_favorite_dishes 表未成功添加 recipe_id 列';
    END IF;
END $$;

-- 验证 dishes 表结构
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'dishes' 
        AND column_name IN ('dish_type', 'template_dish_id', 'favorite')
    ) THEN
        RAISE WARNING 'dishes 表仍存在旧字段（dish_type, template_dish_id, favorite）';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'dishes' 
        AND column_name = 'source_recipe_id'
    ) THEN
        RAISE EXCEPTION 'dishes 表未成功添加 source_recipe_id 列';
    END IF;
END $$;

-- ============================================================
-- 迁移完成提示
-- ============================================================

DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE '数据库迁移完成！';
    RAISE NOTICE 'Migration completed successfully!';
    RAISE NOTICE '========================================';
    RAISE NOTICE '下一步：';
    RAISE NOTICE '1. 验证迁移结果（运行上述验证查询）';
    RAISE NOTICE '2. 部署新代码到生产环境';
    RAISE NOTICE '3. 测试收藏功能是否正常工作';
    RAISE NOTICE '========================================';
END $$;

