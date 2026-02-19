package com.calotter.cooking.service;

import com.calotter.common.core.domain.PreferenceStandardLibrary;
import com.calotter.cooking.controller.dto.RecipeGenerationFilter;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 偏好数据转换工具类
 * 提供 User.preferences Map 和 RecipeGenerationFilter.DietPreferences 之间的转换方法
 */
public class PreferenceConverter {
    
    /**
     * 将 User.preferences Map 转换为 RecipeGenerationFilter.DietPreferences
     * 
     * <p>映射关系：
     * <ul>
     *   <li>User.preferences["TASTE"] -> DietPreferences.tastePreferences</li>
     *   <li>User.preferences["CUISINE"] -> DietPreferences.cuisinePreferences</li>
     * </ul>
     * 
     * <p>注意：avoidIngredients 应该从 User.taboos 或其他来源获取，不在此转换中处理。
     * 
     * @param userPreferences User 实体的 preferences Map
     * @return RecipeGenerationFilter.DietPreferences 对象
     */
    public static RecipeGenerationFilter.DietPreferences toDietPreferences(
            Map<String, List<String>> userPreferences) {
        RecipeGenerationFilter.DietPreferences dietPrefs = 
            new RecipeGenerationFilter.DietPreferences();
        
        if (userPreferences != null) {
            dietPrefs.setTastePreferences(
                userPreferences.getOrDefault(PreferenceStandardLibrary.PREF_KEY_TASTE, new ArrayList<>()));
            dietPrefs.setCuisinePreferences(
                userPreferences.getOrDefault(PreferenceStandardLibrary.PREF_KEY_CUISINE, new ArrayList<>()));
            // avoidIngredients 不再从 preferences 获取
        }
        
        return dietPrefs;
    }
    
    /**
     * 将 RecipeGenerationFilter.DietPreferences 转换为 User.preferences Map
     * 
     * <p>映射关系：
     * <ul>
     *   <li>DietPreferences.tastePreferences -> User.preferences["TASTE"]</li>
     *   <li>DietPreferences.cuisinePreferences -> User.preferences["CUISINE"]</li>
     * </ul>
     * 
     * <p>注意：avoidIngredients 不会转换回 preferences，应该存储到 User.taboos 或其他地方。
     * 
     * @param dietPrefs RecipeGenerationFilter.DietPreferences 对象
     * @return User 实体的 preferences Map
     */
    public static Map<String, List<String>> toUserPreferencesMap(
            RecipeGenerationFilter.DietPreferences dietPrefs) {
        Map<String, List<String>> preferences = new HashMap<>();
        
        if (dietPrefs != null) {
            if (dietPrefs.getTastePreferences() != null && !dietPrefs.getTastePreferences().isEmpty()) {
                preferences.put(PreferenceStandardLibrary.PREF_KEY_TASTE, dietPrefs.getTastePreferences());
            }
            if (dietPrefs.getCuisinePreferences() != null && !dietPrefs.getCuisinePreferences().isEmpty()) {
                preferences.put(PreferenceStandardLibrary.PREF_KEY_CUISINE, dietPrefs.getCuisinePreferences());
            }
            // avoidIngredients 不再转换回 preferences
        }
        
        return preferences;
    }
    
    
    private PreferenceConverter() {
        // 工具类，禁止实例化
        throw new UnsupportedOperationException("Utility class cannot be instantiated");
    }
}

