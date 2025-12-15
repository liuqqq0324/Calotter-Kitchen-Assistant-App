package com.calotter.inventory.controller.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * 厨具请求 DTO
 */
@Data
public class UtensilRequest {
    
    @NotNull(message = "家庭ID不能为空")
    private Long householdId;
    
    @NotNull(message = "标准厨具ID不能为空")
    private Long standardUtensilId;
    
    @NotNull(message = "是否可用不能为空")
    private Boolean isAvailable;
    
    private String remark;
}
