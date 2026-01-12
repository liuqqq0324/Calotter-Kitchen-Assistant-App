# 数据库迁移指南：收藏功能物理隔离重构

## 📋 迁移概述

本次迁移实现了收藏功能的物理隔离重构：
- **新表**：`user_recipes`（用户收藏的菜谱蓝图）
- **表修改**：`household_favorite_dishes`（`dish_id` → `recipe_id`）
- **表修改**：`dishes`（删除旧字段，添加 `source_recipe_id`）

## ⚠️ 重要警告

1. **在生产环境执行前，必须先备份数据库！**
2. **建议在维护窗口期间执行**
3. **如果有现有收藏数据，需要特殊处理**（见下方"数据迁移"部分）

## 📝 执行步骤

### 步骤 1：备份数据库

```bash
# 使用 pg_dump 备份（根据你的 AWS RDS 配置调整）
pg_dump -h <rds-endpoint> -U <username> -d <database-name> > backup_before_migration_$(date +%Y%m%d_%H%M%S).sql
```

### 步骤 2：检查现有数据

```sql
-- 检查是否有现有收藏数据
SELECT COUNT(*) FROM household_favorite_dishes;

-- 查看现有收藏数据（如果有）
SELECT * FROM household_favorite_dishes LIMIT 10;

-- 检查 dishes 表的字段
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'dishes' 
ORDER BY ordinal_position;
```

### 步骤 3：执行迁移脚本

```bash
# 连接数据库并执行迁移脚本
psql -h <rds-endpoint> -U <username> -d <database-name> -f migrations/migrate_favorite_to_user_recipe.sql
```

或在 psql 中直接执行：

```sql
\i migrations/migrate_favorite_to_user_recipe.sql
```

### 步骤 4：验证迁移结果

```sql
-- 验证表是否存在
SELECT table_name FROM information_schema.tables 
WHERE table_name IN ('user_recipes', 'household_favorite_dishes', 'dishes');

-- 验证 household_favorite_dishes 表结构
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'household_favorite_dishes' 
ORDER BY ordinal_position;

-- 验证 dishes 表结构
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'dishes' 
AND column_name IN ('source_recipe_id', 'dish_type', 'template_dish_id', 'favorite')
ORDER BY ordinal_position;
```

### 步骤 5：部署新代码

迁移脚本执行成功后，可以安全地 push 代码并触发自动部署。

## 🔄 数据迁移（如果有旧收藏数据）

**注意**：根据"物理隔离"的设计原则，旧的收藏数据（`dish_id`）与新系统（`recipe_id`）不兼容。

### 情况 1：生产环境还没有用户使用收藏功能

如果 `household_favorite_dishes` 表为空或只有测试数据，可以直接执行迁移脚本，无需数据迁移。

### 情况 2：生产环境已有用户收藏数据

如果有真实的用户收藏数据，需要：

1. **导出旧数据**（备份）
2. **清空 `household_favorite_dishes` 表**（因为旧数据无法直接迁移）
3. **通知用户重新收藏**（用户体验影响）

或者，可以编写一个数据迁移脚本，将旧的 `Dish` 记录转换为 `UserRecipe` 记录：

```sql
-- 示例：数据迁移脚本（需要根据实际情况调整）
-- 此脚本将旧的收藏 Dish 记录转换为 UserRecipe 记录

-- 1. 为每个收藏的 Dish 创建对应的 UserRecipe
INSERT INTO user_recipes (
    household_id, name, cover_image, description,
    total_weight_gram, total_calories, total_protein, 
    total_fat, total_carb, total_fiber,
    cooking_time_minutes, difficulty,
    steps, tags, ingredient_snapshots,
    create_time, update_time
)
SELECT 
    d.household_id, d.name, d.cover_image, d.description,
    d.total_weight_gram, d.total_calories, d.total_protein,
    d.total_fat, d.total_carb, d.total_fiber,
    d.cooking_time_minutes, d.difficulty::text,
    d.steps, d.tags, d.ingredient_snapshots,
    d.create_time, d.update_time
FROM dishes d
INNER JOIN household_favorite_dishes hfd ON d.id = hfd.dish_id;

-- 2. 更新 household_favorite_dishes 表的 recipe_id
UPDATE household_favorite_dishes hfd
SET recipe_id = ur.id
FROM user_recipes ur
INNER JOIN dishes d ON d.household_id = ur.household_id AND d.name = ur.name
WHERE hfd.dish_id = d.id;
```

**重要**：如果选择数据迁移，请在测试环境充分测试后再在生产环境执行！

## 🔙 回滚方案

如果迁移失败，需要回滚：

```sql
-- ⚠️ 注意：回滚会丢失迁移后创建的新数据！

-- 1. 恢复 household_favorite_dishes 表
ALTER TABLE household_favorite_dishes 
ADD COLUMN dish_id BIGINT;

ALTER TABLE household_favorite_dishes 
DROP COLUMN IF EXISTS recipe_id;

-- 2. 恢复 dishes 表（字段类型需要根据实际情况调整）
ALTER TABLE dishes 
ADD COLUMN dish_type VARCHAR(20),
ADD COLUMN template_dish_id BIGINT,
ADD COLUMN favorite BOOLEAN;

ALTER TABLE dishes 
DROP COLUMN IF EXISTS source_recipe_id;

-- 3. 删除 user_recipes 表（如果有数据需要先备份）
DROP TABLE IF EXISTS user_recipes CASCADE;
```

## ✅ 迁移检查清单

- [ ] 数据库备份已完成
- [ ] 已检查现有数据（确认是否有旧收藏数据）
- [ ] 迁移脚本已执行
- [ ] 验证查询已通过
- [ ] 代码已部署
- [ ] 功能测试已通过（收藏/取消收藏/列表查询）

## 📞 问题排查

如果迁移过程中遇到问题：

1. **检查错误日志**：查看 PostgreSQL 日志
2. **检查约束冲突**：确认是否有外键约束阻止删除列
3. **检查数据依赖**：确认是否有其他表引用被删除的列
4. **联系团队**：如果无法解决，及时联系团队

## 📚 相关文档

- 迁移脚本：`migrate_favorite_to_user_recipe.sql`
- 实体定义：
  - `UserRecipe.java`
  - `HouseholdFavoriteDish.java`
  - `Dish.java`

