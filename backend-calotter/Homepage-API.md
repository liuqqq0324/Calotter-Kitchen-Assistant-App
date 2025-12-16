HP (HomePage)
1.Get Weekly Nutrition Targets (F -> B)
Request method and path: GET /api/nutrition/targets/weekly
Request header:
Authorization: Bearer <accessToken>
Response (B -> F):
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
2. Get Weekly Nutrition Summary (F -> B)
Request method and path: GET /api/nutrition/summary?period=week
Request header:
Authorization: Bearer
Response (B -> F):
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
3. Get Today Intakes (F -> B)
Request method and path: GET /api/intake/today?source=recipe GET /api/intake/today?source=manual
Request header:
Authorization: Bearer
Response 1 (B -> F):
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
Response 2 (B -> F):
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
4. Update Intake Percentage (F -> B)
Request method and path: PATCH /api/intake/{intake_id}

Request header:

Authorization: Bearer
Content-Type: application/json
Request body: { "consumed_percentage": 80 }

Response (B -> F):

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
4. Add Manual Intake (F -> B)
Request method and path: POST /api/intake/manual

Request header:

Authorization: Bearer
Content-Type: application/json
Request body: { "date": "2025-11-29", "food_name": "fried rice with egg", "portion_description": "1 bowl" }

Response (B -> F):

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