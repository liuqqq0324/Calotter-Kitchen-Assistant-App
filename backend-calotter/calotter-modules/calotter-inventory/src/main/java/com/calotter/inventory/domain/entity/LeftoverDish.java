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
 * 获取 Dish 相关属性（name, coverImage, caloriesPer100g等）需要在 Service 层通过 DishRepository 查询。
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

    // 重命名：quantityGram -> currentQuantityGram（更清晰）
    @Column(nullable = false)
    private Integer currentQuantityGram; // 当前剩余重量（克）
    
    // 保留：记录制作时间（用于判断新鲜度）
    @Column(nullable = false)
    private LocalDateTime producedTime;

    // 移除：name 和 coverImage（需要在 Service 层通过 DishRepository 查询 Dish 获取）
    // 移除：caloriesPer100g（需要在 Service 层通过 DishRepository 查询 Dish 计算）
    
    // 注意：以下辅助方法需要在 Service 层实现：
    // - getName() - 通过 DishRepository.findById(originalDishId) 获取
    // - getCoverImage() - 通过 DishRepository.findById(originalDishId) 获取
    // - getCurrentCalories() - 通过 DishRepository 查询 Dish 后计算
    // - getCaloriesPer100g() - 通过 DishRepository 查询 Dish 后计算
}
