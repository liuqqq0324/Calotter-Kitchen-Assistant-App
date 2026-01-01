package com.calotter.cooking.controller.dto;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 烹饪完成请求DTO
 */
@Data
public class CookingCompletionRequest {
    
    @NotNull(message = "会话ID不能为空")
    private Long sessionId;
    
    private LocalDateTime consumedAt = LocalDateTime.now();

    @NotEmpty(message = "用餐者列表不能为空")
    private List<DinerConsumption> diners;

    private LeftoverStrategy leftoverHandling;

    // 内部类：用餐者消费信息
    @Data
    public static class DinerConsumption {
        @NotNull(message = "用户ID不能为空")
        private Long userId;
        
        @DecimalMin(value = "0.0", message = "比例不能小于0")
        @DecimalMax(value = "1.0", message = "比例不能大于1")
        private Double portionPercentage; // 例如 0.25 代表吃了 1/4
        
        private String note;
    }

    // 内部类：剩菜处理策略
    @Data
    public static class LeftoverStrategy {
        private LeftoverAction action; // 枚举: DISCARD, SAVE_TO_FRIDGE
        private String containerName;  // 存入冰箱显示的名称
        private String storageLocation;// FRIDGE, FREEZER
    }
}

