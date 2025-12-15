package com.calotter.user.controller.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * 家庭创建/更新请求 DTO
 */
@Data
public class HouseholdRequest {
    
    @NotBlank(message = "家庭名称不能为空")
    private String name;
    
    @NotNull(message = "所有者ID不能为空")
    private Long ownerId;
}
