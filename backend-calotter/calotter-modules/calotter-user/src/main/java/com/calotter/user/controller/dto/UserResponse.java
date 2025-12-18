package com.calotter.user.controller.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.Map;

/**
 * 用户信息响应 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserResponse {
    
    private Long userId;
    private String userName; // 注意：前端期望 userName，不是 username
    private String email;
    private String role;
    private Map<String, Object> profile; // 用户资料信息（age, gender, height, weight）
}
