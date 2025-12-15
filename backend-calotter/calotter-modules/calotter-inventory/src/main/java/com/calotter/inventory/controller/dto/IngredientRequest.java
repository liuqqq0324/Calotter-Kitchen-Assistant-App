package com.calotter.inventory.controller.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;

import java.time.LocalDate;

/**
 * 食材请求 DTO
 */
@Data
public class IngredientRequest {
    
    @NotNull(message = "家庭ID不能为空")
    private Long householdId;
    
    @NotNull(message = "标准食材ID不能为空")
    private Long standardIngredientId;
    
    @NotNull(message = "数量不能为空")
    @Positive(message = "数量必须大于0")
    private Double quantity;
    
    @NotNull(message = "单位不能为空")
    private String unit; // "g", "ml", "pcs"
    
    private LocalDate expirationDate;
    
    private String location; // "FRIDGE", "FREEZER", "PANTRY"
}
