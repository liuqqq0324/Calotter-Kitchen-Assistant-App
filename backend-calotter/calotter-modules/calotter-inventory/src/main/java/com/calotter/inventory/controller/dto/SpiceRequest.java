package com.calotter.inventory.controller.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * 调料请求 DTO
 */
@Data
public class SpiceRequest {
    
    @NotNull(message = "家庭ID不能为空")
    private Long householdId;
    
    @NotNull(message = "标准调料ID不能为空")
    private Long standardSpiceId;
    
    @NotNull(message = "是否可用不能为空")
    private Boolean isAvailable;
    
    private String remark;
}
