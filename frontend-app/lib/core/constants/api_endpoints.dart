// API端点常量
// 集中管理所有API路径，便于维护和修改

class ApiEndpoints {
  // User API endpoints
  static const String userRegister = '/api/user/register';
  static const String userLogin = '/api/user/login';
  static const String userLogout = '/api/user/logout';
  static const String userInfo = '/api/user';
  static const String userPreferences = '/api/user/preferences';
  static const String userPreferencesMap = '/api/user/preferences-map';
  static const String userDietHabits = '/api/user/diet-habits';
  static const String userAllergies = '/api/user/allergies';
  static const String userHealthInfo = '/api/user/health-info';
  static const String userHealthGoal = '/api/user/health-goal';
  static const String userStandardAllergens = '/api/user/standard-allergens';

  // Household API endpoints
  static const String householdCurrent = '/api/household/current';
  static const String householdJoin = '/api/household/join';
  static String householdInvite(int householdId) => '/api/household/$householdId/invite';
  static String householdLeave(int householdId) => '/api/household/$householdId/leave';
  static String householdSwitch(int householdId) => '/api/household/$householdId/switch';
  static String householdRegenerateInviteCode(int householdId) => '/api/household/$householdId/regenerate-invite-code';
  static String householdMembers(int householdId, int? memberId) {
    if (memberId != null) {
      return '/api/household/$householdId/members/$memberId';
    }
    return '/api/household/$householdId/members';
  }
  static String householdByUserId(int userId) => '/api/household/user/$userId/joined';
  static String householdByInviteCode(String inviteCode) => '/api/household/invite/$inviteCode';

  // Inventory API endpoints
  static const String inventoryIngredients = '/api/inventory/ingredients';
  static String inventoryIngredient(int id) => '/api/inventory/ingredients/$id';
  static const String inventoryUtensils = '/api/inventory/utensils';
  static String inventoryUtensil(int id) => '/api/inventory/utensils/$id';
  static String inventoryUtensilToggle(int id) => '/api/inventory/utensils/$id/toggle';
  static const String inventorySpices = '/api/inventory/spices';
  static String inventorySpice(int id) => '/api/inventory/spices/$id';
  static String inventorySpiceToggle(int id) => '/api/inventory/spices/$id/toggle';
  static const String inventoryLeftovers = '/api/inventory/leftovers';
  static String inventoryLeftover(int id) => '/api/inventory/leftovers/$id';
  
  // Standard Library API endpoints
  static const String standardIngredientsSearch = '/api/inventory/standard-ingredients/search';
  static const String standardIngredients = '/api/inventory/standard-ingredients';
  static String standardIngredient(int id) => '/api/inventory/standard-ingredients/$id';
  static String standardIngredientAllowedUnits(int id) => '/api/inventory/standard-ingredients/$id/allowed-units';
  static const String standardUtensils = '/api/inventory/standard-utensils';
  static const String standardSpices = '/api/inventory/standard-spices';

  // Recipe API endpoints
  static const String recipesDefaultFilter = '/api/recipes/default-filter';
  static const String recipesFavorites = '/api/recipes/favorites';
  static const String recipeFavorite = '/api/recipes/favorite';

  // AI API endpoints
  static const String aiGenerateMenus = '/api/ai/generate-menus';

  // Cooking API endpoints
  static const String cookingStart = '/api/cooking/start';
  static const String cookingFinish = '/api/cooking/finish';

  // Homepage/Nutrition API endpoints
  static const String nutritionTargetsWeekly = '/api/nutrition/targets/weekly';
  static const String nutritionTargetsDaily = '/api/nutrition/targets/daily';
  static const String nutritionSummary = '/api/nutrition/summary';
  static const String nutritionSummaryDaily = '/api/nutrition/summary/daily';
  static const String intakeToday = '/api/intake/today';
  static String intake(int intakeId) => '/api/intake/$intakeId';
  static const String intakeManual = '/api/intake/manual';
  static const String intakeDishOptions = '/api/intake/dish/options';
  static const String intakeDish = '/api/intake/dish';
}

