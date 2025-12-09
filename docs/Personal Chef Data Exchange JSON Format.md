---
date: 2025-11-26
version: 1
tags:
  - api
  - documentation
  - INFOSYS-778
  - GroupProject
---



### `F` represents *Frontend app*, `B` represents *Backend app*, `A` represents *AI-Engine* (e.g., `F -> B` refers to frontend app is sending data to backend API).

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
## 1. Registration Request (F -> B)

- Request method and path: `POST /api/ums/auth/register`
- Request header: Context-Type: application/json
- Request body:

```JSON
{
	"username": "UserName",
	"password": "UserPassword123",
	"confirmPassword": "UserPassword123",
	"email": "user.email@example.com"
}
```


## 2. Registration Response (B -> F)
```JSON
{
	"userId": 2345678765678,
	"message": "User registered successfully"
}
```

## 3. Login Request (F -> B)
- Request method and path: `POST /api/ums/auth/login`
- Request header: Context-Type: application/json
- Request body:
```JSON
{
	"identifier": "UsernameOrEmail",
	"password": "UserPassword123"
}
```

## 4. Login Response (B -> F)
```JSON
{
	"userId": 2345678765678,
	"token": {
		"accessToken": "56ncieni-oenlnoicsjoijjfofoi",
		"expiresIn": 3000
	}
}
```

## 5. User Brief Info Request(F -> B)
- Request method and path: `GET /api/ums/user?id=2345678765678`
- Request header: 
	- Authorization: Bearer
	- Context-Type: application/json

## 6. User Brief Info Response (B -> F)
```JSON
{
	"userId": 2345678765678,
	"userName": "UserName",
	"email": "user.email@example.com",
	"profile": {
		"age": 28,
		"height": 178,
		"weight": 72
	}
}
```
## 7. Get User Preferences Request (F -> B)

Request method and path: GET /api/ums/user/preferences?id=2345678765678

Request header:

Authorization: Bearer

Context-Type: application/json

## 8. Get User Preferences Response (B -> F)

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

## 9. Update User Preferences Request (F -> B)

Request method and path: PUT /api/ums/user/preferences?id=2345678765678

Request header:

Authorization: Bearer

Context-Type: application/json

Request body:

```json
{
	"dietaryType": "vegetarian",
	"cuisineTypes": ["Italian", "Chinese", "Japanese"],
	"spiceLevel": "medium",
	"cookingTimePreference": "30-60min"
}
```

## 10. Update User Preferences Response (B -> F)

```json
{
	"userId": 2345678765678,
	"message": "User preferences updated successfully"
}
```

## 11. Get User Taboos Request (F -> B)

Request method and path: GET /api/ums/user/taboos?id=2345678765678

Request header:

Authorization: Bearer

Context-Type: application/json

## 12. Get User Taboos Response (B -> F)

```json
{
	"userId": 2345678765678,
	"taboos": [
		"pork",
		"beef"
	]
}
```

## 13. Update User Taboos Request (F -> B)

Request method and path: PUT /api/ums/user/taboos?id=2345678765678

Request header:

Authorization: Bearer

Context-Type: application/json

Request body:

```json
{
	"taboos": [
		"pork",
		"beef",
		"alcohol"
	]
}
```

## 14. Update User Taboos Response (B -> F)

```json
{
	"userId": 2345678765678,
	"message": "User taboos updated successfully"
}
```

## 15. Get User Allergies Request (F -> B)

Request method and path: GET /api/ums/user/allergies?id=2345678765678

Request header:

Authorization: Bearer

Context-Type: application/json

## 16. Get User Allergies Response (B -> F)

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

## 17. Update User Allergies Request (F -> B)

Request method and path: PUT /api/ums/user/allergies?id=2345678765678

Request header:

Authorization: Bearer

Context-Type: application/json

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

## 18. Update User Allergies Response (B -> F)

```json
{
	"userId": 2345678765678,
	"message": "User allergies updated successfully"
}
```

## 

# D. IMS (Inventory Management Service)
## 1. Add to Inventory Request (F -> B)

# E. CMS (Cooking Management Service)

# F. RMS (Recipe Management Service)
## 1. Generate Menus (F -> B)
- Request method and path: `POST /api/recipes/generate`
- Request header:
  - Authorization: Bearer `<accessToken>`
  - Content-Type: application/json
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
- Request method and path: GET /api/recipes/preferences/default
- Request header:
	- Authorization: Bearer <accessToken>
- Response (B -> F):

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
    "allergies": []
  },
  "calorie_target": {
    "min_total_kcal": 1500,
    "max_total_kcal": 1800
  }
}
```

## 3. Get Favorite Recipes List (F -> B)
- Request method and path: GET /api/users/me/favorite-recipes
- Request header:
	- Authorization: Bearer <accessToken>
- Response (B -> F):

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
- Request method and path: GET /api/users/me/favorite-recipes/{recipeId}
- Request header:
	- Authorization: Bearer <accessToken>
- Response (B -> F):

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

## 5. Add favourite Recipe (F -> B)
- Request method and path: POST /api/users/me/favorite-recipes
- Request header:
	- Authorization: Bearer <accessToken>
	- Content-Type: application/json
- Request body:

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
- Request method and path: DELETE /api/users/me/favorite-recipes/{recipeId}
- Request header:
	- Authorization: Bearer <accessToken>
- Response (B -> F):

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
