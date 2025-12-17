package com.calotter.health.domain.entity;

import com.calotter.common.core.domain.BaseEntity;
import com.calotter.health.domain.enums.LogSourceType;
import com.calotter.health.domain.enums.MealType;
import com.calotter.user.domain.entity.User;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 营养日志实体（摄入流水）
 * 记录每一次进食的原子操作
 */
@Data
@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "nutrition_logs", indexes = {
    @Index(name = "idx_log_user_date", columnList = "user_id, log_date")
})
public class NutritionLog extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // --- 归属信息 (使用JPA强引用) ---
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "log_date", nullable = false)
    private LocalDate logDate;   // 记录日期（冗余字段，便于分区查询）

    @Column(name = "eaten_at", nullable = false)
    private LocalDateTime eatenAt; // 具体进食时间

    @Enumerated(EnumType.STRING)
    @Column(name = "meal_type")
    private MealType mealType;   // BREAKFAST, LUNCH, DINNER, SNACK

    // --- 来源追踪 (核心逻辑) ---
    /**
     * 来源类型：
     * - APP_COOKING: 来自本App的烹饪会话
     * - LEFTOVER: 来自冰箱剩菜
     * - MANUAL: 用户手动输入 (比如"吃了一个苹果")
     * - EXTERNAL: 扫码或其他来源
     */
    @Column(name = "source_type", nullable = false)
    @Enumerated(EnumType.STRING)
    private LogSourceType sourceType;

    // ✅ 使用弱引用关联Dish（避免模块循环依赖）
    /**
     * 关联的Dish ID（弱引用）
     * - 当 sourceType = APP_COOKING 时，关联烹饪产生的 Dish ID
     * - 当 sourceType = LEFTOVER 时，关联 LeftoverDish.originalDishId 对应的 Dish ID
     * - 当 sourceType = MANUAL 或 EXTERNAL 时，为 null
     * 
     * 注意：使用弱引用避免 calotter-health 和 calotter-cooking 之间的循环依赖
     * Dish 信息通过Service层查询获取（如需要）
     */
    @Column(name = "dish_id") // 可空
    private Long dishId;

    // --- 食物快照（冗余字段，便于查询和展示）---
    @Column(name = "food_name", nullable = false)
    private String foodName; // 食物名称（从Dish获取或手动输入）

    @Column(name = "quantity")
    private Double quantity; // 摄入数量

    @Column(name = "unit")
    private String unit;     // 单位 (g, ml, serving)

    // --- 营养素快照 (必须存快照，不能只存Dish ID，因为需要记录实际摄入量) ---
    // 注意：存储基础营养值（100%时的值，从Dish获取），effectiveNutrition 根据 consumedPercentage 动态计算
    
    // 基础营养值（100%时的值，从Dish获取）
    @Column(name = "base_energy")
    private Integer baseEnergy; // 基础能量 (kcal) - 100%时的值

    @Column(name = "base_protein")
    private Double baseProtein;   // 基础蛋白质 (g) - 100%时的值

    @Column(name = "base_fat")
    private Double baseFat;       // 基础脂肪 (g) - 100%时的值

    @Column(name = "base_carbohydrates")
    private Double baseCarbohydrates;      // 基础碳水 (g) - 100%时的值

    @Column(name = "base_fiber")
    private Double baseFiber;     // 基础膳食纤维 (g) - 100%时的值

    // 实际摄入营养值（基于 consumedPercentage 计算，冗余字段便于查询）
    @Column(name = "energy")
    private Integer energy; // 实际能量 (kcal) = baseEnergy * consumedPercentage / 100

    @Column(name = "protein")
    private Double protein;   // 实际蛋白质 (g) = baseProtein * consumedPercentage / 100

    @Column(name = "fat")
    private Double fat;       // 实际脂肪 (g) = baseFat * consumedPercentage / 100

    @Column(name = "carbohydrates")
    private Double carbohydrates;      // 实际碳水 (g) = baseCarbohydrates * consumedPercentage / 100

    @Column(name = "fiber")
    private Double fiber;     // 实际膳食纤维 (g) = baseFiber * consumedPercentage / 100

    // --- 消费百分比 (用于记录用户实际吃掉的百分比) ---
    /**
     * 消费百分比（0.0 - 100.0）
     * - 用于记录用户实际吃掉的百分比
     * - 例如：如果做了100g的菜，用户只吃了50g，则 consumedPercentage = 50.0
     * - 默认值为 100.0（表示全部吃掉）
     * - 当 consumedPercentage < 100.0 时，剩余部分可以在当天过后转为剩菜存入 inventory
     */
    @Column(name = "consumed_percentage", nullable = false, columnDefinition = "decimal(5,2) default 100.00")
    private BigDecimal consumedPercentage = BigDecimal.valueOf(100.00);
}

