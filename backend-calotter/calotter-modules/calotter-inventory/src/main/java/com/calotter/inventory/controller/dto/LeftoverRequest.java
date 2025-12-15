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
    
    @NotNull(message = "菜名不能为空")
    private String name;
    
    private String coverImage;
    
    @Positive(message = "数量必须大于0")
    private Double quantityGram;
    
    @NotNull(message = "制作时间不能为空")
    private LocalDateTime producedTime;
}
