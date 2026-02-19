package com.calotter.user.controller.dto;

import lombok.Data;
import java.util.List;

/**
 * 用户偏好更新请求 DTO
 */
@Data
public class PreferencesRequest {
    
    private String dietaryType;
    private List<String> cuisineTypes;
    private String spiceLevel;
    private String cookingTimePreference;
}
