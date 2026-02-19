package com.calotter.cooking.service.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * 厨房快照
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class KitchenSnapshot {
    // 必须优先使用的 (临期、剩菜) -> Prompt: "MUST USE these if possible"
    private List<Item> priorityIngredients;
    
    // 普通可用的
    private List<Item> commonIngredients;
    
    // 可用调料 (List<String>)
    private List<String> availableSpices;
    
    // 可用厨具 (List<String>)
    private List<String> availableUtensils;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Item {
        private String name;
        private String quantity; // "500g", "2 pcs"
        private String unit;
        private String expireStatus; // "URGENT", "NORMAL"
    }
}
