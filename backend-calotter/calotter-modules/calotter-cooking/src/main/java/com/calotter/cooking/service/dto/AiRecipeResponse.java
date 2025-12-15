package com.calotter.cooking.service.dto;

import lombok.Data;

import java.util.List;
import java.util.Map;

/**
 * AI 响应结果
 * 包含：结构化菜谱（用于计时和库存）、智能分餐指南（用于营养分配）
 */
@Data
public class AiRecipeResponse {

    // 1. 生成的菜谱列表 (支持 1 主菜 + N 配菜)
    private List<GeneratedDish> dishes;

    // 2. 智能分餐指南 (Plating Guide)
    // Key: dinerId (对应 Request 中的 DinerSlot.dinerId, 如 "M-101")
    private Map<String, PlatingInstruction> platingGuide;

    // 3. 总体营养预估 (整顿饭的总值)
    private NutritionSummary totalNutrition;

    // --- 内部类定义 ---

    @Data
    public static class GeneratedDish {
        private String dishName;        // 菜名
        private String description;     // 短描述 (用于前端展示)
        private Integer totalTimeMin;   // 总耗时
        private String difficulty;      // 难度

        // [库存核心]：AI 必须返回精确的数量，后端才能去扣库存
        private List<RequiredIngredient> ingredients;

        // [前端核心]：步骤与计时器
        private List<CookingStep> steps;
    }

    @Data
    public static class RequiredIngredient {
        private String name;        // 食材名 (e.g. "Chicken Thigh")
        private Double amountValue; // e.g. 200.0
        private String amountUnit;  // e.g. "g"
        private String category;    // e.g. "Main", "Seasoning" (对应前端需求)
        // 备注：库存扣减逻辑将在 Service 层通过 name 匹配数据库实现
    }

    @Data
    public static class CookingStep {
        private Integer stepNumber; // 1, 2, 3...
        private String instruction; // 具体指令
        private Integer timeMin;    // [前端需求] 该步骤预计耗时 (用于倒计时)
        
        // [新增亮点]：针对冲突的提示
        // e.g. "Add chili peppers now. (Tip: Scoop out a portion for Dad before adding chili)"
        private String conflictTip; 
    }

    @Data
    public static class PlatingInstruction {
        // 分餐指令
        // e.g. "Serve 150g of Chicken. Add extra broccoli."
        private String instruction;

        // [补全] 个人预计摄入营养 (用于个人健康报表)
        private Integer estimatedCalories;
        private Integer estimatedProtein;
        private Integer estimatedFat;   // 补全
        private Integer estimatedCarb;  // 补全
        private Integer estimatedFiber; // 补全
    }

    @Data
    public static class NutritionSummary {
        private Integer calories;
        private Integer protein;
        private Integer fat;
        private Integer carb;
        private Integer fiber;
    }
}
