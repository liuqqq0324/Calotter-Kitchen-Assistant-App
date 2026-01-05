# dietaryStyles 字段迁移说明

## 概述

将 `User.dietaryStyles` 字段从 `List<String>` 格式迁移到 `Map<String, List<String>>` 格式，以支持更细粒度的饮食画像分类。

## 迁移内容

### 1. 数据结构变更

**旧格式（List）：**
```json
["low_sodium", "low_sugar", "halal", "vegetarian"]
```

**新格式（Map）：**
```json
{
  "TABOO": ["low_sodium", "low_sugar", "halal", "vegetarian"],
  "AVOID_INGREDIENT": ["cilantro", "carrot", "lamb"]
}
```

### 2. 字段说明

- **TABOO**: 硬性饮食禁忌（如：低钠、低糖、清真、素食等）
- **AVOID_INGREDIENT**: 不喜欢吃的食材（如：香菜、胡萝卜、羊肉等）

### 3. 值的要求

**重要：所有值必须是英文，不能使用中文！**

- TABOO 的值应该使用标准库中的值（参考 `PreferenceStandardLibrary.TABOO_OPTIONS`）
- AVOID_INGREDIENT 的值应该是食材的英文名称（如：`cilantro`, `carrot`, `lamb`）

## 执行迁移

### 步骤 1：备份数据（可选但推荐）

```sql
CREATE TABLE users_backup_dietary_styles AS 
SELECT id, dietary_styles FROM users WHERE dietary_styles IS NOT NULL;
```

### 步骤 2：执行迁移脚本

```bash
psql -U your_username -d calotter -f migrate-dietary-styles-to-map.sql
```

或者直接在 PostgreSQL 客户端中执行 `migrate-dietary-styles-to-map.sql` 文件。

### 步骤 3：验证迁移结果

```sql
-- 检查是否还有数组格式的数据
SELECT id, dietary_styles, jsonb_typeof(dietary_styles) as type
FROM users 
WHERE jsonb_typeof(dietary_styles) = 'array';

-- 检查 Map 格式的数据结构
SELECT id, 
       dietary_styles->'TABOO' as taboos,
       dietary_styles->'AVOID_INGREDIENT' as avoid_ingredients
FROM users 
WHERE dietary_styles IS NOT NULL;
```

## 代码变更

### 后端变更

1. **User.java**: `dietaryStyles` 字段类型从 `List<String>` 改为 `Map<String, List<String>>`
2. **PreferenceStandardLibrary.java**: 添加了 `PREF_KEY_TABOO` 和 `PREF_KEY_AVOID_INGREDIENT` 常量
3. **DietaryStylesValidator.java**: 新增验证工具类，确保值都是英文
4. **UserService.java**: `getUserTaboos()` 和 `updateUserTaboos()` 方法改为操作 `dietaryStyles.TABOO`
5. **AiMenuService.java**: 从 `dietaryStyles` Map 中提取 taboos 和 avoidIngredients
6. **CookingContextBuilderService.java**: 从 `dietaryStyles` Map 中提取数据

### 前端变更

**无需修改！** 前端继续使用 `/api/user/taboos` API，后端会自动处理数据格式转换。

## 注意事项

1. **数据验证**：后端会自动验证和清理 `dietaryStyles` 的值，移除包含中文字符的值
2. **向后兼容**：现有的 `/api/user/taboos` API 仍然可用，会自动从新的 `dietaryStyles` Map 中读取和写入
3. **自动清理**：通过 JPA 生命周期钩子（`@PrePersist` 和 `@PreUpdate`），每次保存用户时都会自动验证和清理 `dietaryStyles`

## 后续工作

如果需要在前端添加管理 `AVOID_INGREDIENT` 的功能，可以：

1. 创建新的 API 端点 `/api/user/dietary-styles` 来统一管理 `dietaryStyles` Map
2. 或者创建单独的 API `/api/user/avoid-ingredients` 来管理 `AVOID_INGREDIENT` 列表

## 相关文件

- 迁移脚本：`migrate-dietary-styles-to-map.sql`
- 实体类：`calotter-user/src/main/java/com/calotter/user/domain/entity/User.java`
- 验证工具：`calotter-user/src/main/java/com/calotter/user/service/DietaryStylesValidator.java`
- 标准库：`calotter-common/src/main/java/com/calotter/common/core/domain/PreferenceStandardLibrary.java`

