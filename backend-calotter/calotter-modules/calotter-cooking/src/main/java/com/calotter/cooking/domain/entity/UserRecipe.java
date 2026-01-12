package com.calotter.cooking.domain.entity;

import com.calotter.common.core.domain.BaseEntity;
import com.calotter.cooking.domain.enums.DifficultyLevel;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.List;

/**
 * 用户收藏的菜谱（蓝图）
 * 物理隔离于 Dish，专门用于收藏和复用
 * 
 * 设计原则：
 * - 不做 JOIN 查询，只通过字段复制与 Dish 交互
 * - ID 与 Dish 完全隔离，避免类型混淆
 * - 生命周期独立：删除收藏不影响历史烹饪记录
 */
@Data
@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "user_recipes", indexes = {
    @Index(name = "idx_user_recipe_household", columnList = "household_id"),
    @Index(name = "idx_user_recipe_name", columnList = "household_id, name")
})
public class UserRecipe extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "household_id", nullable = false)
    private Long householdId; // 使用弱引用，避免循环依赖

    // --- 基础信息 ---
    @Column(nullable = false)
    private String name;

    private String coverImage;
    
    @Column(length = 1000)
    private String description;

    // --- 核心物理属性 ---
    @Column(nullable = false)
    private Integer totalWeightGram;

    // --- 总营养素 ---
    private Integer totalCalories;
    private Double totalProtein;
    private Double totalFat;
    private Double totalCarb;
    private Double totalFiber;

    // --- 烹饪元数据 ---
    private Integer cookingTimeMinutes;
    
    @Enumerated(EnumType.STRING)
    private DifficultyLevel difficulty;

    // --- 复杂结构 (使用 JSONB 存储) ---
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private List<CookingStep> steps;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private List<String> tags;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private List<IngredientSnapshot> ingredientSnapshots;

    // --- 静态内部类定义（与 Dish 保持一致） ---
    
    /**
     * 烹饪步骤
     */
    @Data
    public static class CookingStep {
        private Integer stepNumber;
        private String instruction;
        private Integer timeMin;
    }

    /**
     * 原料快照
     */
    @Data
    public static class IngredientSnapshot {
        private String name;
        private Double amountValue;
        private String amountUnit;
    }
}

