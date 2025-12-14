package com.calotter.inventory.domain.entity;

import com.calotter.common.core.domain.BaseEntity;
import com.calotter.common.core.domain.entity.StandardSpice;
import com.calotter.user.domain.entity.Household;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 家庭调料实体
 * 与 HouseholdUtensil 结构基本一致，但关联的是 StandardSpice
 */
@Data
@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "household_spices")
public class HouseholdSpice extends BaseEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
        name = "household_id",
        nullable = false,
        foreignKey = @ForeignKey(
            name = "fk_spice_household",
            foreignKeyDefinition = "FOREIGN KEY (household_id) REFERENCES households(id) ON DELETE CASCADE"
        )
    )
    private Household household;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "standard_spice_id", nullable = false)
    private StandardSpice metadata;

    @Column(nullable = false, columnDefinition = "boolean default true")
    private Boolean isAvailable;

    private String remark;
}
