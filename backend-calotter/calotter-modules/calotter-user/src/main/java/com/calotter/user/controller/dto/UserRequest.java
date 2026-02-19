package com.calotter.user.controller.dto;

import lombok.Data;
import java.util.Map;

/**
 * 用户信息更新请求 DTO
 */
@Data
public class UserRequest {
    
    private Long userId;
    private Map<String, Object> profile; // 用户资料信息（age, gender, height, weight）
}
