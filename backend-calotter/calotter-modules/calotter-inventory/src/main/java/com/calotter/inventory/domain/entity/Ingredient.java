package com.calotter.inventory.domain.entity;

import com.calotter.common.core.domain.BaseEntity;
import com.calotter.common.core.domain.entity.StandardIngredient;
import com.calotter.user.domain.entity.Household;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDate;

/**
 * 食材库存实体
 */
@Data
@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "household_ingredients")
public class Ingredient extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
        name = "household_id",
        nullable = false,
        foreignKey = @ForeignKey(
            name = "fk_ingredient_household",
            foreignKeyDefinition = "FOREIGN KEY (household_id) REFERENCES households(id) ON DELETE CASCADE"
        )
    )
    private Household household;

    /**
     * 必须关联 StandardIngredient (标准食材库)
     */
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "standard_ingredient_id", nullable = false)
    private StandardIngredient metadata;

    // --- 食材特有的属性 (区别于厨具) ---

    @Column(nullable = false)
    private Double quantity; // 数量 (e.g., 500.0)

    @Column(nullable = false)
    private String unit;     // 单位 (e.g., "g", "ml", "pcs")

    private LocalDate expirationDate; // 过期时间

    private String location; // 存放位置: "FRIDGE", "FREEZER", "PANTRY"
}
