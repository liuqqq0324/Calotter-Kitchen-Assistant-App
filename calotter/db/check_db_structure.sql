-- ============================================================
-- 检查数据库结构脚本
-- 用于查看当前数据库的 ums_user 表结构
-- ============================================================

-- 1. 查看 ums_user 表的完整结构
SELECT 
    column_name AS "字段名",
    data_type AS "数据类型",
    CASE 
        WHEN character_maximum_length IS NOT NULL 
        THEN data_type || '(' || character_maximum_length || ')'
        ELSE data_type
    END AS "完整类型",
    is_nullable AS "允许NULL",
    column_default AS "默认值",
    ordinal_position AS "位置"
FROM information_schema.columns 
WHERE table_schema = 'sous_chef_ums' 
  AND table_name = 'ums_user'
ORDER BY ordinal_position;

-- 2. 检查是否有 age, height, weight, gender 字段
SELECT 
    CASE 
        WHEN COUNT(*) = 4 THEN '✅ 所有字段都存在'
        ELSE '❌ 缺少字段: ' || string_agg(missing_field, ', ')
    END AS "检查结果"
FROM (
    SELECT 'age' AS missing_field WHERE NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'sous_chef_ums' 
          AND table_name = 'ums_user' 
          AND column_name = 'age'
    )
    UNION ALL
    SELECT 'height' WHERE NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'sous_chef_ums' 
          AND table_name = 'ums_user' 
          AND column_name = 'height'
    )
    UNION ALL
    SELECT 'weight' WHERE NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'sous_chef_ums' 
          AND table_name = 'ums_user' 
          AND column_name = 'weight'
    )
    UNION ALL
    SELECT 'gender' WHERE NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'sous_chef_ums' 
          AND table_name = 'ums_user' 
          AND column_name = 'gender'
    )
) AS missing_fields;

-- 3. 查看所有表的列表
SELECT 
    table_schema AS "Schema",
    table_name AS "表名"
FROM information_schema.tables 
WHERE table_schema IN ('sous_chef_ums', 'sous_chef_rms', 'sous_chef_ims', 'sous_chef_cms', 'sous_chef_hp')
ORDER BY table_schema, table_name;
