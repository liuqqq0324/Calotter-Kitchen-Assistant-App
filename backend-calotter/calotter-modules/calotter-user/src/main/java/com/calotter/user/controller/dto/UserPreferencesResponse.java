package com.calotter.user.controller.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;
import java.util.Map;

/**
 * 用户偏好响应 DTO（操作 User.preferences Map）
 * 包含两个大类：TASTE（口味）、CUISINE（菜系）
 * 
 * <p>注意：厨具（cookers/equipment）不是用户偏好，应该从家庭厨具表获取。
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserPreferencesResponse {
    
    /** 口味偏好列表 */
    private List<String> tastes;
    
    /** 菜系偏好列表 */
    private List<String> cuisines;
    
    /**
     * 从 User.preferences Map 构建响应
     */
    public static UserPreferencesResponse fromMap(Map<String, List<String>> preferences) {
        if (preferences == null) {
            return UserPreferencesResponse.builder()
                    .tastes(List.of())
                    .cuisines(List.of())
                    .build();
        }
        
        return UserPreferencesResponse.builder()
                .tastes(preferences.getOrDefault("TASTE", List.of()))
                .cuisines(preferences.getOrDefault("CUISINE", List.of()))
                .build();
    }
}

