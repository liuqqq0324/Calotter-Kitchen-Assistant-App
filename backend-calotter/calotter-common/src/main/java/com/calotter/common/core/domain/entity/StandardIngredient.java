package com.calotter.common.core.domain.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.util.List;

/**
 * 标准食材库
 */
@Data
@Entity
@Table(name = "ref_standard_ingredients")
public class StandardIngredient {
    
    @Id
    private Long id; // 手动分配 ID (e.g. 1001)

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String category; // MEAT, VEG

    // 营养素 (每100g)
    private Integer calories;
    private Double protein;
    private Double fat;
    private Double carb;
    private Double fiber;

    /**
     * 单位换算核心
     * 如果用户存 "1 pcs" 苹果，此处定义 1 pcs = 150g
     * 用于 Ingredient 中 quantity * averageGramPerUnit 计算总摄入
     */
    private Integer averageGramPerUnit;

    // 保质期 (天)
    private Integer shelfLifePantry;
    private Integer shelfLifeFridge;
    private Integer shelfLifeFreezer;

    @Enumerated(EnumType.STRING)
    private StorageLocation defaultLocation;

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "ingredient_allergens",
        joinColumns = @JoinColumn(name = "ingredient_id"),
        inverseJoinColumns = @JoinColumn(name = "allergen_id")
    )
    private List<RefAllergen> containedAllergens;
    
    public enum StorageLocation {
        FRIDGE, FREEZER, PANTRY
    }
}
