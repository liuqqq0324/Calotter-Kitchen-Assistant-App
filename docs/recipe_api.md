# Recipe API (lightweight version)

Base URL (dev): `http://<host>:9000`

- 模拟器访问宿主机：`http://10.0.2.2:9000`
- 所有接口均使用 JSON，`Content-Type: application/json`
- 数量单位统一：`g | ml | piece`

## 1) 生成菜单

`POST /api/recipes/generate`

用于一次性生成 5 组选项，每组选项内包含 `generation_settings.dish_count` 道菜。

Request body
```json
{
  "inventory": [
    { "name": "chicken thigh", "amount_value": 200, "amount_unit": "g", "expires_at": "2025-11-30" }
  ],
  "calorie_target": { "min_total_kcal": 1500, "max_total_kcal": 1800 },
  "servings": 1,
  "diet_preferences": {
    "cuisine_preferences": ["chinese"],
    "taste_preferences": ["light"],
    "avoid_ingredients": [],
    "allergies": []
  },
  "generation_settings": {
    "dish_count": 1,
    "max_cooking_time_min": 40,
    "difficulty_target": "easy"
  },
  "cookers": ["stove"],
  "seasonings": ["salt", "soy_sauce"]
}
```

Response body
```json
{
  "menus": [
    {
      "menu_id": 1,
      "recipes": [
        {
          "title": "Garlic Butter Chicken with Steamed Broccoli",
          "short_description": "Pan-seared chicken thigh with garlic butter sauce and light steamed broccoli.",
          "servings": 1,
          "cooking_time_min": 30,
          "difficulty": "easy",
          "total_calories_estimate": 650,
          "ingredients": [
            { "name": "chicken thigh", "amount_value": 200, "amount_unit": "g", "is_optional": false, "category": "main" },
            { "name": "olive oil", "amount_value": 10, "amount_unit": "ml", "is_optional": false, "category": "seasoning" }
          ],
          "steps": [
            { "step_number": 1, "instruction": "Season the chicken thigh with salt and black pepper.", "step_time_min": 5 },
            { "step_number": 2, "instruction": "Pan-fry the chicken with olive oil over medium heat until cooked through.", "step_time_min": 15 }
          ]
        }
      ]
    }
  ]
}
```

说明
- 始终返回 `menus` 长度为 5 的数组。
- `recipes` 长度应等于 `generation_settings.dish_count`。
- 后端内部调用 AI，失败时会回退到固定示例菜单。

## 2) 获取默认偏好（可选）

`GET /api/recipes/preferences/default`

用于前端初始化筛选表单的默认值（非持久化）。

Response body
```json
{
  "servings": 1,
  "generation_settings": {
    "dish_count": 1,
    "max_cooking_time_min": 40,
    "difficulty_target": "easy"
  },
  "diet_preferences": {
    "cuisine_preferences": ["chinese", "japanese"],
    "taste_preferences": ["light"],
    "avoid_ingredients": [],
    "allergies": []
  },
  "calorie_target": { "min_total_kcal": 1500, "max_total_kcal": 1800 }
}
```

## 错误约定（建议）
- 统一返回 HTTP 状态码 + JSON：
```json
{ "code": 400, "message": "bad request" }
```
- AI 调用失败将回退示例菜单并返回 200；若要区分，可在 header 或日志中标记。

## 3) 收藏列表

`GET /api/users/me/favorite-recipes`

Response
```json
{
  "recipes": [
    {
      "recipeId": "rec_123456",
      "title": "Tomato Egg Stir-fry",
      "short_description": "Light Chinese-style stir fry with tomato and egg.",
      "servings": 1,
      "cooking_time_min": 15,
      "difficulty": "easy",
      "total_calories_estimate": 320
    }
  ]
}
```

## 4) 收藏详情

`GET /api/users/me/favorite-recipes/{recipeId}`

Response
```json
{
  "recipeId": "rec_123456",
  "title": "Tomato Egg Stir-fry",
  "short_description": "Light Chinese-style stir fry with tomato and egg.",
  "servings": 1,
  "cooking_time_min": 15,
  "difficulty": "easy",
  "total_calories_estimate": 320,
  "ingredients": [
    { "name": "egg", "amount_value": 2, "amount_unit": "piece", "is_optional": false },
    { "name": "tomato", "amount_value": 150, "amount_unit": "g", "is_optional": false },
    { "name": "salt", "amount_value": 2, "amount_unit": "g", "is_optional": false }
  ],
  "steps": [
    { "step_number": 1, "instruction": "Beat the eggs with a pinch of salt.", "step_time_min": 3 },
    { "step_number": 2, "instruction": "Stir-fry tomatoes until soft, then add eggs.", "step_time_min": 7 },
    { "step_number": 3, "instruction": "Season to taste and serve hot.", "step_time_min": 5 }
  ]
}
```

## 5) 添加收藏

`POST /api/users/me/favorite-recipes`

Request
```json
{
  "source": "generated_menu",
  "recipe": {
    "title": "Tomato Egg Stir-fry",
    "short_description": "Light Chinese-style stir fry with tomato and egg.",
    "servings": 1,
    "cooking_time_min": 15,
    "difficulty": "easy",
    "total_calories_estimate": 320,
    "ingredients": [
      { "name": "egg", "amount_value": 2, "amount_unit": "piece", "is_optional": false },
      { "name": "tomato", "amount_value": 150, "amount_unit": "g", "is_optional": false },
      { "name": "salt", "amount_value": 2, "amount_unit": "g", "is_optional": false }
    ],
    "steps": [
      { "step_number": 1, "instruction": "Beat the eggs with a pinch of salt.", "step_time_min": 3 },
      { "step_number": 2, "instruction": "Stir-fry tomatoes until soft, then add eggs.", "step_time_min": 7 },
      { "step_number": 3, "instruction": "Season to taste and serve hot.", "step_time_min": 5 }
    ]
  }
}
```
Response
```json
{ "recipeId": "rec_123456", "message": "Recipe added to favorites" }
```

## 6) 取消收藏

`DELETE /api/users/me/favorite-recipes/{recipeId}`

Response
```json
{ "message": "Recipe removed from favorites" }
```
