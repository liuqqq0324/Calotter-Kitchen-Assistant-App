package com.calotter.cooking.service.dto;

import lombok.Builder;
import lombok.Data;

import java.util.List;
import java.util.Map;

/**
 * 食客画像
 */
@Data
@Builder
public class DinerProfile {
    // A. 全局硬性限制 (Union of all allergies) -> 任何一道菜都不能出现
    private List<String> globalStrictAvoidance; 

    // B. 全局软性偏好冲突报告
    private PreferenceConflictReport preferenceConflicts;

    // C. 食客花名册 (关键新增！)
    // AI 需要知道每个人的名字和具体营养需求，才能生成 Plating Guide
    private List<DinerSlot> roster;

    @Data
    @Builder
    public static class DinerSlot {
        private String dinerId;   // "M-101" (家人) 或 "G-1" (客人)
        private String displayName; // "Dad", "Grandma"
        private Integer targetCalories; // 个人的目标热量 (用于分餐计算)
        private List<String> personalDislikes; // 个人的忌口 (用于 AI 提示 "给爸爸盛菜时避开葱")
    }

    @Data
    @Builder
    public static class PreferenceConflictReport {
        // 大家都讨厌的 (AI 绝对不放)
        private List<String> universalDislikes;
        // 大家都喜欢的 (AI 优先考虑)
        private List<String> commonLikedTastes;
        // 冲突点 (Key: 食材, Value: 描述) -> AI 需权衡
        // e.g. "Cilantro": "PARTIAL_DISLIKE (2/3 people dislike)"
        private Map<String, String> conflictDetails;
    }
}
