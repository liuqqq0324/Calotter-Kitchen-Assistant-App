package com.calotter.cooking.service.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

/**
 * 复合营养目标
 * 这一顿饭的总热量/营养目标 (所有食客需求之和)
 */
@Data
@Builder
public class CompositeNutritionalGoal {
    private Range<Integer> totalCalories; 
    private Integer totalProtein; // g
    private Integer totalFat;     // g
    private Integer totalCarb;    // g
    private Integer totalFiber;   // g

    @Data
    @AllArgsConstructor
    public static class Range<T> {
        private T min;
        private T max;
    }
}
