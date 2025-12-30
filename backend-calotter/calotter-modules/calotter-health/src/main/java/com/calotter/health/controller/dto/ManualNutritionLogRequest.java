package com.calotter.health.controller.dto;

import com.calotter.health.domain.enums.MealType;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 手动记录营养日志请求DTO
 */
@Data
public class ManualNutritionLogRequest {
    
    @NotNull(message = "用户ID不能为空")
    private Long userId;
    
    @NotNull(message = "进食时间不能为空")
    private LocalDateTime eatenAt;
    
    private MealType mealType;
    
    @NotNull(message = "食物名称不能为空")
    private String foodName;
    
    @Min(value = 0, message = "数量必须大于等于0")
    private Double quantity;
    
    private String unit; // g, ml, serving
    
    // 营养信息
    @Min(value = 0, message = "卡路里必须大于等于0")
    private Integer calories;
    
    @Min(value = 0, message = "蛋白质必须大于等于0")
    private Double protein;
    
    @Min(value = 0, message = "脂肪必须大于等于0")
    private Double fat;
    
    @Min(value = 0, message = "碳水必须大于等于0")
    private Double carb;
    
    @Min(value = 0, message = "纤维必须大于等于0")
    private Double fiber;
}

