package com.calotter.cooking.service.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * AI 生成上下文 (Prompt Context)
 * 核心逻辑：Shared Pot (CompositeGoal) + Individual Plate (DinerRoster)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AiCookingContext {

    // 1. 任务设置 (Task)
    private TaskSettings settings;

    // 2. 营养目标 (Total Constraints)
    // 指导 AI 决定"这顿饭总共要做多少量" (e.g., 买 1kg 牛肉还是 500g)
    private CompositeNutritionalGoal compositeGoal;

    // 3. 食客画像 (Diners)
    // 包含两部分：全局限制(红线) + 详细花名册(用于分餐)
    private DinerProfile dinerProfile;

    // 4. 厨房快照 (Resources)
    // 指导 AI "能做什么菜"以及"必须优先消耗什么"
    private KitchenSnapshot kitchenInventory;
}
