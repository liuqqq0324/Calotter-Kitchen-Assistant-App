package com.calotter.user.controller.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.Map;

/**
 * 用户偏好响应 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PreferencesResponse {
    
    private Map<String, Object> preferences;
}
