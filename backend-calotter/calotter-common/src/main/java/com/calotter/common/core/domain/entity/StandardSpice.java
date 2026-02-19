package com.calotter.common.core.domain.entity;

import io.hypersistence.utils.hibernate.type.array.ListArrayType;
import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.Type;

import java.util.ArrayList;
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
     * 饮食属性标签，用于物理熔断过滤。如 HIGH_SODIUM, HIGH_SUGAR, ALCOHOL, GLUTEN, SOY
     */
    @Type(ListArrayType.class)
    @Column(name = "dietary_tags", columnDefinition = "text[]")
    private List<String> dietaryTags = new ArrayList<>();

    public boolean hasDietaryTag(String tag) {
        return dietaryTags != null && dietaryTags.contains(tag);
    }

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
