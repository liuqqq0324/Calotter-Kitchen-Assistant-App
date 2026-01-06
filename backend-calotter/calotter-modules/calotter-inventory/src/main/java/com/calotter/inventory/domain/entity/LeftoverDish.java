package com.calotter.inventory.domain.entity;

import com.calotter.common.core.domain.BaseEntity;
import com.calotter.user.domain.entity.Household;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

/**
 * 剩菜实体
 * 
 * 注意：使用弱引用 originalDishId 关联 Dish，避免模块间的循环依赖。
 * 菜品信息（dishName, coverImage, 每100g的营养素）在创建时保存快照，避免查询时 JOIN。
 * 所有营养素快照都基于每100g的值，便于直接计算任意重量的营养信息。
 */
@Data
@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "household_leftovers")
public class LeftoverDish extends BaseEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 保留：用于查询过滤
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
        name = "household_id",
        nullable = false,
        foreignKey = @ForeignKey(
            name = "fk_leftover_household",
            foreignKeyDefinition = "FOREIGN KEY (household_id) REFERENCES households(id) ON DELETE CASCADE"
        )
    )
    private Household household;

    // 使用弱引用：关联原始Dish的ID（避免模块循环依赖）
    @Column(name = "original_dish_id", nullable = false)
    private Long originalDishId;

    // ✅ 菜品信息快照（创建时保存，避免查询时 JOIN 和循环依赖）
    @Column(name = "dish_name", length = 200)
    private String dishName; // 菜品名称快照
    
    @Column(name = "cover_image", length = 500)
    private String coverImage; // 封面图快照（可选）
    
    @Column(name = "calories_per_100g")
    private Integer caloriesPer100g; // 每100克的卡路里快照
    
    @Column(name = "protein_per_100g")
    private Double proteinPer100g; // 每100克的蛋白质快照（克）
    
    @Column(name = "fat_per_100g")
    private Double fatPer100g; // 每100克的脂肪快照（克）
    
    @Column(name = "carb_per_100g")
    private Double carbPer100g; // 每100克的碳水化合物快照（克）
    
    @Column(name = "fiber_per_100g")
    private Double fiberPer100g; // 每100克的纤维快照（克，可选）

    // 重命名：quantityGram -> currentQuantityGram（更清晰）
    @Column(nullable = false)
    private Integer currentQuantityGram; // 当前剩余重量（克）
    
    /**
     * 初始重量（克），创建时保存快照
     * 用于计算百分比，避免查询 Dish
     */
    @Column(name = "initial_quantity_gram")
    private Integer initialQuantityGram; // 初始重量（克）
    
    // 保留：记录制作时间（用于判断新鲜度）
    @Column(nullable = false)
    private LocalDateTime producedTime;
}
