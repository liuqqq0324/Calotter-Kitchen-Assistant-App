package com.calotter.inventory.controller.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 剩菜请求 DTO
 */
@Data
public class LeftoverRequest {
    
    @NotNull(message = "家庭ID不能为空")
    private Long householdId;
    
    @NotNull(message = "原始菜品ID不能为空")
    private Long originalDishId;
    
    @NotNull(message = "数量必须大于0")
    @Positive(message = "数量必须大于0")
    private Integer currentQuantityGram;
    
    @NotNull(message = "制作时间不能为空")
    private LocalDateTime producedTime;
}
