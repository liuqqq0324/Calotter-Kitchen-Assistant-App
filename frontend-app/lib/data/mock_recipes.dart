// lib/data/mock_recipes.dart
import 'package:personal_sous_chef/models/recipe_models.dart';

const List<RecipeMenuModel> kMockRecipeMenus = [
  RecipeMenuModel(
    menuId: 1,
    recipes: [
      RecipeModel(
        id: 'm1_r1',
        title: 'Tomato Egg Stir-fry',
        shortDescription: 'Light Chinese-style stir fry with tomato and egg.',
        servings: 1,
        cookingTimeMin: 15,
        difficulty: 'easy',
        totalCaloriesEstimate: 320,
        emoji: '🍅',
        ingredients: [
          RecipeIngredientModel(
            name: 'Tomato',
            amountValue: 150,
            amountUnit: 'g',
          ),
          RecipeIngredientModel(
            name: 'Egg',
            amountValue: 2,
            amountUnit: 'piece',
          ),
        ],
        steps: [
          RecipeStepModel(
            stepNumber: 1,
            instruction: 'Beat the eggs with a pinch of salt.',
            stepTimeMin: 3,
          ),
          RecipeStepModel(
            stepNumber: 2,
            instruction: 'Stir-fry tomatoes until soft, then add eggs.',
            stepTimeMin: 7,
          ),
          RecipeStepModel(
            stepNumber: 3,
            instruction: 'Season to taste and serve hot.',
            stepTimeMin: 5,
          ),
        ],
      ),
    ],
  ),
  RecipeMenuModel(
    menuId: 2,
    recipes: [
      RecipeModel(
        id: 'm2_r1',
        title: 'Garlic Butter Chicken',
        shortDescription: 'Pan-seared chicken with garlic butter sauce.',
        servings: 2,
        cookingTimeMin: 30,
        difficulty: 'medium',
        totalCaloriesEstimate: 680,
        emoji: '🍗',
        ingredients: [
          RecipeIngredientModel(
            name: 'Chicken thigh',
            amountValue: 300,
            amountUnit: 'g',
          ),
        ],
        steps: [
          RecipeStepModel(
            stepNumber: 1,
            instruction: 'Season chicken and pan-fry until golden.',
            stepTimeMin: 15,
          ),
          RecipeStepModel(
            stepNumber: 2,
            instruction: 'Add garlic and butter, cook until fragrant.',
            stepTimeMin: 10,
          ),
          RecipeStepModel(
            stepNumber: 3,
            instruction: 'Rest for a few minutes and serve.',
            stepTimeMin: 5,
          ),
        ],
      ),
      // 再加一道简单菜，模拟 dish_count > 1
      RecipeModel(
        id: 'm2_r2',
        title: 'Steamed Broccoli',
        shortDescription: 'Simple steamed broccoli with olive oil.',
        servings: 2,
        cookingTimeMin: 10,
        difficulty: 'easy',
        totalCaloriesEstimate: 120,
        emoji: '🥦',
        ingredients: [
          RecipeIngredientModel(
            name: 'Broccoli',
            amountValue: 200,
            amountUnit: 'g',
          ),
        ],
        steps: [
          RecipeStepModel(
            stepNumber: 1,
            instruction: 'Cut broccoli into florets.',
            stepTimeMin: 3,
          ),
          RecipeStepModel(
            stepNumber: 2,
            instruction: 'Steam until tender but still crisp.',
            stepTimeMin: 7,
          ),
        ],
      ),
    ],
  ),
  // 为了凑够 5 套菜单，再简单复制几套
  RecipeMenuModel(menuId: 3, recipes: [
    RecipeModel(
      id: 'm3_r1',
      title: 'Creamy Mushroom Pasta',
      shortDescription: 'Quick pasta with creamy mushroom sauce.',
      servings: 1,
      cookingTimeMin: 25,
      difficulty: 'medium',
      totalCaloriesEstimate: 550,
      emoji: '🍝',
      ingredients: [],
      steps: [],
    ),
  ]),
  RecipeMenuModel(menuId: 4, recipes: [
    RecipeModel(
      id: 'm4_r1',
      title: 'Veggie Fried Rice',
      shortDescription: 'Use leftover rice and mixed veggies.',
      servings: 1,
      cookingTimeMin: 20,
      difficulty: 'easy',
      totalCaloriesEstimate: 480,
      emoji: '🍚',
      ingredients: [],
      steps: [],
    ),
  ]),
  RecipeMenuModel(menuId: 5, recipes: [
    RecipeModel(
      id: 'm5_r1',
      title: 'Baked Garlic Potatoes',
      shortDescription: 'Crispy on the outside, soft inside.',
      servings: 2,
      cookingTimeMin: 45,
      difficulty: 'hard',
      totalCaloriesEstimate: 720,
      emoji: '🥔',
      ingredients: [],
      steps: [],
    ),
  ]),
];
