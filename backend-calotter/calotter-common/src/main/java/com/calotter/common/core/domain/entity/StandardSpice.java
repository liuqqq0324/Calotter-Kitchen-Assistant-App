package com.calotter.common.core.domain.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.util.List;

/**
 * 标准调料库
 */
@Data
@Entity
@Table(name = "ref_standard_spices")
public class StandardSpice {

    @Id
    private Long id; // e.g., 3001 = "Soy Sauce"

    @Column(nullable = false)
    private String name;

    /**
     * 该调料包含的过敏原
     * e.g. 酱油 (Soy Sauce) -> [大豆, 麸质]
     * 这一步对于健康检查至关重要
     */
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "spice_allergens", // 中间表名称
        joinColumns = @JoinColumn(name = "spice_id"),
        inverseJoinColumns = @JoinColumn(name = "allergen_id")
    )
    private List<RefAllergen> containedAllergens;
}
