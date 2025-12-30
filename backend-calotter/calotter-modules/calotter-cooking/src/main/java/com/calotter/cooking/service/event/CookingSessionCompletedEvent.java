package com.calotter.cooking.service.event;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.context.ApplicationEvent;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 烹饪会话完成事件
 * 用于触发health模块创建NutritionLog，避免模块循环依赖
 * 
 * 注意：MealType枚举在health模块，这里使用String类型，由监听器转换为枚举
 */
@Data
public class CookingSessionCompletedEvent extends ApplicationEvent {
    
    private Long dishId;
    private String dishName;
    private DishNutritionSnapshot dishNutrition;
    private List<DinerConsumptionData> diners;
    private LocalDateTime consumedAt;
    private String mealType; // 使用String，避免依赖health模块的MealType枚举
    
    public CookingSessionCompletedEvent(Object source) {
        super(source);
    }
    
    public CookingSessionCompletedEvent(Object source, Long dishId, String dishName,
                                       DishNutritionSnapshot dishNutrition,
                                       List<DinerConsumptionData> diners,
                                       LocalDateTime consumedAt, String mealType) {
        super(source);
        this.dishId = dishId;
        this.dishName = dishName;
        this.dishNutrition = dishNutrition;
        this.diners = diners;
        this.consumedAt = consumedAt;
        this.mealType = mealType;
    }
    
    // 内部类：Dish营养快照
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class DishNutritionSnapshot {
        private Integer totalCalories;
        private Double totalProtein;
        private Double totalFat;
        private Double totalCarb;
        private Double totalFiber;
        private Integer totalWeightGram;
    }
    
    // 内部类：用餐者消费数据
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class DinerConsumptionData {
        private Long userId;
        private Double portionPercentage;
        private String note;
    }
}

