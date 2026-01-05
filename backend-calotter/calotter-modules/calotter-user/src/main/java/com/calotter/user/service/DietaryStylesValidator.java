package com.calotter.user.service;

import com.calotter.common.core.domain.PreferenceStandardLibrary;
import lombok.extern.slf4j.Slf4j;

import java.util.*;
import java.util.regex.Pattern;

/**
 * 饮食画像验证工具类
 * 确保 dietaryStyles Map 中的值都是英文，并符合标准库要求
 */
@Slf4j
public class DietaryStylesValidator {
    
    // 匹配中文字符的正则表达式
    private static final Pattern CHINESE_PATTERN = Pattern.compile("[\\u4e00-\\u9fa5]");
    
    /**
     * 验证并清理 dietaryStyles Map
     * 
     * <p>验证规则：
     * <ul>
     *   <li>TABOO 列表中的值必须是英文，且在标准库中（可选验证）</li>
     *   <li>AVOID_INGREDIENT 列表中的值必须是英文</li>
     *   <li>移除包含中文字符的值</li>
     * </ul>
     * 
     * @param dietaryStyles 待验证的 dietaryStyles Map
     * @return 清理后的 dietaryStyles Map（如果输入为 null，返回包含空列表的 Map）
     */
    public static Map<String, List<String>> validateAndClean(Map<String, List<String>> dietaryStyles) {
        if (dietaryStyles == null) {
            return createEmptyMap();
        }
        
        Map<String, List<String>> cleaned = new HashMap<>();
        
        // 验证和清理 TABOO
        List<String> taboos = dietaryStyles.getOrDefault(PreferenceStandardLibrary.PREF_KEY_TABOO, new ArrayList<>());
        List<String> cleanedTaboos = cleanAndValidateTaboos(taboos);
        cleaned.put(PreferenceStandardLibrary.PREF_KEY_TABOO, cleanedTaboos);
        
        // 验证和清理 AVOID_INGREDIENT
        List<String> avoidIngredients = dietaryStyles.getOrDefault(PreferenceStandardLibrary.PREF_KEY_AVOID_INGREDIENT, new ArrayList<>());
        List<String> cleanedAvoidIngredients = cleanAndValidateIngredients(avoidIngredients);
        cleaned.put(PreferenceStandardLibrary.PREF_KEY_AVOID_INGREDIENT, cleanedAvoidIngredients);
        
        return cleaned;
    }
    
    /**
     * 清理和验证 TABOO 列表
     * 移除包含中文字符的值，并验证是否在标准库中（可选）
     */
    private static List<String> cleanAndValidateTaboos(List<String> taboos) {
        if (taboos == null || taboos.isEmpty()) {
            return new ArrayList<>();
        }
        
        List<String> cleaned = new ArrayList<>();
        for (String taboo : taboos) {
            if (taboo == null || taboo.trim().isEmpty()) {
                continue;
            }
            
            // 检查是否包含中文字符
            if (containsChinese(taboo)) {
                log.warn("发现包含中文字符的 TABOO 值，已移除: {}", taboo);
                continue;
            }
            
            // 可选：验证是否在标准库中
            // 如果不在标准库中，记录警告但不移除（允许扩展值）
            if (!PreferenceStandardLibrary.isValidTaboo(taboo)) {
                log.debug("TABOO 值不在标准库中，但保留: {}", taboo);
            }
            
            cleaned.add(taboo.trim().toLowerCase()); // 统一转换为小写
        }
        
        return cleaned;
    }
    
    /**
     * 清理和验证 AVOID_INGREDIENT 列表
     * 移除包含中文字符的值
     */
    private static List<String> cleanAndValidateIngredients(List<String> ingredients) {
        if (ingredients == null || ingredients.isEmpty()) {
            return new ArrayList<>();
        }
        
        List<String> cleaned = new ArrayList<>();
        for (String ingredient : ingredients) {
            if (ingredient == null || ingredient.trim().isEmpty()) {
                continue;
            }
            
            // 检查是否包含中文字符
            if (containsChinese(ingredient)) {
                log.warn("发现包含中文字符的 AVOID_INGREDIENT 值，已移除: {}", ingredient);
                continue;
            }
            
            cleaned.add(ingredient.trim().toLowerCase()); // 统一转换为小写
        }
        
        return cleaned;
    }
    
    /**
     * 检查字符串是否包含中文字符
     */
    private static boolean containsChinese(String str) {
        return CHINESE_PATTERN.matcher(str).find();
    }
    
    /**
     * 创建空的 dietaryStyles Map
     */
    public static Map<String, List<String>> createEmptyMap() {
        Map<String, List<String>> map = new HashMap<>();
        map.put(PreferenceStandardLibrary.PREF_KEY_TABOO, new ArrayList<>());
        map.put(PreferenceStandardLibrary.PREF_KEY_AVOID_INGREDIENT, new ArrayList<>());
        return map;
    }
    
    /**
     * 验证 dietaryStyles Map 的结构是否正确
     * 
     * @param dietaryStyles 待验证的 Map
     * @return 如果结构正确返回 true，否则返回 false
     */
    public static boolean isValidStructure(Map<String, List<String>> dietaryStyles) {
        if (dietaryStyles == null) {
            return false;
        }
        
        // 检查是否包含必要的键
        boolean hasTaboo = dietaryStyles.containsKey(PreferenceStandardLibrary.PREF_KEY_TABOO);
        boolean hasAvoidIngredient = dietaryStyles.containsKey(PreferenceStandardLibrary.PREF_KEY_AVOID_INGREDIENT);
        
        return hasTaboo && hasAvoidIngredient;
    }
}

