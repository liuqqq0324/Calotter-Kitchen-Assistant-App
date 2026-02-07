---
date: 2025-11-26
lastUpdated: 2026-02-08
version: 2
tags:
  - api
  - documentation
  - INFOSYS-778
  - GroupProject
---

### 图例与统一响应

- **`F`** = Frontend，**`B`** = Backend，**`A`** = AI-Engine（如 `F -> B` 表示前端请求后端 API）。
- **统一响应包装**：后端所有接口返回 `Result<T>` 格式：`{ "code": 200, "message": "操作成功", "data": <T> }`。错误时 `code` 为非 2xx，`message` 为错误说明。下文中的响应示例为 `data` 字段内容或与 `Result` 一致的结构。

# A. Prompt JSON

## 1. Backend -> AI Engine
```JSON
{
  "inventory": [
    {
      "name": "chicken thigh",
      "amount_value": 500,
      "amount_unit": "g",
      "expires_at": "2025-11-29"
    },
    {
      "name": "broccoli",
      "amount_value": 300,
      "amount_unit": "g",
      "expires_at": "2025-11-30"
    },
    {
      "name": "rice",
      "amount_value": 400,
      "amount_unit": "g",
      "expires_at": null
    }
  ],
  "calorie_target": {
    "min_total_kcal": 1500,
    "max_total_kcal": 1800
  },
  "servings": 1,
  "diet_preferences": {
    "cuisine_preferences": ["chinese", "japanese"],
    "taste_preferences": ["light", "umami"],
    "avoid_ingredients": ["coriander"],
    "diet_habits": ["vegetarian"],
    "allergies": []
  },
  "generation_settings": {
    "dish_count": 1,
    "max_cooking_time_min": 40,
    "difficulty_target": "easy"
  },
  "cookers": [
    "stove",
    "rice_cooker"
  ],
  "seasonings": [
    "salt",
    "sugar",
    "black_pepper",
    "soy_sauce",
    "olive_oil"
  ]
}

```

# B. Generated recipe JSON

## 1. AI-Engine -> Backend
```JSON
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
            {
              "name": "chicken thigh",
              "amount_value": 200,
              "amount_unit": "g",
              "is_optional": false,
              "category": "main"
            },
            {
              "name": "broccoli",
              "amount_value": 150,
              "amount_unit": "g",
              "is_optional": false,
              "category": "main"
            },
            {
              "name": "rice",
              "amount_value": 80,
              "amount_unit": "g",
              "is_optional": false,
              "category": "main"
            },
            {
              "name": "olive oil",
              "amount_value": 10,
              "amount_unit": "ml",
              "is_optional": false,
              "category": "seasoning"
            },
            {
              "name": "salt",
              "amount_value": 3,
              "amount_unit": "g",
              "is_optional": false,
              "category": "seasoning"
            },
            {
              "name": "black pepper",
              "amount_value": 1,
              "amount_unit": "g",
              "is_optional": true,
              "category": "seasoning"
            },
            {
              "name": "soy_sauce",
              "amount_value": 5,
              "amount_unit": "ml",
              "is_optional": true,
              "category": "seasoning"
            }
          ],
          "steps": [
            {
              "step_number": 1,
              "instruction": "Season the chicken thigh with salt and black pepper.",
              "step_time_min": 5
            },
            {
              "step_number": 2,
              "instruction": "Pan-fry the chicken with olive oil over medium heat until cooked through.",
              "step_time_min": 15
            },
            {
              "step_number": 3,
              "instruction": "Steam the broccoli until just tender.",
              "step_time_min": 7
            },
            {
              "step_number": 4,
              "instruction": "Plate the rice, sliced chicken and broccoli, drizzle with a little soy sauce if desired.",
              "step_time_min": 3
            }
          ]
        }
      ]
    },
    {
      "menu_id": 2,
      "recipes": [
        {
          "title": "Light Chicken and Broccoli Rice Bowl",
          "short_description": "One-bowl light rice dish with simmered chicken and broccoli.",
          "servings": 1,
          "cooking_time_min": 25,
          "difficulty": "easy",
          "total_calories_estimate": 580,
          "ingredients": [
            {
              "name": "chicken thigh",
              "amount_value": 180,
              "amount_unit": "g",
              "is_optional": false,
              "category": "main"
            },
            {
              "name": "broccoli",
              "amount_value": 120,
              "amount_unit": "g",
              "is_optional": false,
              "category": "main"
            },
            {
              "name": "rice",
              "amount_value": 90,
              "amount_unit": "g",
              "is_optional": false,
              "category": "main"
            },
            {
              "name": "soy_sauce",
              "amount_value": 8,
              "amount_unit": "ml",
              "is_optional": false,
              "category": "seasoning"
            },
            {
              "name": "salt",
              "amount_value": 2,
              "amount_unit": "g",
              "is_optional": false,
              "category": "seasoning"
            },
            {
              "name": "olive_oil",
              "amount_value": 5,
              "amount_unit": "ml",
              "is_optional": true,
              "category": "seasoning"
            }
          ],
          "steps": [
            {
              "step_number": 1,
              "instruction": "Cook the rice in the rice cooker according to package instructions.",
              "step_time_min": 15
            },
            {
              "step_number": 2,
              "instruction": "Stir-fry chicken pieces with a little oil until they change color.",
              "step_time_min": 5
            },
            {
              "step_number": 3,
              "instruction": "Add broccoli, soy sauce, salt and a splash of water, simmer until broccoli is tender and chicken is cooked through.",
              "step_time_min": 5
            }
          ]
        }
      ]
    }
  ]
}

```


# C. UMS (User Management Service)

后端同时支持路径前缀 `/api/user` 与 `/api/ums/user`，以下以 `/api/user` 为例。

## 1. Registration Request (F -> B)

- Request method and path: `POST /api/user/register`（或 `POST /api/ums/user/register`）
- Request header: Content-Type: application/json
- Request body:

- Request method and path: `POST /api/ums/auth/register`
- Request header: Content-Type: application/json
- Request body:

```JSON
{
	"username": "UserName",
	"password": "UserPassword123",
	"email": "user.email@example.com"
}
```

> **Note**: 后端仅校验 `username`、`password`、`email`。若前端需要二次确认密码，可在前端校验 `confirmPassword` 与 `password` 一致后再提交，不传给后端。


## 2. Registration Response (B -> F)

`Result.data` 为认证信息（与登录响应一致）：

```JSON
{
	"userId": 1,
	"token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
	"username": "UserName",
	"email": "user.email@example.com",
	"role": "USER",
	"householdId": null
}
```

## 3. Login Request (F -> B)

- Request method and path: `POST /api/user/login`（或 `POST /api/ums/user/login`）
- Request header: Content-Type: application/json
- Request body:

```JSON
{
	"usernameOrEmail": "UsernameOrEmail",
	"password": "UserPassword123"
}
```

## 4. Login Response (B -> F)

`Result.data` 为认证信息：

```JSON
{
	"userId": 1,
	"token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
	"username": "UserName",
	"email": "user.email@example.com",
	"role": "USER",
	"householdId": 1
}
```

## 5. Logout Request (F -> B)

- Request method and path: `POST /api/user/logout`（或 `POST /api/ums/user/logout`）
- Request header: `Authorization: Bearer <accessToken>`
- Request header: `Content-Type: application/json`

> **Note**: The Authorization header should contain the current access token.

## 6. Logout Response (B -> F)

`Result.data` 为字符串，如 `"Logged out successfully"`。

> **Note**: After logout, the frontend should clear the stored token and user ID from local storage.

## 7. User Brief Info Request (F -> B)

- Request method and path: `GET /api/user?id=<userId>`（或 `GET /api/ums/user?id=<userId>`）
- Request header: `Authorization: Bearer <accessToken>`
- Request header: `Content-Type: application/json`

## 8. User Brief Info Response (B -> F)

`Result.data` 结构：

```json
{
	"userId": 1,
	"userName": "UserName",
	"email": "user.email@example.com",
	"role": "USER",
	"profile": {
		"age": 28,
		"height": 178,
		"weight": 72,
		"gender": "male"
	}
}
```

> **Note**: The `gender` field in `profile` is optional. It may be `null` if not set by the user.

## 9. Update User Brief Info Request (F -> B)

- Request method and path: `PUT /api/user?id=<userId>`（或 `PUT /api/ums/user?id=<userId>`）
- Request header: `Authorization: Bearer <accessToken>`
- Request header: `Content-Type: application/json`

Request body:

```json
{
	"userId": 2345678765678,
	"userName": "UpdatedUserName",
	"email": "updated.email@example.com",
	"profile": {
		"age": 30,
		"height": 180,
		"weight": 75,
		"gender": "male"
	}
}
```

> **Note**: All fields in the request body are optional. Only provided fields will be updated.

## 10. Update User Brief Info Response (B -> F)

```json
{
	"userId": 2345678765678,
	"message": "User info updated successfully"
}
```

## 11. Get User Preferences Request (F -> B)

- Request method and path: `GET /api/user/preferences?userId=<userId>`（或 `/api/ums/user/preferences?userId=<userId>`）
- Request header: `Authorization: Bearer <accessToken>`
- Request header: `Content-Type: application/json`

## 12. Get User Preferences Response (B -> F)

```json
{
	"userId": 2345678765678,
	"preferences": {
		"dietaryType": "vegetarian",
		"cuisineTypes": ["Italian", "Chinese", "Japanese"],
		"spiceLevel": "medium",
		"cookingTimePreference": "30-60min"
	}
}
```

## 13. Update User Preferences Request (F -> B)

- Request method and path: `PUT /api/user/preferences?userId=<userId>`（或 `/api/ums/user/preferences?userId=<userId>`）
- Request header: `Authorization: Bearer <accessToken>`
- Request header: `Content-Type: application/json`

Request body:

```json
{
	"dietaryType": "vegetarian",
	"cuisineTypes": ["Italian", "Chinese", "Japanese"],
	"spiceLevel": "medium",
	"cookingTimePreference": "30-60min"
}
```

## 14. Update User Preferences Response (B -> F)

```json
{
	"userId": 2345678765678,
	"message": "User preferences updated successfully"
}
```

## 15. Get User Taboos / Diet Habits Request (F -> B)

- Request method and path: `GET /api/user/diet-habits?userId=<userId>`（后端使用 diet-habits 表示饮食禁忌/习惯）
- Request header: `Authorization: Bearer <accessToken>`
- Request header: `Content-Type: application/json`

## 16. Get User Taboos / Diet Habits Response (B -> F)

`Result.data` 结构（后端字段为 `dietHabits`）：

```json
{
	"userId": 1,
	"dietHabits": [
		"vegetarian",
		"no_pork"
	]
}
```

## 17. Update User Taboos / Diet Habits Request (F -> B)

- Request method and path: `PUT /api/user/diet-habits?userId=<userId>`
- Request header: `Authorization: Bearer <accessToken>`
- Request header: `Content-Type: application/json`
- Request body:

```json
{
	"dietHabits": [
		"vegetarian",
		"no_pork",
		"no_alcohol"
	]
}
```

## 18. Update User Taboos / Diet Habits Response (B -> F)

`Result.data` 为更新后的 `{ "userId": <id>, "dietHabits": [...] }` 结构。

## 19. Get User Allergies Request (F -> B)

- Request method and path: `GET /api/user/allergies?userId=<userId>`（或 `/api/ums/user/allergies?userId=<userId>`）
- Request header: `Authorization: Bearer <accessToken>`
- Request header: `Content-Type: application/json`

## 20. Get User Allergies Response (B -> F)

```json
{
	"userId": 2345678765678,
	"allergies": [
		"peanuts",
		"shellfish",
		"dairy"
	]
}
```

## 21. Update User Allergies Request (F -> B)

- Request method and path: `PUT /api/user/allergies?userId=<userId>`（或 `/api/ums/user/allergies?userId=<userId>`）
- Request header: `Authorization: Bearer <accessToken>`
- Request header: `Content-Type: application/json`

Request body:

```json
{
	"allergies": [
		"peanuts",
		"shellfish",
		"dairy",
		"eggs"
	]
}
```

## 22. Update User Allergies Response (B -> F)

```json
{
	"userId": 2345678765678,
	"message": "User allergies updated successfully"
}
```

# D. IMS (Inventory Management Service)

## 1. Add to Inventory Request (F -> B)

（见后端 `POST /api/inventory/ingredients`，请求体为 `IngredientRequest`。）

# E. CMS (Cooking Management Service)

（见后端 `POST /api/cooking/start`、`POST /api/cooking/finish` 等。）

# F. RMS (Recipe Management Service)

## 1. Generate Menus (F -> B)

- Request method and path: `POST /api/ai/generate-menus?householdId=<householdId>`（可选查询参数 `householdId`，用于自动填充库存/偏好）
- Request header: `Authorization: Bearer <accessToken>`
- Request header: `Content-Type: application/json`
- Request body:

```JSON
{
  "inventory": [
    {
      "name": "chicken thigh",
      "amount_value": 500,
      "amount_unit": "g",
      "expires_at": "2025-11-29"
    },
    {
      "name": "broccoli",
      "amount_value": 300,
      "amount_unit": "g",
      "expires_at": "2025-11-30"
    },
    {
      "name": "rice",
      "amount_value": 400,
      "amount_unit": "g",
      "expires_at": null
    }
  ],
  "calorie_target": {
    "min_total_kcal": 1500,
    "max_total_kcal": 1800
  },
  "servings": 1,
  "diet_preferences": {
    "cuisine_preferences": ["chinese", "japanese"],
    "taste_preferences": ["light", "umami"],
    "avoid_ingredients": ["coriander"],
    "diet_habits": ["vegetarian"],
    "allergies": []
  },
  "generation_settings": {
    "dish_count": 1,
    "max_cooking_time_min": 40,
    "difficulty_target": "easy"
  },
  "cookers": [
    "stove",
    "rice_cooker"
  ],
  "seasonings": [
    "salt",
    "sugar",
    "black_pepper",
    "soy_sauce",
    "olive_oil"
  ]
}
```
- Response (B->F):

```JSON
{
  "menus": [
    {
      "menu_id": 1,
      "recipes": [
        {
          "title": "Garlic Butter Chicken with Steamed Broccoli",
          "short_description": "Pan-seared chicken thigh with garlic butter sauce and steamed broccoli.",
          "servings": 1,
          "cooking_time_min": 30,
          "difficulty": "easy",
          "total_calories_estimate": 650,
          "ingredients": [
            {
              "name": "chicken thigh",
              "amount_value": 200,
              "amount_unit": "g",
              "is_optional": false
            },
            {
              "name": "broccoli",
              "amount_value": 150,
              "amount_unit": "g",
              "is_optional": false
            },
            {
              "name": "rice",
              "amount_value": 80,
              "amount_unit": "g",
              "is_optional": false
            },
            {
              "name": "olive oil",
              "amount_value": 10,
              "amount_unit": "ml",
              "is_optional": false
            },
            {
              "name": "salt",
              "amount_value": 3,
              "amount_unit": "g",
              "is_optional": false
            },
            {
              "name": "black pepper",
              "amount_value": 1,
              "amount_unit": "g",
              "is_optional": true
            }
          ],
          "steps": [
            {
              "step_number": 1,
              "instruction": "Season the chicken thigh with salt and black pepper.",
              "step_time_min": 5
            },
            {
              "step_number": 2,
              "instruction": "Pan-fry the chicken with olive oil over medium heat until cooked through.",
              "step_time_min": 15
            },
            {
              "step_number": 3,
              "instruction": "Steam the broccoli until just tender.",
              "step_time_min": 7
            },
            {
              "step_number": 4,
              "instruction": "Plate the rice, sliced chicken and broccoli.",
              "step_time_min": 3
            }
          ]
        }
      ]
    },
    {
      "menu_id": 2,
      "recipes": [
        {
          "title": "Light Chicken and Broccoli Rice Bowl",
          "short_description": "One-bowl light rice dish with simmered chicken and broccoli.",
          "servings": 1,
          "cooking_time_min": 25,
          "difficulty": "easy",
          "total_calories_estimate": 580,
          "ingredients": [
            {
              "name": "chicken thigh",
              "amount_value": 180,
              "amount_unit": "g",
              "is_optional": false
            },
            {
              "name": "broccoli",
              "amount_value": 120,
              "amount_unit": "g",
              "is_optional": false
            },
            {
              "name": "rice",
              "amount_value": 90,
              "amount_unit": "g",
              "is_optional": false
            },
            {
              "name": "soy_sauce",
              "amount_value": 8,
              "amount_unit": "ml",
              "is_optional": false
            },
            {
              "name": "salt",
              "amount_value": 2,
              "amount_unit": "g",
              "is_optional": false
            }
          ],
          "steps": [
            {
              "step_number": 1,
              "instruction": "Cook the rice in the rice cooker according to package instructions.",
              "step_time_min": 15
            },
            {
              "step_number": 2,
              "instruction": "Stir-fry chicken pieces with a little oil until they change color.",
              "step_time_min": 5
            },
            {
              "step_number": 3,
              "instruction": "Add broccoli, soy sauce, salt and a splash of water, simmer until broccoli is tender and chicken is cooked through.",
              "step_time_min": 5
            }
          ]
        }
      ]
    }
  ]
}
```

## 2. Get Default Recipe Preferences (F -> B)

- Request method and path: `GET /api/recipes/default-filter?householdId=<householdId>`
- Request header: `Authorization: Bearer <accessToken>`
- Response (B -> F) 为 `Result.data`，结构同下方 JSON：

```JSON
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
    "diet_habits": [],
    "allergies": []
  },
  "calorie_target": {
    "min_total_kcal": 1500,
    "max_total_kcal": 1800
  }
}
```

## 3. Get Favorite Recipes List (F -> B)

- Request method and path: `GET /api/recipes/favorites?householdId=<householdId>`
- Request header: `Authorization: Bearer <accessToken>`
- Response (B -> F) 为 `Result.data`（收藏菜谱列表）：

```JSON
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
    },
    {
      "recipeId": "rec_987654",
      "title": "Garlic Butter Chicken",
      "short_description": "Pan-seared chicken with garlic butter sauce.",
      "servings": 1,
      "cooking_time_min": 30,
      "difficulty": "medium",
      "total_calories_estimate": 800
    }
  ]
}
```

## 4. Get Favorite Recipe Detail (F -> B)

- Request method and path: 由收藏列表接口返回完整菜谱信息；或通过烹饪/菜谱相关接口根据 `recipeId`/`dishId` 获取详情。
- Request header: `Authorization: Bearer <accessToken>`
- Response (B -> F) 示例结构：

```JSON
{
  "recipeId": "rec_123456",
  "title": "Tomato Egg Stir-fry",
  "short_description": "Light Chinese-style stir fry with tomato and egg.",
  "servings": 1,
  "cooking_time_min": 15,
  "difficulty": "easy",
  "total_calories_estimate": 320,
  "ingredients": [
    {
      "name": "egg",
      "amount_value": 2,
      "amount_unit": "piece",
      "is_optional": false
    },
    {
      "name": "tomato",
      "amount_value": 150,
      "amount_unit": "g",
      "is_optional": false
    },
    {
      "name": "salt",
      "amount_value": 2,
      "amount_unit": "g",
      "is_optional": false
    }
  ],
  "steps": [
    {
      "step_number": 1,
      "instruction": "Beat the eggs with a pinch of salt.",
      "step_time_min": 3
    },
    {
      "step_number": 2,
      "instruction": "Stir-fry tomatoes until soft, then add eggs.",
      "step_time_min": 7
    },
    {
      "step_number": 3,
      "instruction": "Season to taste and serve hot.",
      "step_time_min": 5
    }
  ]
}
```

## 5. Add / Toggle Favorite Recipe (F -> B)

- Request method and path: `POST /api/recipes/favorite?householdId=<householdId>&recipeId=<recipeId>`（或按后端实际参数：若为“切换收藏”则同一接口可添加/取消）
- Request header: `Authorization: Bearer <accessToken>`
- Request header: `Content-Type: application/json`
- Request body（若后端要求 body）：

```JSON
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
      {
        "name": "egg",
        "amount_value": 2,
        "amount_unit": "piece",
        "is_optional": false
      },
      {
        "name": "tomato",
        "amount_value": 150,
        "amount_unit": "g",
        "is_optional": false
      },
      {
        "name": "salt",
        "amount_value": 2,
        "amount_unit": "g",
        "is_optional": false
      }
    ],
    "steps": [
      {
        "step_number": 1,
        "instruction": "Beat the eggs with a pinch of salt.",
        "step_time_min": 3
      },
      {
        "step_number": 2,
        "instruction": "Stir-fry tomatoes until soft, then add eggs.",
        "step_time_min": 7
      },
      {
        "step_number": 3,
        "instruction": "Season to taste and serve hot.",
        "step_time_min": 5
      }
    ]
  }
}
```
- Response (B -> F):

```JSON
{
  "recipeId": "rec_123456",
  "message": "Recipe added to favorites"
}
```

## 7. Remove Favorite Recipe (F -> B)

- Request method and path: `POST /api/recipes/favorite?householdId=<householdId>&recipeId=<recipeId>`（若为 toggle，再次调用即取消收藏）；或 `DELETE /api/recipes/favorite?householdId=...&recipeId=...`（以实际后端为准）
- Request header: `Authorization: Bearer <accessToken>`
- Response (B -> F)：

```JSON
{
  "message": "Recipe removed from favorites"
}
```

# G. HP (HomePage)
## 1.Get Weekly Nutrition Targets (F -> B)
- Request method and path: `GET /api/nutrition/targets/weekly`
- Request header:
  - Authorization: Bearer `<accessToken>`
- Response (B -> F):
```JSON
{
  "weekly_target": {
    "energy": 12600,
    "fat": 350,
    "carbohydrates": 1400,
    "protein": 560
  },
  "basis": {
    "bmi": 22.3,
    "goal_type": "fat_loss",
    "calculation_model": "mifflin_st_jeor",
    "week_start": "2025-11-24",
    "week_end": "2025-11-30"
  }
}
```
## 2. Get Weekly Nutrition Summary (F -> B)
- Request method and path: `GET /api/nutrition/summary?period=week`
- Request header:
  - Authorization: Bearer <accessToken>
- Response (B -> F):
```JSON
{
  "period": "week",
  "week_start": "2025-11-24",
  "week_end": "2025-11-30",
  "consumed": {
    "energy": 4200,
    "fat": 120,
    "carbohydrates": 480,
    "protein": 180
  },
  "remaining": {
    "energy": 8400,
    "fat": 230,
    "carbohydrates": 920,
    "protein": 380
  }
}
```
## 3. Get Today Intakes (F -> B)
- Request method and path: `GET /api/intake/today?source=recipe`
                           `GET /api/intake/today?source=manual`
- Request header:
  - Authorization: Bearer <accessToken>
- Response 1 (B -> F):
```JSON
{
  "date": "2025-11-29",
  "source": "recipe",
  "items": [
    {
      "intake_id": 101,
      "source_type": "recipe",
      "recipe_id": 1,
      "recipe_title": "Garlic Butter Chicken with Steamed Broccoli",
      "consumed_percentage": 50,
      "base_nutrition": {
        "energy": 650,
        "fat": 18,
        "carbohydrates": 50,
        "protein": 30
      },
      "effective_nutrition": {
        "energy": 325,
        "fat": 9,
        "carbohydrates": 25,
        "protein": 15
      }
    },
    {
      "intake_id": 102,
      "source_type": "recipe",
      "recipe_id": 2,
      "recipe_title": "Light Chicken and Broccoli Rice Bowl",
      "consumed_percentage": 0,
      "base_nutrition": {
        "energy": 580,
        "fat": 14,
        "carbohydrates": 60,
        "protein": 24
      },
      "effective_nutrition": {
        "energy": 0,
        "fat": 0,
        "carbohydrates": 0,
        "protein": 0
      }
    }
  ]
}
```
- Response 2 (B -> F):
```JSON
{
  "date": "2025-11-29",
  "source": "manual",
  "items": [
    {
      "intake_id": 201,
      "source_type": "manual",
      "manual_food_name": "fried rice with egg",
      "effective_nutrition": {
        "energy": 650,
        "fat": 20,
        "carbohydrates": 80,
        "protein": 18
      }
    }
  ]
}
```
## 4. Update Intake Percentage (F -> B)
- Request method and path: `PATCH /api/intake/{intake_id}`

- Request header:
  - Authorization: Bearer <accessToken>
  - Content-Type: application/json
- Request body:
{
  "consumed_percentage": 80
}
- Response (B -> F):
```JSON
{
  "intake": {
    "intake_id": 101,
    "source_type": "recipe",
    "recipe_id": 1,
    "recipe_title": "Garlic Butter Chicken with Steamed Broccoli",
    "date": "2025-11-29",
    "consumed_percentage": 80,
    "base_nutrition": {
      "energy": 650,
      "fat": 18,
      "carbohydrates": 50,
      "protein": 30
    },
    "effective_nutrition": {
      "energy": 520,
      "fat": 14.4,
      "carbohydrates": 40,
      "protein": 24
    }
  },
  "weekly_summary": {
    "week_start": "2025-11-24",
    "week_end": "2025-11-30",
    "consumed": {
      "energy": 4720,
      "fat": 134,
      "carbohydrates": 520,
      "protein": 204
    }
  }
}
```
## 4. Add Manual Intake (F -> B)
- Request method and path: `POST /api/intake/manual`

- Request header:
  - Authorization: Bearer <accessToken>
  - Content-Type: application/json
- Request body:
{
  "date": "2025-11-29",
  "food_name": "fried rice with egg",
  "portion_description": "1 bowl"
}
- Response (B -> F):
```JSON
{
  "intake": {
    "intake_id": 201,
    "source_type": "manual",
    "date": "2025-11-29",
    "manual_food_name": "fried rice with egg",
    "portion_description": "1 bowl",
    },
    "effective_nutrition": {
      "energy": 650,
      "fat": 20,
      "carbohydrates": 80,
      "protein": 18
    }
  },
  "weekly_summary": {
    "week_start": "2025-11-24",
    "week_end": "2025-11-30",
    "consumed": {
      "energy": 4850,
      "fat": 140,
      "carbohydrates": 560,
      "protein": 222
    }
  }
}
```
