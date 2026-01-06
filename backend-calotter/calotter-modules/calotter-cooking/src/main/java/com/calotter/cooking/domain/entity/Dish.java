package com.calotter.cooking.domain.entity;

import com.calotter.common.core.domain.BaseEntity;
import com.calotter.cooking.domain.enums.DifficultyLevel;
import com.calotter.user.domain.entity.Household;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import com.fasterxml.jackson.annotation.JsonIgnore;
import java.util.List;

/**
 * Dish (菜谱快照/蓝图)
 * 代表一道已经生成的、具体的菜品配方。
 * 采用 Copy-on-Write 策略：每次配方微调都会生成新的 Dish 记录，
 * 以确保历史摄入记录和剩菜营养计算的绝对准确性。
 */
@Data
@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "dishes")
public class Dish extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 使用JPA强引用关联Household
    @JsonIgnore  // 防止 Jackson 序列化懒加载代理
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "household_id", nullable = false)
    private Household household;

    // --- 基础信息 ---
    @Column(nullable = false)
    private String name;      // 菜名 (e.g., "低脂版红烧肉")

    private String coverImage; // AI生成的图片或用户上传的图
    
    @Column(length = 1000)
    private String description; // 短描述

    /**
     * Dish 类型：
     * - TEMPLATE: “菜谱模板”（用于收藏/复用，不会随着每次烹饪变化）
     * - INSTANCE: “本次烹饪快照”（每次开始烹饪生成一条，保证每次有独立 dishId）
     */
    @Enumerated(EnumType.STRING)
    @Column(name = "dish_type", nullable = false)
    private DishType dishType = DishType.INSTANCE;

    /**
     * 如果该 Dish 是 INSTANCE，则指向它来源的 TEMPLATE dishId（可选但推荐）。
     * 如果该 Dish 本身就是 TEMPLATE，则为空。
     */
    @Column(name = "template_dish_id")
    private Long templateDishId;

    // --- 核心物理属性 (Snapshot Metrics) ---
    /**
     * 总重量 (克)。
     * 极其重要：用于计算营养密度 (Density)。
     * Density = TotalCalories / TotalWeight
     */
    @Column(nullable = false)
    private Integer totalWeightGram; 

    // --- 总营养素 (Total Nutrients for the WHOLE dish) ---
    private Integer totalCalories; // kCal
    private Double totalProtein;   // g
    private Double totalFat;       // g
    private Double totalCarb;      // g
    private Double totalFiber;     // g

    // --- 烹饪元数据 ---
    private Integer cookingTimeMinutes;
    
    @Enumerated(EnumType.STRING)
    private DifficultyLevel difficulty; // EASY, MEDIUM, HARD

    // --- 复杂结构 (使用 JSONB 存储) ---
    
    /**
     * 烹饪步骤
     * 结构: [{"stepNumber": 1, "instruction": "切肉...", "timeMin": 5}]
     */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private List<CookingStep> steps;

    /**
     * 标签列表
     * 结构: ["Spicy", "Sichuan", "Keto-Friendly"]
     */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private List<String> tags;

    /**
     * 原料清单的快照（快照模式，确保历史数据准确）
     * 结构: [{"name": "五花肉", "amountValue": 500.0, "amountUnit": "g"}, ...]
     */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private List<IngredientSnapshot> ingredientSnapshots;

    /**
     * 是否收藏
     */
    @Column(nullable = false)
    private boolean favorite = false;

    public enum DishType {
        TEMPLATE,
        INSTANCE
    }

    // --- 辅助计算方法 (Domain Logic) ---
    
    /**
     * 计算每100克的卡路里 (用于剩菜估算)
     */
    public int getCaloriesPer100g() {
        if (totalWeightGram == null || totalWeightGram == 0 || totalCalories == null) {
            return 0;
        }
        return (int) ((totalCalories * 100.0) / totalWeightGram);
    }

    // --- 静态内部类定义 ---
    
    /**
     * 烹饪步骤
     */
    @Data
    public static class CookingStep {
        private Integer stepNumber;
        private String instruction;
        private Integer timeMin; // 使用分钟，与AiRecipeResponse.CookingStep保持一致
    }

    /**
     * 原料快照
     */
    @Data
    public static class IngredientSnapshot {
        private String name;
        private Double amountValue; // 数量值，如 500.0
        private String amountUnit;  // 单位，如 "g", "ml", "pcs"
    }
}
