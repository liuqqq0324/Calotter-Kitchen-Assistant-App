package com.calotter.user.controller.dto;

import lombok.Data;
import java.util.List;

/**
 * 用户偏好更新请求 DTO（操作 User.preferences Map）
 * 包含两个大类：TASTE（口味）、CUISINE（菜系）
 * 
 * <p>注意：厨具（cookers/equipment）不是用户偏好，应该从家庭厨具表获取。
 */
@Data
public class UserPreferencesRequest {
    
    /** 口味偏好列表（标准库选项：light, rich, spicy, sweet, sour, salty, umami） */
    private List<String> tastes;
    
    /** 菜系偏好列表（标准库选项：chinese, japanese, korean, etc.） */
    private List<String> cuisines;
}

