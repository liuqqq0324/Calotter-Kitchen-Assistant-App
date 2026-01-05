-- 将 dietary_styles 字段从 List<String> 格式迁移到 Map<String, List<String>> 格式
-- 执行时间：2026-01-06
-- 说明：将现有的数组格式转换为 Map 格式，包含 TABOO 和 AVOID_INGREDIENT 两个键
-- 
-- 迁移逻辑：
-- 1. 如果 dietary_styles 是数组格式，将其转换为 {"TABOO": [...原数组...], "AVOID_INGREDIENT": []}
-- 2. 如果 dietary_styles 已经是 Map 格式，保持不变
-- 3. 如果 dietary_styles 为 NULL，设置为 {"TABOO": [], "AVOID_INGREDIENT": []}

-- 步骤1：备份现有数据（可选，建议在生产环境执行）
-- CREATE TABLE users_backup_dietary_styles AS 
-- SELECT id, dietary_styles FROM users WHERE dietary_styles IS NOT NULL;

-- 步骤2：将数组格式转换为 Map 格式
-- 处理逻辑：
-- - 如果 jsonb_typeof(dietary_styles) = 'array'，转换为 Map
-- - 如果已经是 object，保持不变
-- - 如果是 null，设置为默认 Map

UPDATE users
SET dietary_styles = CASE
    -- 如果当前是数组格式，转换为 Map（将原数组作为 TABOO）
    WHEN jsonb_typeof(dietary_styles) = 'array' THEN
        jsonb_build_object(
            'TABOO', COALESCE(dietary_styles, '[]'::jsonb),
            'AVOID_INGREDIENT', '[]'::jsonb
        )
    -- 如果已经是对象格式，检查是否包含必要的键，如果没有则添加
    WHEN jsonb_typeof(dietary_styles) = 'object' THEN
        -- 如果缺少 TABOO 键，添加空数组
        CASE 
            WHEN dietary_styles ? 'TABOO' THEN
                -- 如果缺少 AVOID_INGREDIENT 键，添加空数组
                CASE 
                    WHEN dietary_styles ? 'AVOID_INGREDIENT' THEN dietary_styles
                    ELSE dietary_styles || jsonb_build_object('AVOID_INGREDIENT', '[]'::jsonb)
                END
            ELSE
                -- 如果缺少 TABOO，添加它
                CASE 
                    WHEN dietary_styles ? 'AVOID_INGREDIENT' THEN
                        jsonb_build_object('TABOO', '[]'::jsonb) || dietary_styles
                    ELSE
                        jsonb_build_object(
                            'TABOO', '[]'::jsonb,
                            'AVOID_INGREDIENT', '[]'::jsonb
                        ) || dietary_styles
                END
        END
    -- 如果是 null，设置为默认 Map
    ELSE
        jsonb_build_object(
            'TABOO', '[]'::jsonb,
            'AVOID_INGREDIENT', '[]'::jsonb
        )
END
WHERE dietary_styles IS NULL 
   OR jsonb_typeof(dietary_styles) = 'array'
   OR (jsonb_typeof(dietary_styles) = 'object' 
       AND (NOT (dietary_styles ? 'TABOO') OR NOT (dietary_styles ? 'AVOID_INGREDIENT')));

-- 步骤3：验证迁移结果（可选）
-- 检查是否还有数组格式的数据
-- SELECT id, dietary_styles, jsonb_typeof(dietary_styles) as type
-- FROM users 
-- WHERE jsonb_typeof(dietary_styles) = 'array';

-- 检查 Map 格式的数据结构
-- SELECT id, 
--        dietary_styles->'TABOO' as taboos,
--        dietary_styles->'AVOID_INGREDIENT' as avoid_ingredients
-- FROM users 
-- WHERE dietary_styles IS NOT NULL;

