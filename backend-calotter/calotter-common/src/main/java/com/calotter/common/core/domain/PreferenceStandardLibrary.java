package com.calotter.common.core.domain;

import java.util.*;

/**
 * 用户偏好标准库
 * 统一管理所有偏好类型的预设值，与前端 filter 页面保持一致
 * 
 * <p>该标准库解决了以下问题：
 * <ul>
 *   <li>统一管理偏好类型的 Key 常量</li>
 *   <li>提供与前端一致的预设值列表</li>
 *   <li>提供验证方法确保值在标准库中</li>
 * </ul>
 * 
 * <p>注意：转换方法（User.preferences Map 和 RecipeGenerationFilter.DietPreferences 之间的转换）
 * 请参考 {@link com.calotter.cooking.service.PreferenceConverter} 工具类。
 */
public class PreferenceStandardLibrary {
    
    // ========== Preference Key 常量 ==========
    /** 口味偏好 Key (对应 User.preferences Map 的 Key) */
    public static final String PREF_KEY_TASTE = "TASTE";
    
    /** 菜系偏好 Key (对应 User.preferences Map 的 Key) */
    public static final String PREF_KEY_CUISINE = "CUISINE";
    
    /** 硬性饮食习惯 Key (对应 User.dietaryStyles Map 的 Key) */
    public static final String PREF_KEY_DIET_HABITS = "DIET_HABITS";
    
    /** 避免食材 Key (对应 User.dietaryStyles Map 的 Key) */
    public static final String PREF_KEY_AVOID_INGREDIENT = "AVOID_INGREDIENT";
    
    // ========== 菜系偏好预设值 (Cuisine Preferences) ==========
    /** 菜系偏好选项列表，与前端 recipe_filter_page.dart 保持一致 */
    public static final List<String> CUISINE_OPTIONS = Arrays.asList(
        "chinese",
        "japanese",
        "korean",
        "south_east_asian",
        "indian",
        "western",
        "italian",
        "mediterranean",
        "mexican",
        "middle_eastern",
        "fusion"
    );
    
    // ========== 口味偏好预设值 (Taste Preferences) ==========
    /** 口味偏好选项列表，与前端 recipe_filter_page.dart 保持一致 */
    public static final List<String> TASTE_OPTIONS = Arrays.asList(
        "light",
        "rich",
        "spicy",
        "sweet",
        "sour",
        "salty",
        "umami"
    );
    
    // ========== 难度预设值 (Difficulty) ==========
    /** 难度选项列表，与前端 recipe_filter_page.dart 保持一致 */
    public static final List<String> DIFFICULTY_OPTIONS = Arrays.asList(
        "easy",
        "medium",
        "hard"
    );
    
    // ========== 厨具预设值 (Cookers) ==========
    /** 厨具选项列表，与前端 recipe_filter_page.dart 保持一致 */
    public static final List<String> COOKER_OPTIONS = Arrays.asList(
        "stove",
        "oven",
        "microwave",
        "air_fryer",
        "rice_cooker",
        "pressure_cooker",
        "steamer",
        "slow_cooker",
        "blender"
    );
    
    // ========== 硬性饮食习惯预设值 (Dietary Habits) ==========
    /** 硬性饮食习惯选项列表（英文值） */
    public static final List<String> DIET_HABITS_OPTIONS = Arrays.asList(
        "low_sodium",      // 低钠
        "low_sugar",       // 低糖
        "low_fat",         // 低脂
        "low_calorie",     // 低卡
        "halal",           // 清真
        "vegetarian",      // 素食
        "vegan",           // 纯素
        "gluten_free",     // 无麸质
        "lactose_free",    // 无乳糖
        "soy_free",        // 无大豆
        "nut_free"         // 无坚果
    );
    
    // ========== 工具方法：验证 ==========
    
    /**
     * 验证菜系偏好值是否有效
     * @param cuisine 菜系值
     * @return 是否在标准库中
     */
    public static boolean isValidCuisine(String cuisine) {
        return cuisine != null && CUISINE_OPTIONS.contains(cuisine);
    }
    
    /**
     * 验证口味偏好值是否有效
     * @param taste 口味值
     * @return 是否在标准库中
     */
    public static boolean isValidTaste(String taste) {
        return taste != null && TASTE_OPTIONS.contains(taste);
    }
    
    /**
     * 验证难度值是否有效
     * @param difficulty 难度值
     * @return 是否在标准库中
     */
    public static boolean isValidDifficulty(String difficulty) {
        return difficulty != null && DIFFICULTY_OPTIONS.contains(difficulty);
    }
    
    /**
     * 验证厨具值是否有效
     * @param cooker 厨具值
     * @return 是否在标准库中
     */
    public static boolean isValidCooker(String cooker) {
        return cooker != null && COOKER_OPTIONS.contains(cooker);
    }
    
    /**
     * 验证硬性饮食习惯值是否有效
     * @param dietHabit 饮食习惯值
     * @return 是否在标准库中
     */
    public static boolean isValidDietHabit(String dietHabit) {
        return dietHabit != null && DIET_HABITS_OPTIONS.contains(dietHabit);
    }
    
    
    private PreferenceStandardLibrary() {
        // 工具类，禁止实例化
        throw new UnsupportedOperationException("Utility class cannot be instantiated");
    }
}

