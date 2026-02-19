package com.calotter.common.core.domain.entity;

import jakarta.persistence.*;
import lombok.Data;

/**
 * 标准过敏原表
 */
@Data
@Entity
@Table(name = "ref_standard_allergens")
public class RefAllergen {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * 过敏源名称
     * e.g., "Peanuts" (花生), "Crustaceans" (甲壳类), "Lactose" (乳糖)
     */
    @Column(nullable = false, unique = true)
    private String name;

    /**
     * 描述 / 严重程度备注
     * e.g., "可能引起过敏性休克"
     */
    private String description;
}
