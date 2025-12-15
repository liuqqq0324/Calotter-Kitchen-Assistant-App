package com.calotter.health.domain.entity;

import com.calotter.common.core.domain.BaseEntity;
import com.calotter.health.domain.enums.LogSourceType;
import com.calotter.health.domain.enums.MealType;
import com.calotter.user.domain.entity.FamilyMember;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

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
    @Index(name = "idx_log_member_date", columnList = "family_member_id, log_date")
})
public class NutritionLog extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // --- 归属信息 (使用JPA强引用) ---
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "family_member_id", nullable = false)
    private FamilyMember familyMember;

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
    // 注意：营养数据基于Dish快照计算，但存储实际摄入的绝对值
    @Column(name = "calories")
    private Integer calories; // 卡路里 (kcal)

    @Column(name = "protein")
    private Double protein;   // 蛋白质 (g)

    @Column(name = "fat")
    private Double fat;       // 脂肪 (g)

    @Column(name = "carb")
    private Double carb;      // 碳水 (g)

    @Column(name = "fiber")
    private Double fiber;     // 膳食纤维 (g)
}

