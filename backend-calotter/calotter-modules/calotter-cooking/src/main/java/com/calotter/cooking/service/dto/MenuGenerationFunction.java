package com.calotter.cooking.service.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Menu Generation Function 用于 Spring AI Function Calling
 * 定义菜单生成的结构化输出格式，减少 Prompt 中的格式说明 token
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MenuGenerationFunction {
    

    @JsonProperty(required = true)
    private List<MenuOption> menus;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MenuOption {

        @JsonProperty(required = true)
        private Integer menuId;
        

        @JsonProperty(required = true)
        private List<RecipeOption> recipes;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RecipeOption {
        // 移除 "菜品名称" 描述，字段名 title 已经很清楚
        @JsonProperty(required = true)
        private String title;
        
        // 移除 "简短描述" 描述
        private String shortDescription;
        
        // 移除 "份数" 描述
        @JsonProperty(required = true)
        private Integer servings;
        
        // 移除 "烹饪时间（分钟）" 描述，字段名 cookingTimeMin 已经很清楚
        @JsonProperty(required = true)
        private Integer cookingTimeMin;
        
        // 简化描述，只保留枚举值
        @JsonPropertyDescription("easy, medium, or hard")
        @JsonProperty(required = true)
        private String difficulty;
        
        @JsonPropertyDescription("Cooking category: STIR_FRY_PAN_FRY (stir-fry/pan-fry), STEAM_BOIL (steam/boil), BRAISE_STEW (braise/stew), COLD_SALAD (cold salad), SOUP (soup), ROAST_BAKE (roast/bake)")
        @JsonProperty(required = true)
        private String category;
        
        @JsonPropertyDescription("Nutrition estimate for the entire recipe")
        @JsonProperty(required = true)
        private NutritionEstimateOption nutritionEstimate;
        
        // 移除描述，字段名 ingredients 已经很清楚
        @JsonProperty(required = true)
        private List<IngredientOption> ingredients;
        
        // 移除描述，字段名 steps 已经很清楚
        @JsonProperty(required = true)
        private List<StepOption> steps;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class NutritionEstimateOption {
        // 移除描述，字段名 calories 已经很清楚
        @JsonProperty(required = true)
        private Double calories;
        
        // 移除描述，字段名 proteinG 已经很清楚
        @JsonProperty(required = true)
        private Double proteinG;
        
        // 移除描述，字段名 fatG 已经很清楚
        @JsonProperty(required = true)
        private Double fatG;
        
        // 移除描述，字段名 carbsG 已经很清楚
        @JsonProperty(required = true)
        private Double carbsG;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class IngredientOption {
        // 移除描述，字段名 name 已经很清楚
        @JsonProperty(required = true)
        private String name;
        
        // 移除描述，字段名 amountValue 已经很清楚
        @JsonProperty(required = true)
        private Double amountValue;
        
        // 简化描述，只保留单位示例
        @JsonPropertyDescription("g, ml, pcs, etc")
        @JsonProperty(required = true)
        private String amountUnit;
        
        // 移除描述，字段名 isOptional 已经很清楚
        private Boolean isOptional = false;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class StepOption {
        // 移除描述，字段名 stepNumber 已经很清楚
        @JsonProperty(required = true)
        private Integer stepNumber;
        
        // 移除描述，字段名 instruction 已经很清楚
        @JsonProperty(required = true)
        private String instruction;
        
        // 移除描述，字段名 stepTimeMin 已经很清楚
        private Integer stepTimeMin;
    }
}

