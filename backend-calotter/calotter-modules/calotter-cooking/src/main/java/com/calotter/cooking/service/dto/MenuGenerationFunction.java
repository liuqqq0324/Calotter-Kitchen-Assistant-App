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
    
    @JsonPropertyDescription("生成5套菜单选项，每套包含指定数量的菜品")
    @JsonProperty(required = true)
    private List<MenuOption> menus;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MenuOption {
        @JsonPropertyDescription("菜单ID (1-5)")
        @JsonProperty(required = true)
        private Integer menuId;
        
        @JsonPropertyDescription("该菜单中的食谱列表")
        @JsonProperty(required = true)
        private List<RecipeOption> recipes;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RecipeOption {
        @JsonPropertyDescription("菜品名称")
        @JsonProperty(required = true)
        private String title;
        
        @JsonPropertyDescription("简短描述")
        private String shortDescription;
        
        @JsonPropertyDescription("份数")
        @JsonProperty(required = true)
        private Integer servings;
        
        @JsonPropertyDescription("烹饪时间（分钟）")
        @JsonProperty(required = true)
        private Integer cookingTimeMin;
        
        @JsonPropertyDescription("难度等级: easy, medium, hard")
        @JsonProperty(required = true)
        private String difficulty;
        
        @JsonPropertyDescription("营养估算（整个食谱的总量）")
        @JsonProperty(required = true)
        private NutritionEstimateOption nutritionEstimate;
        
        @JsonPropertyDescription("食材列表")
        @JsonProperty(required = true)
        private List<IngredientOption> ingredients;
        
        @JsonPropertyDescription("烹饪步骤")
        @JsonProperty(required = true)
        private List<StepOption> steps;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class NutritionEstimateOption {
        @JsonPropertyDescription("总卡路里（整个食谱）")
        @JsonProperty(required = true)
        private Double calories;
        
        @JsonPropertyDescription("总蛋白质（克）")
        @JsonProperty(required = true)
        private Double proteinG;
        
        @JsonPropertyDescription("总脂肪（克）")
        @JsonProperty(required = true)
        private Double fatG;
        
        @JsonPropertyDescription("总碳水化合物（克）")
        @JsonProperty(required = true)
        private Double carbsG;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class IngredientOption {
        @JsonPropertyDescription("食材名称")
        @JsonProperty(required = true)
        private String name;
        
        @JsonPropertyDescription("数量值")
        @JsonProperty(required = true)
        private Double amountValue;
        
        @JsonPropertyDescription("数量单位（g, ml, pcs等）")
        @JsonProperty(required = true)
        private String amountUnit;
        
        @JsonPropertyDescription("是否可选")
        private Boolean isOptional = false;
        
        @JsonPropertyDescription("来源类型: INVENTORY (来自库存) 或 MANUAL_ADD (需要购买)")
        @JsonProperty(required = true)
        private String sourceType;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class StepOption {
        @JsonPropertyDescription("步骤编号")
        @JsonProperty(required = true)
        private Integer stepNumber;
        
        @JsonPropertyDescription("步骤说明")
        @JsonProperty(required = true)
        private String instruction;
        
        @JsonPropertyDescription("该步骤所需时间（分钟）")
        private Integer stepTimeMin;
    }
}

